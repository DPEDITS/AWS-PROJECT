package test

import (
	"fmt"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/codepipeline"
	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformAwsCodePipeline(t *testing.T) {
	t.Parallel()

	terraformDir := "../terraform"

	terraformOptions := &terraform.Options{
		TerraformDir: terraformDir,
	}

	// Clean up after test
	defer terraform.Destroy(t, terraformOptions)

	// Deploy infrastructure
	terraform.InitAndApply(t, terraformOptions)

	// --- Get Outputs ---
	pipelineName := terraform.Output(t, terraformOptions, "codepipeline_name")
	awsRegion := terraform.Output(t, terraformOptions, "aws_region")
	ec2PublicIp := terraform.Output(t, terraformOptions, "ec2_public_ip")

	fmt.Println("Pipeline Name:", pipelineName)
	fmt.Println("AWS Region:", awsRegion)
	fmt.Println("EC2 Public IP:", ec2PublicIp)

	// --- AWS SDK Setup ---
	sess, err := session.NewSession(&aws.Config{Region: aws.String(awsRegion)})
	assert.NoError(t, err)
	cpClient := codepipeline.New(sess)

	// --- Check if CodePipeline Exists ---
	_, err = cpClient.GetPipeline(&codepipeline.GetPipelineInput{
		Name: aws.String(pipelineName),
	})
	assert.NoError(t, err, "Failed to find CodePipeline: %s", pipelineName)

	// --- Trigger Pipeline Execution ---
	fmt.Println("Starting pipeline execution...")
	_, err = cpClient.StartPipelineExecution(&codepipeline.StartPipelineExecutionInput{
		Name: aws.String(pipelineName),
	})
	assert.NoError(t, err, "Failed to start CodePipeline execution")

	// --- Wait for Pipeline Execution to Succeed ---
	fmt.Println("Waiting for CodePipeline to succeed...")

	waitForPipelineSuccess(t, cpClient, pipelineName)

	// --- HTTP Test on EC2 ---
	url := fmt.Sprintf("http://%s", ec2PublicIp)
	maxRetries := 30
	timeBetweenRetries := 10 * time.Second

	fmt.Println("Checking URL:", url)

	// Retry HTTP check
	http_helper.HttpGetWithRetryWithCustomValidation(
		t,
		url,
		nil,
		maxRetries,
		timeBetweenRetries,
		func(statusCode int, body string) bool {
			t.Logf("Status code: %d", statusCode)
			t.Logf("Body: %s", body)
			return statusCode == 200
		},
	)
}

// Helper to wait for CodePipeline to reach "Succeeded"
func waitForPipelineSuccess(t *testing.T, cpClient *codepipeline.CodePipeline, pipelineName string) {
	retries := 20
	sleep := 15 * time.Second

	for i := 0; i < retries; i++ {
		stateOutput, err := cpClient.GetPipelineState(&codepipeline.GetPipelineStateInput{
			Name: aws.String(pipelineName),
		})
		assert.NoError(t, err)

		allSucceeded := true
		for _, stage := range stateOutput.StageStates {
			if stage.LatestExecution == nil || *stage.LatestExecution.Status != "Succeeded" {
				allSucceeded = false
				break
			}
		}

		if allSucceeded {
			fmt.Println("✅ CodePipeline succeeded.")
			return
		}

		fmt.Printf("⏳ Pipeline not yet complete. Retrying (%d/%d)...\n", i+1, retries)
		time.Sleep(sleep)
	}

	t.Fatal("❌ CodePipeline did not succeed within expected time")
}