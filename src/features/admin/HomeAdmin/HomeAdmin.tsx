import { useAuth } from "../../../auth/AuthContext";
export function HomeAdmin() {
  const { user, loading } = useAuth();
  if (loading) {
    return <div>Loading...</div>;
  }
    return (
    <div>
      <h1>Home {user?.telefono}</h1>
    </div>
  );
}
