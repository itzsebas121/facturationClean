"use client"

import type { Order } from "../../types/Order"
import { Calendar, MapPin, Package, Download, Printer, Eye, User, Mail, Phone, DollarSign } from 'lucide-react'
import "./OrderCard.css"

interface OrderCardProps {
  order: Order
  onView: () => void
  onPrint: () => void
  onDownloadPDF: () => void
}

export default function OrderCard({ order, onView, onPrint, onDownloadPDF }: OrderCardProps) {
  return (
    <div className="order-card-enhanced">
      <div className="order-header-enhanced">
        <div className="order-id-section">
          <Package size={18} />
          <span className="order-id">#{order.orderId}</span>
        </div>
        <div className="order-date">
          <Calendar size={14} />
          <span>
            {new Date(order.orderDate).toLocaleDateString("es-ES", {
              day: "2-digit",
              month: "short",
              year: "numeric",
            })}
          </span>
        </div>
      </div>

      <div className="customer-info-section">
        
        <div className="customer-details">
        <div className="detail-row">
          <User size={16} />
          <span>{order.customerName}</span>
        </div>
          <div className="detail-row">
            <Mail size={12} />
            <span className="detail-text">{order.customerEmail}</span>
          </div>
          
          <div className="detail-row">
            <Phone size={12} />
            <span className="detail-text">{order.customerPhone}</span>
          </div>
          
          <div className="detail-row">
            <MapPin size={12} />
            <span className="detail-text">{order.customerAddress}</span>
          </div>
        </div>
      </div>

      <div className="order-financial-section">
        <div className="financial-row-od">
          <span className="financial-label">Subtotal:</span>
          <span className="financial-value">${order.orderSubtotal?.toFixed(2) || "0.00"}</span>
        </div>
        
        <div className="financial-row-od">
          <span className="financial-label">Impuestos:</span>
          <span className="financial-value">${order.orderTax?.toFixed(2) || "0.00"}</span>
        </div>
        
        <div className="financial-row-od total-row">
          <span className="financial-label">Total:</span>
          <span className="financial-value total-amount">
            ${order.orderTotal?.toFixed(2) || "0.00"}
          </span>
        </div>
      </div>

      <div className="order-actions-enhanced">
        <button className="action-btn-enhanced-od view-btn" onClick={onView} title="Ver detalles">
          <Eye size={16} />
          <span>Ver</span>
        </button>
        <button className="action-btn-enhanced-od print-btn" onClick={onPrint} title="Imprimir">
          <Printer size={16} />
          <span>Imprimir</span>
        </button>
        <button className="action-btn-enhanced-od download-btn" onClick={onDownloadPDF} title="Descargar PDF">
          <Download size={16} />
          <span>PDF</span>
        </button>
      </div>
    </div>
  )
}
