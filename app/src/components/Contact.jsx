import { useEffect, useState } from 'react';
import { Col, Container, Row } from 'react-bootstrap';
import contactImg from '../assets/img/contact-img.svg';

const Contact = () => {
  const formInitialDetails = {
    firstName: '',
    lastName: '',
    email: '',
    phone: '',
    message: ''
  };

  const [formDetails, setFormDetails] = useState(formInitialDetails);
  const [buttonText, setButtonText] = useState('Send');
  const [status, setStatus] = useState({});
  const [result, setResult] = useState("");

  const onFormUpdate = (category, value) => {
    setFormDetails({
      ...formDetails,
      [category]: value
    });
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    setButtonText("Sending...");
    const formData = new FormData();

    // Append form data
    formData.append("access_key", "788c55f7-9965-44ab-92da-b039b1ad9b61");
    formData.append("first_name", formDetails.firstName);
    formData.append("last_name", formDetails.lastName);
    formData.append("email", formDetails.email);
    formData.append("phone", formDetails.phone);
    formData.append("message", formDetails.message);

    const response = await fetch("https://api.web3forms.com/submit", {
      method: "POST",
      body: formData
    });

    const data = await response.json();

    if (data.success) {
      setResult("Form Submitted Successfully");
      setButtonText("Send");
      event.target.reset();
      setFormDetails(formInitialDetails);
      setStatus({ success: true, message: "Form submitted successfully!" });
    } else {
      console.log("Error", data);
      setResult(data.message);
      setButtonText("Send");
      setStatus({ success: false, message: "Something went wrong, please try again." });
    }
  };

  return (
    <section className='contact' id='connect'>
      <Container>
        <Row className='align-items-center'>
          <Col md={6}>
            <img src={contactImg} alt='Contact Us' />
          </Col>
          <Col md={6}>
            <h2>Get In Touch</h2>
            <form onSubmit={handleSubmit}>
              <Row>
                <Col sm={6} className='px-1'>
                  <input 
                    type='text' 
                    value={formDetails.firstName} 
                    placeholder='First Name' 
                    onChange={(e) => onFormUpdate('firstName', e.target.value)} 
                    name="first_name" // Make sure to add a name attribute
                  />
                </Col>
                <Col sm={6} className='px-1'>
                  <input 
                    type='text' 
                    value={formDetails.lastName} 
                    placeholder='Last Name' 
                    onChange={(e) => onFormUpdate('lastName', e.target.value)} 
                    name="last_name" // Make sure to add a name attribute
                  />
                </Col>
                <Col sm={6} className='px-1'>
                  <input 
                    type='email' 
                    value={formDetails.email} 
                    placeholder='E-mail' 
                    onChange={(e) => onFormUpdate('email', e.target.value)} 
                    name="email" // Make sure to add a name attribute
                  />
                </Col>
                <Col sm={6} className='px-1'>
                  <input 
                    type='tel' 
                    value={formDetails.phone} 
                    placeholder='+91 12345 67890' 
                    onChange={(e) => onFormUpdate('phone', e.target.value)} 
                    name="phone" // Make sure to add a name attribute
                  />
                </Col>
                <Col>
                  <textarea 
                    rows='6' 
                    value={formDetails.message} 
                    placeholder='Message' 
                    onChange={(e) => onFormUpdate('message', e.target.value)}
                    name="message" // Make sure to add a name attribute
                  ></textarea>
                  <button type='submit'><span>{buttonText}</span></button>
                </Col>
                {status.message && (
                  <Col>
                    <p className={status.success === false ? 'danger' : 'success'}>{status.message}</p>
                  </Col>
                )}
              </Row>
            </form>
          </Col>
        </Row>
      </Container>
    </section>
  );
}

export default Contact;
