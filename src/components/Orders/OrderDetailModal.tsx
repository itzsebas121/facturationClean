import { useState, useEffect } from "react"
import type { Order } from "../../types/Order"
import type { OrderDetail } from "../../types/OrderDetail"
import { generatePrintContent } from "./View"
import {
  X,
  Calendar,
  MapPin,
  Package,
  Download,
  Printer,
  User,
  Mail,
  DollarSign,
  Loader2,
  ShoppingCart,
} from "lucide-react"
import "./OrderDetailModal.css"
import { getDetailService } from "../../api/services/OrderService"

interface OrderDetailModalProps {
  order: Order
  onClose: () => void
  onPrint: () => void
  onDownloadPDF: () => void
}

export default function OrderDetailModal({ order, onClose, onPrint, onDownloadPDF }: OrderDetailModalProps) {
  const [orderDetails, setOrderDetails] = useState<OrderDetail[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    fetchOrderDetails()
  }, [order.orderId])

  const fetchOrderDetails = async () => {
    try {
      setLoading(true)
      setError(null)
      const result = await getDetailService(order.orderId)
      console.log("Order details:", result)
      setOrderDetails(result || [])
    } catch (err) {
      console.error("Error fetching order details:", err)
      setError("Error al cargar los detalles del pedido")
    } finally {
      setLoading(false)
    }
  }

  const handlePrint = () => {
    const printContent = generatePrintContent(order, orderDetails)
    const printWindow = window.open("", "_blank")
    if (printWindow) {
      printWindow.document.write(printContent)
      printWindow.document.close()
      printWindow.print()
    }
  }

  const handleDownloadPDF = async () => {
    try {
      const pdfContent = generateProfessionalPDF(order, orderDetails)
      const blob = new Blob([pdfContent], { type: "text/html" })
      const url = URL.createObjectURL(blob)

      const a = document.createElement("a")
      a.href = url
      a.download = `Factura-${order.orderId}.html`
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      URL.revokeObjectURL(url)

      // Call the parent's onDownloadPDF if needed
      onDownloadPDF()
    } catch (error) {
      console.error("Error generating PDF:", error)
    }
  }


  const generateProfessionalPDF = (orderInfo: Order, details: OrderDetail[]) => {
    return generatePrintContent(orderInfo, details)
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

  if (error) {
    return (
      <div className="modal-overlay">
        <div className="order-detail-modal-enhanced">
          <div className="error-modal">
            <Package size={48} />
            <h3>Error al cargar</h3>
            <p>{error}</p>
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
                <span className="order-id-large">#{order.orderId}</span>
              </div>
            </div>
            <div className="order-date-section">
              <Calendar size={16} />
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
                    <span className="value">{order.customerName}</span>
                  </div>
                  <div className="info-row">
                    <span className="label">ID Cliente:</span>
                    <span className="value">{order.customerId}</span>
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
                    <span className="value">{order.customerEmail}</span>
                  </div>
                  <div className="info-row">
                    <span className="label">Teléfono:</span>
                    <span className="value">{order.customerPhone}</span>
                  </div>
                </div>
              </div>

              <div className="customer-card address-card">
                <div className="card-header">
                  <MapPin size={16} />
                  <span>Dirección de Entrega</span>
                </div>
                <div className="card-content">
                  <div className="address-text">{order.customerAddress}</div>
                </div>
              </div>
            </div>
          </div>

          {orderDetails.length > 0 && (
            <div className="products-section-enhanced">
              <h3 className="section-title">
                <ShoppingCart size={20} />
                Productos del Pedido ({orderDetails.length})
              </h3>

              <div className="products-section">
                <div className="section-title">Productos</div>
                <table className="products-table">
                  <thead>
                    <tr>
                      <th>Imagen</th>
                      <th>Producto</th>
                      <th>Cantidad</th>
                      <th>Precio Unit.</th>
                      <th>Subtotal</th>
                    </tr>
                  </thead>
                  <tbody>
                    {orderDetails.map(

                      (item) =>
                        <tr>
                          <td><img src={item.ImageUrl} alt={item.Name} className="product-image" /></td>
                          <td >{item.Name}</td>
                          <td className="quantity">{item.Quantity}</td>
                          <td className="price">${item.UnitPrice.toFixed(2)}</td>
                          <td className="price">${item.SubTotal.toFixed(2)}</td>
                        </tr>
                    )
                    }
                  </tbody>
                </table>
              </div>
            </div>
          )}

          <div className="financial-section-enhanced">
            <h3 className="section-title">
              <DollarSign size={20} />
              Resumen Financiero
            </h3>

            <div className="financial-card">
              <div className="financial-breakdown">
                <div className="financial-row">
                  <span className="financial-label">Subtotal:</span>
                  <span className="financial-value">${order.orderSubtotal?.toFixed(2) || "0.00"}</span>
                </div>
                <div className="financial-row">
                  <span className="financial-label">Impuestos:</span>
                  <span className="financial-value">${order.orderTax?.toFixed(2) || "0.00"}</span>
                </div>
                <div className="financial-row total-row">
                  <span className="financial-label">TOTAL:</span>
                  <span className="financial-value total-amount">${order.orderTotal?.toFixed(2) || "0.00"}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className="modal-footer-enhanced">
          <div className="action-buttons-enhanced">
            <button className="btn btn-secondary" onClick={handlePrint}>
              <Printer size={16} />
              Imprimir
            </button>
            <button className="btn btn-primary" onClick={handleDownloadPDF}>
              <Download size={16} />
              Descargar PDF
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
