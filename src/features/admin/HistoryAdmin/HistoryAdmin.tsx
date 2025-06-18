"use client"

import { Suspense, lazy } from "react"
import { useAuth } from "../../../auth/AuthContext"
import { Loader2 } from "lucide-react"

const OrderHistory = lazy(() => import("../../../components/Orders/OrderHistory"))

export default function HistoryAdmin() {
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
    <div className="history-page">
      <Suspense
        fallback={
          <div className="loading-container">
            <Loader2 className="loading-spinner" />
            <p>Cargando historial de pedidos...</p>
          </div>
        }
      >
        <OrderHistory />
      </Suspense>
    </div>
  )
}
