import { useAuth } from "../../auth/AuthContext";
export function ClientDashboard() {
  
  const { user, loading, logout } = useAuth();
  if (loading) {
    return <div>Cargando...</div>;
  }
  
  return (
    <div>
      <h1>Dashboard de Cliente</h1>
      <p>Bienvenido, {user?.nombre}!</p>
      <button onClick={logout}>Log out</button>
    </div>
  )
}
 