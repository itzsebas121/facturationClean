import { useAuth } from "../../auth/AuthContext";
import {Navbar} from "../../components/navigation/NavbarClient";
export function ClientDashboard() {
  
  const { user, loading, logout } = useAuth();
  if (loading) {
    return <div>Cargando...</div>;
  }
  
  return (
    <div>
      <Navbar />
      <h1>Dashboard de Cliente</h1>
      <p>Bienvenido, {user?.nombre}!</p>
      <button onClick={logout}>Log out</button>
    </div>
  )
}
 