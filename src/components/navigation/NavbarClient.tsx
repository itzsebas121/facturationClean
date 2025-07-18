
import { useState, useEffect } from 'react';
import { useAuth } from '../../auth/AuthContext';
import { Home, Package, History, LogOut, Menu, X } from 'lucide-react';

export function NavbarClient() {
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
                <a href="/client/home" className="nav-link">
                  <Home size={18} />
                  <span>Home</span>
                </a>
              </li>
              <li>
                <a href="/client/products" className="nav-link">
                  <Package size={18} />
                  <span>Products</span>
                </a>
              </li>
              <li>
                <a href="/client/history" className="nav-link">
                  <History size={18} />
                  <span>History</span>
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
          <span className="mobile-brand-text">Client Portal</span>
          <button className="mobile-close-button" onClick={closeMenu}>
            <X size={20} />
          </button>
        </div>
        
        <ul className="mobile-nav-links">
          <li>
            <a href="/client/home" className="mobile-nav-link" onClick={closeMenu}>
              <Home size={18} />
              <span>Home</span>
            </a>
          </li>
          <li>
            <a href="/client/products" className="mobile-nav-link" onClick={closeMenu}>
              <Package size={18} />
              <span>Products</span>
            </a>
          </li>
          <li>
            <a href="/client/history" className="mobile-nav-link" onClick={closeMenu}>
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