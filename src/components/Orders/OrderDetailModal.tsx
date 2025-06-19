"use client"

import { useState, useEffect } from "react"
import type { Order } from "../../types/Order"
import { X, Calendar, MapPin, Package, Download, Printer, User, Mail, Phone, DollarSign, Loader2 } from 'lucide-react'
import "./OrderDetailModal.css"

interface OrderDetailModalProps {
  order: Order
  onClose: () => void
  onPrint: () => void
  onDownloadPDF: () => void
}

export default function OrderDetailModal({ order, onClose, onPrint, onDownloadPDF }: OrderDetailModalProps) {
  const [orderDetails, setOrderDetails] = useState<Order | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    fetchOrderDetails()
  }, [order.orderId])

  const fetchOrderDetails = async () => {
    try {
      setLoading(true)
      setError(null)
      
      await new Promise(resolve => setTimeout(resolve, 1000))
      
      setOrderDetails(order)
    } catch (err) {
      console.error("Error fetching order details:", err)
      setError("Error al cargar los detalles del pedido")
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return (
      <div className="modal-overlay">
        <div className="order-detail-modal-enhanced">
          <div className="loading-modal">
            <Loader2 className="loading-icon" size={48} />
            <h3>Cargando detalles del pedido...</h3>
            <p>Por favor espere un momento</p>
          </div>
        </div>
      </div>
    )
  }

  if (error || !orderDetails) {
    return (
      <div className="modal-overlay">
        <div className="order-detail-modal-enhanced">
          <div className="error-modal">
            <Package size={48} />
            <h3>Error al cargar</h3>
            <p>{error || "No se pudieron cargar los detalles del pedido"}</p>
            <button className="btn btn-primary" onClick={onClose}>
              Cerrar
            </button>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="modal-overlay">
      <div className="order-detail-modal-enhanced">
        <div className="modal-header-enhanced">
          <div className="header-content-enhanced">
            <div className="order-title-section">
              <Package size={24} />
              <div>
                <h2>Detalles del Pedido</h2>
                <span className="order-id-large">#{orderDetails.orderId}</span>
              </div>
            </div>
            <div className="order-date-section">
              <Calendar size={16} />
              <span>
                {new Date(orderDetails.orderDate).toLocaleDateString("es-ES", {
                  year: "numeric",
                  month: "long",
                  day: "numeric",
                  hour: "2-digit",
                  minute: "2-digit",
                })}
              </span>
            </div>
          </div>
          <button className="close-btn-enhanced" onClick={onClose}>
            <X size={24} />
          </button>
        </div>

        <div className="modal-content-enhanced">
          <div className="customer-section-enhanced">
            <h3 className="section-title">
              <User size={20} />
              Información del Cliente
            </h3>
            
            <div className="customer-grid">
              <div className="customer-card">
                <div className="card-header">
                  <User size={16} />
                  <span>Datos Personales</span>
                </div>
                <div className="card-content">
                  <div className="info-row">
                    <span className="label">Nombre:</span>
                    <span className="value">{orderDetails.customerName}</span>
                  </div>
                  <div className="info-row">
                    <span className="label">ID Cliente:</span>
                    <span className="value">{orderDetails.customerId}</span>
                  </div>
                </div>
              </div>

              <div className="customer-card">
                <div className="card-header">
                  <Mail size={16} />
                  <span>Contacto</span>
                </div>
                <div className="card-content">
                  <div className="info-row">
                    <span className="label">Email:</span>
                    <span className="value">{orderDetails.customerEmail}</span>
                  </div>
                  <div className="info-row">
                    <span className="label">Teléfono:</span>
                    <span className="value">{orderDetails.customerPhone}</span>
                  </div>
                </div>
              </div>

              <div className="customer-card address-card">
                <div className="card-header">
                  <MapPin size={16} />
                  <span>Dirección</span>
                </div>
                <div className="card-content">
                  <div className="address-text">
                    {orderDetails.customerAddress}
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div className="financial-section-enhanced">
            <h3 className="section-title">
              <DollarSign size={20} />
              Resumen Financiero
            </h3>
            
            <div className="financial-card">
              <div className="financial-breakdown">
                <div className="financial-row">
                  <span className="financial-label">Subtotal:</span>
                  <span className="financial-value">${orderDetails.orderSubtotal?.toFixed(2) || "0.00"}</span>
                </div>
                <div className="financial-row">
                  <span className="financial-label">Impuestos:</span>
                  <span className="financial-value">${orderDetails.orderTax?.toFixed(2) || "0.00"}</span>
                </div>
                <div className="financial-row total-row">
                  <span className="financial-label">TOTAL:</span>
                  <span className="financial-value total-amount">
                    ${orderDetails.orderTotal?.toFixed(2) || "0.00"}
                  </span>
                </div>
              </div>
            </div>
          </div>

          
        </div>

        <div className="modal-footer-enhanced">
          <div className="order-actions-enhanced">
            <button className="action-btn-enhanced-od print-btn" onClick={onPrint}>
              <Printer size={16} />
              Imprimir
            </button>
            <button className="action-btn-enhanced-od download-btn" onClick={onDownloadPDF}>
              <Download size={16} />
              Descargar PDF
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
