"use client"

import type { Order } from "../../types/Order"
import { Calendar, MapPin, Package, Download, Printer, Eye } from "lucide-react"
import "./OrderCard.css"

interface OrderCardProps {
  order: Order
  onView: () => void
  onPrint: () => void
  onDownloadPDF: () => void
}

export default function OrderCard({ order, onView, onPrint, onDownloadPDF }: OrderCardProps) {
  const getStatusColor = (status: string) => {
    switch (status) {
      case "pending":
        return "status-pending"
      case "processing":
        return "status-processing"
      case "shipped":
        return "status-shipped"
      case "delivered":
        return "status-delivered"
      case "cancelled":
        return "status-cancelled"
      default:
        return "status-pending"
    }
  }

  const getStatusText = (status: string) => {
    switch (status) {
      case "pending":
        return "Pendiente"
      case "processing":
        return "Procesando"
      case "shipped":
        return "Enviado"
      case "delivered":
        return "Entregado"
      case "cancelled":
        return "Cancelado"
      default:
        return "Pendiente"
    }
  }

  return (
    <div className="order-card">
      <div className="order-header">
        <div className="order-id">
          <Package size={16} />
          <span>#{order.orderId}</span>
        </div>
      </div>

      <div className="order-details">
        <div className="detail-item">
          <Calendar size={14} />
          <span>
            {new Date(order.orderDate).toLocaleDateString("es-ES", {
              year: "numeric",
              month: "long",
              day: "numeric",
              hour: "2-digit",
              minute: "2-digit",
            })}
          </span>
        </div>

        <div className="detail-item">
          <MapPin size={14} />
          <span>{order.customerAddress}</span>
        </div>

        <div className="order-total">
          <span className="total-label">Total:</span>
          <span className="total-amount">${order.orderTotal?.toFixed(2) || "0.00"}</span>
        </div>

        
      </div>

      <div className="order-actions">
        <button className="action-btn view-btn" onClick={onView} title="Ver detalles">
          <Eye size={16} />
        </button>
        <button className="action-btn print-btn" onClick={onPrint} title="Imprimir">
          <Printer size={16} />
        </button>
        <button className="action-btn download-btn" onClick={onDownloadPDF} title="Descargar PDF">
          <Download size={16} />
        </button>
      </div>
    </div>
  )
}
