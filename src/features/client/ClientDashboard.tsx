import { NavbarClient } from "../../components/navigation/NavbarClient";
import { Outlet } from "react-router-dom";
export function ClientDashboard() {
  return (
    <div className="container">
      <div className="navbar">

        <NavbarClient />
      </div>
      <div className="content">
        <Outlet />
        <div />
      </div>
    </div>
  )
}
