import { useState } from 'react'
import Navbarweb from './components/Navbar'
import Skills from './components/Skills'
import Projects from './components/Projects'
import { Banner } from './components/Banner';
import './App.css'
import 'bootstrap/dist/css/bootstrap.min.css';
import Contact from './components/Contact';

function App() {
  const [count, setCount] = useState(0)

  return (
    <>
    <Navbarweb/>
    <Banner/>
    <Skills/>
    <Projects/>
    <Contact/>
    </>
  )
}

export default App
