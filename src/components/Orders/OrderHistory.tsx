"use client"

import { useState, useEffect } from "react"
import type { Order } from "../../types/Order"
import { getOrdersService } from "../../api/services/OrderService"
import { adaptOrder } from "../../adapters/OrderAdapter"
import { Search, Calendar, Filter } from "lucide-react"
import OrderCard from "./OrderCard"
import OrderDetailModal from "./OrderDetailModal"
import { Alert } from "../UI/Alert"
import "./OrderHistory.css"

export default function OrderHistory() {
  const [orders, setOrders] = useState<Order[]>([])
  const [filteredOrders, setFilteredOrders] = useState<Order[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState("")
  const [dateFilter, setDateFilter] = useState("")
  const [statusFilter, setStatusFilter] = useState("")
  const [selectedOrder, setSelectedOrder] = useState<Order | null>(null)
  const [showDetailModal, setShowDetailModal] = useState(false)
  const [alert, setAlert] = useState<{ type: "success" | "error" | "info" | "warning"; message: string } | null>(null)

  useEffect(() => {
    fetchOrders()
  }, [])

  useEffect(() => {
    filterOrders()
  }, [orders, searchTerm, dateFilter, statusFilter])

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

    // Filter by search term
    if (searchTerm) {
      const searchLower = searchTerm.toLowerCase()
      filtered = filtered.filter(
        (order) =>
          order.orderId.toString().includes(searchLower) ||
          order.customerAddress.toLowerCase().includes(searchLower),
      )
    }

    // Filter by date
    if (dateFilter) {
      filtered = filtered.filter((order) => {
        const orderDate = new Date(order.orderDate).toISOString().split("T")[0]
        return orderDate === dateFilter
      })
    }


    setFilteredOrders(filtered)
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
    // Generate print content
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
      // This would typically call a service to generate PDF
      showAlert("info", "Generando PDF...")
      // Simulate PDF generation
      setTimeout(() => {
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
          <title>Orden ${order.orderId}</title>
          <style>
            body { font-family: Arial, sans-serif; margin: 20px; }
            .header { text-align: center; margin-bottom: 30px; }
            .order-info { margin-bottom: 20px; }
            .items-table { width: 100%; border-collapse: collapse; }
            .items-table th, .items-table td { border: 1px solid #ddd; padding: 8px; text-align: left; }
            .items-table th { background-color: #f2f2f2; }
            .total { text-align: right; margin-top: 20px; font-weight: bold; }
          </style>
        </head>
        <body>
          <div class="header">
            <h1>Factura</h1>
            <h2>Orden #${order.orderId}</h2>
          </div>
          <div class="order-info">
            <p><strong>Fecha:</strong> ${new Date(order.orderDate).toLocaleDateString()}</p>
            <p><strong>Dirección:</strong> ${order.customerAddress}</p>
          </div>
         
          <div class="total">
            <p>Total: $${order.orderTotal?.toFixed(2) || "0.00"}</p>
          </div>
        </body>
      </html>
    `
  }

  if (loading) {
    return (
      <div className="loading-container">
        <div className="loading-spinner"></div>
        <p>Cargando historial de pedidos...</p>
      </div>
    )
  }

  return (
    <div className="order-history">
      <header className="history-header">
        <h1>Historial de Pedidos</h1>
        <p>Gestiona y consulta todos los pedidos realizados</p>
      </header>

      {alert && <Alert type={alert.type} message={alert.message} onClose={() => setAlert(null)} />}

      <div className="filters-section">
        <div className="search-filters">
          <div className="search-input-container">
            <Search className="search-icon" size={20} />
            <input
              type="text"
              placeholder="Buscar por ID de orden o dirección..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="search-input"
            />
          </div>

          <div className="date-filter">
            <Calendar className="filter-icon" size={20} />
            <input
              type="date"
              value={dateFilter}
              onChange={(e) => setDateFilter(e.target.value)}
              className="date-input"
            />
          </div>

          <div className="status-filter">
            <Filter className="filter-icon" size={20} />
            <select value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)} className="status-select">
              <option value="">Todos los estados</option>
              <option value="pending">Pendiente</option>
              <option value="processing">Procesando</option>
              <option value="shipped">Enviado</option>
              <option value="delivered">Entregado</option>
              <option value="cancelled">Cancelado</option>
            </select>
          </div>
        </div>

        <div className="results-info">
          <span className="results-count">
            {filteredOrders.length} pedido{filteredOrders.length !== 1 ? "s" : ""} encontrado
            {filteredOrders.length !== 1 ? "s" : ""}
          </span>
        </div>
      </div>

      <div className="orders-grid">
        {filteredOrders.length === 0 ? (
          <div className="no-orders">
            <Calendar size={48} />
            <h3>No se encontraron pedidos</h3>
            <p>No hay pedidos que coincidan con los filtros seleccionados</p>
          </div>
        ) : (
          filteredOrders.map((order) => (
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
