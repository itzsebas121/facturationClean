import { Outlet } from "react-router-dom";
import { NavbarAdmin } from "../../components/navigation/NavbarAdmin";
import '../index.css';

export function AdminDashboard() {

  return (
    <div className="container">

      <div className="navbar">
        <NavbarAdmin />
      </div>
      <div className="content">

        <Outlet />
      </div>
    </div>
  );
}