import Container from 'react-bootstrap/Container';
import Nav from 'react-bootstrap/Nav';
import Navbar from 'react-bootstrap/Navbar';
import NavDropdown from 'react-bootstrap/NavDropdown';
import { useState,useEffect } from 'react';
import logo from '../assets/img/logo.svg' 
import navIcon1 from '../assets/img/nav-icon1.svg' 
import navIcon2 from '../assets/img/nav-icon2.svg' 
import navIcon3 from '../assets/img/nav-icon3.svg' 

function Navbarweb() {
    const[activeLink,setActiveLink]=useState('home');
    const[scrolled,setScrolled]=useState(false);

    useEffect(() => {
        const onScroll=()=>{
            if(window.scrollY>50){
                setScrolled(true);
            }
            else{
                setScrolled(false);
            }
          }
            window.addEventListener("scroll",onScroll);
            return ()=>window.removeEventListener("scroll",onScroll);
    },[])

    const OnUpdateActiveLink=(value)=>{
      setActiveLink(value);
    }

  return (
    <Navbar expand="lg" className={scrolled ?"scrolled": ""}>
      <Container>
        <Navbar.Brand href="#home">
            <img src={logo} alt="LOGO"/>
        </Navbar.Brand>
        <Navbar.Toggle aria-controls="basic-navbar-nav">
            <span className='navbar-toggler-icon'></span>
        </Navbar.Toggle>
        <Navbar.Collapse id="basic-navbar-nav">
          <Nav className="me-auto">
            <Nav.Link href="#home" className={activeLink=== 'home'?'active-navbar-link':'navbar-link'} onClick={()=>OnUpdateActiveLink('home')}>Home</Nav.Link>
            <Nav.Link href="#skills" className={activeLink=== 'skills'?'active-navbar-link':'navbar-link'} onClick={()=>OnUpdateActiveLink('skills')}>Skills</Nav.Link>
            <Nav.Link href="#projects" className={activeLink=== 'projects'?'active-navbar-link':'navbar-link'} onClick={()=>OnUpdateActiveLink('projects')}>Achievments</Nav.Link>
          </Nav>
          <span className='navbar-text'>
            <div className='social-icon'>
                <a href='https://www.linkedin.com/in/debashish-parida-421496276'><img src={navIcon1} alt="Linkedin"/></a>
                <a href='https://www.facebook.com/debashish.parida.395'><img src={navIcon2} alt="FaceBook"/></a>
                <a href='https://www.instagram.com/dp_edits29/'><img src={navIcon3} alt="Instagram"/></a>
            </div>
            <button className='vvd' onClick={()=>console.log('connect')}><span>Let's Connect</span></button>
          </span>
        </Navbar.Collapse>
        
      </Container>
    </Navbar>
  );
}

export default Navbarweb;