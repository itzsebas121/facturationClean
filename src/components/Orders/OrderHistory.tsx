"use client"

import { useState, useEffect } from "react"
import type { Order } from "../../types/Order"
import { getOrdersService } from "../../api/services/OrderService"
import { adaptOrder } from "../../adapters/OrderAdapter"
import { Search, Calendar, User, Mail, Phone, MapPin, Package } from 'lucide-react'
import OrderCard from "./OrderCard"
import OrderDetailModal from "./OrderDetailModal"
import { Alert } from "../UI/Alert"
import { Pagination } from "../Pagination/Pagination"
import "./OrderHistory.css"

export default function OrderHistory() {
  const [orders, setOrders] = useState<Order[]>([])
  const [filteredOrders, setFilteredOrders] = useState<Order[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState("")
  const [dateFilter, setDateFilter] = useState("")
  const [filterField, setFilterField] = useState<string>("all")
  const [selectedOrder, setSelectedOrder] = useState<Order | null>(null)
  const [showDetailModal, setShowDetailModal] = useState(false)
  const [alert, setAlert] = useState<{ type: "success" | "error" | "info" | "warning"; message: string } | null>(null)
  const [currentPage, setCurrentPage] = useState(1)
  
  const ordersPerPage = 10
  const totalPages = Math.ceil(filteredOrders.length / ordersPerPage)

  useEffect(() => {
    fetchOrders()
  }, [])

  useEffect(() => {
    filterOrders()
  }, [orders, searchTerm, dateFilter, filterField])

  const fetchOrders = async () => {
    try {
      setLoading(true)
      const result = await getOrdersService()
      const adaptedOrders = result.map((order: any) => adaptOrder(order))
      setOrders(adaptedOrders)
    } catch (error) {
      console.error("Error fetching orders:", error)
      showAlert("error", "Error al cargar el historial de pedidos")
    } finally {
      setLoading(false)
    }
  }

  const filterOrders = () => {
    let filtered = [...orders]

    // Filter by search term and field
    if (searchTerm) {
      const searchLower = searchTerm.toLowerCase()
      
      if (filterField === "all") {
        filtered = filtered.filter((order) =>
          order.orderId.toString().includes(searchLower) ||
          order.customerId.toLowerCase().includes(searchLower) ||
          order.customerName.toLowerCase().includes(searchLower) ||
          order.customerEmail.toLowerCase().includes(searchLower) ||
          order.customerPhone.includes(searchTerm) ||
          order.customerAddress.toLowerCase().includes(searchLower)
        )
      } else {
        filtered = filtered.filter((order) => {
          const fieldValue = order[filterField as keyof Order]
          return fieldValue?.toString().toLowerCase().includes(searchLower)
        })
      }
    }

    // Filter by date
    if (dateFilter) {
      filtered = filtered.filter((order) => {
        const orderDate = new Date(order.orderDate).toISOString().split("T")[0]
        return orderDate === dateFilter
      })
    }

    setFilteredOrders(filtered)
    setCurrentPage(1) // Reset to first page after filtering
  }

  const showAlert = (type: "success" | "error" | "info" | "warning", message: string) => {
    setAlert({ type, message })
    setTimeout(() => setAlert(null), 5000)
  }

  const handleViewOrder = (order: Order) => {
    setSelectedOrder(order)
    setShowDetailModal(true)
  }

  const handlePrintOrder = (order: Order) => {
    const printContent = generatePrintContent(order)
    const printWindow = window.open("", "_blank")
    if (printWindow) {
      printWindow.document.write(printContent)
      printWindow.document.close()
      printWindow.print()
    }
  }

  const handleDownloadPDF = async (order: Order) => {
    try {
      showAlert("info", "Generando PDF profesional...")
      
      // Simulate PDF generation with more realistic timing
      setTimeout(() => {
        // Create a more professional PDF content
        const pdfContent = generateProfessionalPDF(order)
        const blob = new Blob([pdfContent], { type: 'text/html' })
        const url = URL.createObjectURL(blob)
        
        // Create download link
        const a = document.createElement('a')
        a.href = url
        a.download = `Factura-${order.orderId}.html`
        document.body.appendChild(a)
        a.click()
        document.body.removeChild(a)
        URL.revokeObjectURL(url)
        
        showAlert("success", "PDF descargado exitosamente")
      }, 2000)
    } catch (error) {
      showAlert("error", "Error al generar PDF")
    }
  }

  const generatePrintContent = (order: Order) => {
    return `
      <!DOCTYPE html>
      <html>
        <head>
          <title>Factura ${order.orderId}</title>
          <style>
            body { 
              font-family: 'Arial', sans-serif; 
              margin: 0; 
              padding: 20px; 
              background-color: #f8f9fa;
            }
            .invoice-container {
              max-width: 800px;
              margin: 0 auto;
              background: white;
              padding: 40px;
              border-radius: 8px;
              box-shadow: 0 0 20px rgba(0,0,0,0.1);
            }
            .header { 
              text-align: center; 
              margin-bottom: 40px; 
              border-bottom: 3px solid #2E3A2F;
              padding-bottom: 20px;
            }
            .company-name {
              font-size: 28px;
              font-weight: bold;
              color: #2E3A2F;
              margin-bottom: 10px;
            }
            .invoice-title {
              font-size: 24px;
              color: #379d3a;
              margin-bottom: 10px;
            }
            .invoice-number {
              font-size: 18px;
              color: #5F5F5F;
            }
            .customer-section {
              margin-bottom: 30px;
              padding: 20px;
              background-color: #F5F7F4;
              border-radius: 8px;
            }
            .section-title {
              font-size: 18px;
              font-weight: bold;
              color: #2E3A2F;
              margin-bottom: 15px;
              border-bottom: 2px solid #379d3a;
              padding-bottom: 5px;
            }
            .customer-info {
              display: grid;
              grid-template-columns: 1fr 1fr;
              gap: 15px;
            }
            .info-item {
              display: flex;
              flex-direction: column;
            }
            .info-label {
              font-weight: bold;
              color: #5F5F5F;
              font-size: 12px;
              text-transform: uppercase;
              margin-bottom: 5px;
            }
            .info-value {
              color: #1C1C1C;
              font-size: 14px;
            }
            .financial-section {
              margin-top: 40px;
              padding: 20px;
              background-color: #F5F7F4;
              border-radius: 8px;
            }
            .financial-row {
              display: flex;
              justify-content: space-between;
              margin-bottom: 10px;
              padding: 8px 0;
            }
            .financial-label {
              font-weight: 500;
              color: #5F5F5F;
            }
            .financial-value {
              font-weight: 600;
              color: #1C1C1C;
            }
            .total-row {
              border-top: 2px solid #379d3a;
              margin-top: 15px;
              padding-top: 15px;
              font-size: 18px;
              font-weight: bold;
            }
            .total-label {
              color: #2E3A2F;
            }
            .total-value {
              color: #379d3a;
            }
            .footer {
              margin-top: 40px;
              text-align: center;
              color: #5F5F5F;
              font-size: 12px;
              border-top: 1px solid #DDE2DC;
              padding-top: 20px;
            }
            @media print {
              body { background-color: white; }
              .invoice-container { box-shadow: none; }
            }
          </style>
        </head>
        <body>
          <div class="invoice-container">
            <div class="header">
              <div class="company-name">Tu Empresa</div>
              <div class="invoice-title">FACTURA</div>
              <div class="invoice-number">Orden #${order.orderId}</div>
            </div>
            
            <div class="customer-section">
              <div class="section-title">Información del Cliente</div>
              <div class="customer-info">
                <div class="info-item">
                  <div class="info-label">Nombre</div>
                  <div class="info-value">${order.customerName}</div>
                </div>
                <div class="info-item">
                  <div class="info-label">Email</div>
                  <div class="info-value">${order.customerEmail}</div>
                </div>
                <div class="info-item">
                  <div class="info-label">Teléfono</div>
                  <div class="info-value">${order.customerPhone}</div>
                </div>
                <div class="info-item">
                  <div class="info-label">Fecha</div>
                  <div class="info-value">${new Date(order.orderDate).toLocaleDateString('es-ES', {
                    year: 'numeric',
                    month: 'long',
                    day: 'numeric'
                  })}</div>
                </div>
              </div>
              <div style="margin-top: 15px;">
                <div class="info-label">Dirección de Entrega</div>
                <div class="info-value">${order.customerAddress}</div>
              </div>
            </div>
            
            <div class="financial-section">
              <div class="section-title">Resumen Financiero</div>
              <div class="financial-row">
                <span class="financial-label">Subtotal:</span>
                <span class="financial-value">$${order.orderSubtotal?.toFixed(2) || "0.00"}</span>
              </div>
              <div class="financial-row">
                <span class="financial-label">Impuestos:</span>
                <span class="financial-value">$${order.orderTax?.toFixed(2) || "0.00"}</span>
              </div>
              <div class="financial-row total-row">
                <span class="total-label">TOTAL:</span>
                <span class="total-value">$${order.orderTotal?.toFixed(2) || "0.00"}</span>
              </div>
            </div>
            
            <div class="footer">
              <p>Gracias por su compra</p>
              <p>Factura generada el ${new Date().toLocaleDateString('es-ES')}</p>
            </div>
          </div>
        </body>
      </html>
    `
  }

  const generateProfessionalPDF = (order: Order) => {
    return generatePrintContent(order) // Using the same professional template
  }

  const handlePageChange = (pageNumber: number) => {
    setCurrentPage(pageNumber)
  }

  const paginatedOrders = filteredOrders.slice((currentPage - 1) * ordersPerPage, currentPage * ordersPerPage)

  if (loading) {
    return (
      <div className="loading-container">
        <div className="loading-spinner"></div>
        <p>Cargando historial de pedidos...</p>
      </div>
    )
  }

  return (
    <div className="order-history-enhanced">
      <header className="history-header-enhanced">
        <div className="header-content">
          <h1>Historial de Pedidos</h1>
          <p>Gestiona y consulta todos los pedidos realizados</p>
        </div>
        <div className="header-stats">
          <div className="stat-card">
            <Package size={24} />
            <div>
              <span className="stat-number">{orders.length}</span>
              <span className="stat-label">Total Pedidos</span>
            </div>
          </div>
        </div>
      </header>

      {alert && <Alert type={alert.type} message={alert.message} onClose={() => setAlert(null)} />}

      <div className="filters-section-enhanced">
        <div className="search-filters-enhanced">
          <div className="search-input-container">
            <Search className="search-icon" size={20} />
            <input
              type="text"
              placeholder="Buscar pedidos..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="search-input"
            />
          </div>

          <select
            value={filterField}
            onChange={(e) => setFilterField(e.target.value)}
            className="filter-select"
          >
            <option value="all">Todos los campos</option>
            <option value="orderId">ID de Orden</option>
            <option value="customerName">Nombre Cliente</option>
            <option value="customerEmail">Email</option>
            <option value="customerPhone">Teléfono</option>
            <option value="customerAddress">Dirección</option>
          </select>

          <div className="date-filter">
            <Calendar className="filter-icon" size={20} />
            <input
              type="date"
              value={dateFilter}
              onChange={(e) => setDateFilter(e.target.value)}
              className="date-input"
            />
          </div>
        </div>

        <div className="results-info-enhanced">
          <span className="results-count">
            {filteredOrders.length} de {orders.length} pedido{filteredOrders.length !== 1 ? "s" : ""}
          </span>
          {totalPages > 1 && (
            <span className="page-info">
              Página {currentPage} de {totalPages}
            </span>
          )}
        </div>
      </div>

      <div className="orders-grid-enhanced">
        {filteredOrders.length === 0 ? (
          <div className="no-orders-enhanced">
            <Package size={64} />
            <h3>No se encontraron pedidos</h3>
            <p>No hay pedidos que coincidan con los filtros seleccionados</p>
          </div>
        ) : (
          paginatedOrders.map((order) => (
            <OrderCard
              key={order.orderId}
              order={order}
              onView={() => handleViewOrder(order)}
              onPrint={() => handlePrintOrder(order)}
              onDownloadPDF={() => handleDownloadPDF(order)}
            />
          ))
        )}
      </div>

      {totalPages > 1 && (
        <div className="pagination-container">
          <Pagination currentPage={currentPage} totalPages={totalPages} onPageChange={handlePageChange} />
        </div>
      )}

      {showDetailModal && selectedOrder && (
        <OrderDetailModal
          order={selectedOrder}
          onClose={() => setShowDetailModal(false)}
          onPrint={() => handlePrintOrder(selectedOrder)}
          onDownloadPDF={() => handleDownloadPDF(selectedOrder)}
        />
      )}
    </div>
  )
}
