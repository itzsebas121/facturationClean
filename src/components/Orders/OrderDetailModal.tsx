"use client"

import type { Order } from "../../types/Order"
import { X, Calendar, MapPin, Package, Download, Printer } from "lucide-react"
import "./OrderDetailModal.css"

interface OrderDetailModalProps {
  order: Order
  onClose: () => void
  onPrint: () => void
  onDownloadPDF: () => void
}

export default function OrderDetailModal({ order, onClose, onPrint, onDownloadPDF }: OrderDetailModalProps) {
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
    <div className="modal-overlay">
      <div className="order-detail-modal">
        <div className="modal-header">
          <div className="header-content">
            <h2>Detalles del Pedido</h2>
            <div className="order-info">
              <span className="order-id">#{order.orderId}</span>
            </div>
          </div>
          <button className="close-btn" onClick={onClose}>
            <X size={24} />
          </button>
        </div>

        <div className="modal-content">
          <div className="order-summary">
            <div className="summary-item">
              <Calendar size={16} />
              <div>
                <span className="label">Fecha del pedido:</span>
                <span className="value">
                  {new Date(order.orderDate).toLocaleDateString("es-ES", {
                    year: "numeric",
                    month: "long",
                    day: "numeric",
                    hour: "2-digit",
                    minute: "2-digit",
                  })}
                </span>
              </div>
            </div>

            <div className="summary-item">
              <MapPin size={16} />
              <div>
                <span className="label">Dirección de entrega:</span>
                <span className="value">{order.customerAddress}</span>
              </div>
            </div>

            <div className="summary-item">
              <Package size={16} />
              <div>
                <span className="label">Total de productos:</span>
              </div>
            </div>
          </div>

          

          <div className="total-section">
            <div className="total-breakdown">
              <div className="total-line">
                <span>Subtotal:</span>
                <span>${order.orderTotal?.toFixed(2) || "0.00"}</span>
              </div>
              <div className="total-line">
                <span>IVA (19%):</span>
                <span>${((order.orderTotal || 0) * 0.19).toFixed(2)}</span>
              </div>
              <div className="total-line total-final">
                <span>Total:</span>
                <span>${((order.orderTotal || 0) * 1.19).toFixed(2)}</span>
              </div>
            </div>
          </div>
        </div>

        <div className="modal-footer">
          <div className="action-buttons">
            <button className="btn btn-secondary" onClick={onPrint}>
              <Printer size={16} />
              Imprimir
            </button>
            <button className="btn btn-primary" onClick={onDownloadPDF}>
              <Download size={16} />
              Descargar PDF
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
