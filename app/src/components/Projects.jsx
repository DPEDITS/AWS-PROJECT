import React from 'react'
import { Col, Container, Row,Tab } from 'react-bootstrap'
import Nav from 'react-bootstrap/Nav';
import mernstack from '../assets/img/mern-stack.png'
import spotify from '../assets/img/spotifyclone.png'
import gdg from '../assets/img/GDG.png'

import ProjectsCard from './ProjectsCard'
import colorSharp2 from '../assets/img/color-sharp2.png'
const Projects = () => {
  const projects = [
    {
      title: "CODE BEAT",
      description: "MERN STACK",
      imgUrl: mernstack,
    },
    {
      title: "LET'S UPGRADE",
      description: "SPOTIFY CLONE",
      imgUrl: spotify,
    },
    {
      title: "GOOGLE DEVELOPER GROUP",
      description: "ORGANIZING COMMITTEE",
      imgUrl: gdg,
    },
  ]
  return (
    <section className='project' id='projects'>
      <Container>
        <Row>
          <Col>
            <h2>Achievments</h2>
            <p>I proudly showcase my MERN stack certification, demonstrating 
              my comprehensive knowledge in MongoDB, Express.js, React, and Node.js, 
              and my commitment to mastering full-stack web development.</p>
            <Tab.Container id='projects-tab' defaultActiveKey="first">
            <Nav variant="pills" className='nav-pills mb-5 justify-content-center align-items-center' id='pills-tab'>
              <Nav.Item>
                <Nav.Link eventKey="first">Tab 1</Nav.Link>
              </Nav.Item>
              <Nav.Item>
                <Nav.Link eventKey="second">Tab 2</Nav.Link>
              </Nav.Item>
              <Nav.Item>
                <Nav.Link eventKey="third">Tab 3</Nav.Link>
              </Nav.Item>
            </Nav>
            <Tab.Content>
              <Tab.Pane eventKey="first">
                <Row>
                  {
                    projects.map((project,index)=>{
                      return(
                        <ProjectsCard key={index}{...project}/>
                      )
                    })
                  }
                </Row>
              </Tab.Pane>
              <Tab.Pane eventKey="second">Loren Ipsum</Tab.Pane>
              <Tab.Pane eventKey="third">Loren Ipsum</Tab.Pane>
            </Tab.Content>
            </Tab.Container>
          </Col>
        </Row>
      </Container>
      <img className='background-image-right' src={colorSharp2}/>
    </section>
  )
}

export default Projects