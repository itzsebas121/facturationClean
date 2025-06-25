import { useState, useEffect } from "react"
import type { Order } from "../../types/Order"
import { getDetailService, getOrdersService } from "../../api/services/OrderService"
import { adaptOrder } from "../../adapters/OrderAdapter"
import { Search, Calendar, Package } from 'lucide-react'
import OrderCard from "./OrderCard"
import OrderDetailModal from "./OrderDetailModal"
import { Alert } from "../UI/Alert"
import { Pagination } from "../Pagination/Pagination"
import "./OrderHistory.css"
import { OrderDetail } from "../../types/OrderDetail"
import { generatePrintContent } from "./View"

interface MyComponentProps {
  role: string;
  clientId?: number;
}
const OrderHistory: React.FC<MyComponentProps> = ({ role, clientId }) => {
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
      const result = await getOrdersService(role === "Client" ? clientId : undefined)
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
    if (dateFilter) {
      filtered = filtered.filter((order) => {
        const orderDate = new Date(order.orderDate).toISOString().split("T")[0]
        return orderDate === dateFilter
      })
    }

    setFilteredOrders(filtered)
    setCurrentPage(1)
  }

  const showAlert = (type: "success" | "error" | "info" | "warning", message: string) => {
    setAlert({ type, message })
    setTimeout(() => setAlert(null), 5000)
  }

  const handleViewOrder = (order: Order) => {
    setSelectedOrder(order)
    setShowDetailModal(true)
  }

  const handlePrintOrder = async (order: Order) => {
    const orderDetails = await getDetailService(order.orderId)
    const printContent = generatePrintContent(order, orderDetails)
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

      setTimeout(async () => {
        const orderDetails = await getDetailService(order.orderId)
        const pdfContent = generateProfessionalPDF(order, orderDetails)
        const blob = new Blob([pdfContent], { type: 'text/html' })
        const url = URL.createObjectURL(blob)

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
  const generateProfessionalPDF = (orderInfo: Order, details: OrderDetail[]) => {
    return generatePrintContent(orderInfo, details)
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
export default OrderHistory;