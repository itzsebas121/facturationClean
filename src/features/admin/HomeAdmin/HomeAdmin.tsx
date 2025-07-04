import { Suspense, lazy } from "react"
import { useAuth } from "../../../auth/AuthContext"
import { Loader2 } from "lucide-react"

const InvoiceManager = lazy(() => import("../../../components/invoice/InvoiceManager"))

export default function HomeAdmin() {
  const { user, loading } = useAuth()

  if (loading) {
    return (
      <div className="loading-container">
        <Loader2 className="loading-spinner" />
        <p>Cargando...</p>
      </div>
    )
  }

  if (user?.rol !== "Admin") {
    return <div>No tienes permisos para acceder a esta página</div>
  }

  return (
    <div className="admin-page">
      <Suspense
        fallback={
          <div className="loading-container">
            <Loader2 className="loading-spinner" />
            <p>Cargando sistema de facturación...</p>
          </div>
        }
      >
        <InvoiceManager />
      </Suspense>
    </div>
  )
}
