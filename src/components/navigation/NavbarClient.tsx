import { useAuth } from "../../auth/AuthContext";
export function NavbarClient() {
const { logout } = useAuth();
  return (
    <nav className="navbar-container">
      <ul>
        <li>
          <a href="/client/home">Home</a>
        </li>
        <li>
          <a href="/client/products">Products</a>
        </li>
        <li>
          <a href="/client/history">History</a>
        </li>
        
      </ul>
      <button onClick={logout}>
        Cerrar Sesión
      </button>
    </nav>
  );
}