import { Suspense, lazy } from "react"
import { useAuth } from "../../../auth/AuthContext"
import { Loader2 } from "lucide-react"

const OrderHistory = lazy(() => import("../../../components/Orders/OrderHistory"))
export function HistoryClient() {

  const { user, loading } = useAuth()

  if (loading) {
    return (
      <div className="loading-container">
        <Loader2 className="loading-spinner" />
        <p>Cargando...</p>
      </div>
    )
  }

  if (user?.rol !== "Client") {
    return <div>No tienes permisos para acceder a esta página</div>
  }

  return (
    <div className="history-page">
      <Suspense
        fallback={
          <div className="loading-container">
            <Loader2 className="loading-spinner" />
            <p>Cargando historial de pedidos...</p>
          </div>
        }
      >
        <OrderHistory role={user.rol} clientId={Number(user.id)} />
      </Suspense>
    </div>
  )
}