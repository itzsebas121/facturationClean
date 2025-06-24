
import { useState, useEffect } from 'react';
import { Home, History, LogOut, Menu, X, Box, Users } from 'lucide-react';
import { useAuth } from '../../auth/AuthContext';
import './Navbar.css'; 

export function NavbarAdmin() {
  const { user, logout } = useAuth();
  const [isOpen, setIsOpen] = useState(false);

  const toggleMenu = () => {
    setIsOpen(!isOpen);
  };

  useEffect(() => {
    if (isOpen) {
      document.body.classList.add('menu-open');
    } else {
      document.body.classList.remove('menu-open');
    }

    return () => {
      document.body.classList.remove('menu-open');
    };
  }, [isOpen]);

  const closeMenu = () => {
    setIsOpen(false);
  };

  return (
    <>
      <nav className="modern-navbar">
        <div className="navbar-container">
          {/* Logo/Brand */}
          <div className="navbar-brand">
            <span className="brand-text">Bienvenido {user?.nombre}</span>
          </div>

          {/* Desktop Navigation */}
          <div className="navbar-center">
            <ul className="nav-links-desktop">
              <li>
                <a href="/admin/home" className="nav-link">
                  <Home size={18} />
                  <span>Home</span>
                </a>
              </li>
              <li>
                <a href="/admin/history" className="nav-link">
                  <History size={18} />
                  <span>Historial</span>
                </a>
              </li>
              <li>
                <a href="/admin/products" className="nav-link">
                  <Box size={18} />
                  <span>Productos</span>
                </a>
              </li>
              <li>
                <a href="/admin/clients" className="nav-link">
                  <Users size={18} />
                  <span>Clientes</span>
                </a>
              </li>
            </ul>
          </div>

          {/* Right side - Desktop logout + Mobile menu */}
          <div className="navbar-right">
            <button className="logout-button-desktop" onClick={logout}>
              <LogOut size={18} />
              <span>Cerrar Sesión</span>
            </button>
            
            <button className="menu-toggle" onClick={toggleMenu}>
              <Menu size={20} />
            </button>
          </div>
        </div>
      </nav>

      {/* Mobile Menu Sliding from Left */}
      <div className={`mobile-menu ${isOpen ? 'mobile-menu-open' : ''}`}>
        <div className="mobile-menu-header">
          <span className="mobile-brand-text">Admin Portal</span>
          <button className="mobile-close-button" onClick={closeMenu}>
            <X size={20} />
          </button>
        </div>
        
        <ul className="mobile-nav-links">
          <li>
            <a href="/admin/home" className="mobile-nav-link" onClick={closeMenu}>
              <Home size={18} />
              <span>Home</span>
            </a>
          </li>
          <li>
            <a href="/admin/history" className="mobile-nav-link" onClick={closeMenu}>
              <History size={18} />
              <span>History</span>
            </a>
          </li>
          <li>
            <button className="mobile-logout-button" onClick={() => { closeMenu(); logout(); }}>
              <LogOut size={18} />
              <span>Cerrar Sesión</span>
            </button>
          </li>
        </ul>
      </div>

      {/* Overlay */}
      {isOpen && <div className={`navbar-overlay ${isOpen ? 'show' : ''}`} onClick={closeMenu} />}
    </>
  );
}