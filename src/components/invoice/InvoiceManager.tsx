import { useState, useEffect } from "react"
import type { Client } from "../../types/User"
import type { Product } from "../../types/Product"
import { getClientsService } from "../../api/services/ClientService"
import { createOrderService, addDetailService, getNextOrderService } from "../../api/services/OrderService"
import { adaptarCliente } from "../../adapters/userAdapter"
import ClientSelector from "./ClientSelector"
import ProductSelector from "./ProductSelector"
import InvoiceForm from "./InvoiceForm"
import { Alert } from "../UI/Alert"
import "./InvoiceManager.css"
import ClientDisplay from "./ClientDisplay"
import { ConfirmDialog } from "../UI/ConfirmDialog"

export interface InvoiceItem {
  product: Product
  quantity: number
  subtotal: number
}

export interface InvoiceData {
  client: Client | null
  items: InvoiceItem[]
  total: number
}



export default function InvoiceManager() {
  const [clients, setClients] = useState<Client[]>([])
  const [invoiceData, setInvoiceData] = useState<InvoiceData>({
    client: null,
    items: [],
    total: 0,
  })
  const [showClientModal, setShowClientModal] = useState(false)
  const [showProductModal, setShowProductModal] = useState(false)
  const [alert, setAlert] = useState<{ type: "success" | "error" | "info" | "warning"; message: string } | null>(null)
  const [loading, setLoading] = useState(false)
  const [confirmDialog, setConfirmDialog] = useState<{
    isOpen: boolean
    title: string
    message: string
    onConfirm: () => void
  } | null>(null)
  const [nextOrderId, setNextOrderId] = useState<number | null>(null);

  useEffect(() => {
    fetchClients()
    getNextOrderId();
  }, [])

  useEffect(() => {
    const total = invoiceData.items.reduce((sum, item) => sum + item.subtotal, 0)
    setInvoiceData((prev) => ({ ...prev, total }))
  }, [invoiceData.items])
  async function getNextOrderId() {
    const result = await getNextOrderService();
    if (result.NextOrderID) {
      setNextOrderId(result.NextOrderID);
    } else {
      setNextOrderId(null);
    }
  }
  const fetchClients = async () => {
    try {
      const result = await getClientsService()
      const adaptedClients = result.map((client: any) => adaptarCliente(client))
      setClients(adaptedClients)
    } catch (error) {
      console.error("Error fetching clients:", error)
      showAlert("error", "Error al cargar los clientes")
    }
  }

  const showAlert = (type: "success" | "error" | "info" | "warning", message: string) => {
    setAlert({ type, message })
    setTimeout(() => setAlert(null), 5000)
  }

  const handleClientSelect = (client: Client) => {
    setInvoiceData((prev) => ({ ...prev, client }))
    setShowClientModal(false)
    showAlert("success", `Cliente ${client.nombre} seleccionado`)
  }

  const handleProductAdd = (product: Product, quantity: number) => {
    const existingItemIndex = invoiceData.items.findIndex((item) => item.product.id === product.id)

    if (existingItemIndex >= 0) {
      const newQuantity = invoiceData.items[existingItemIndex].quantity + quantity
      if (newQuantity > (product.stock ?? 0)) {
        showAlert("warning", `No hay suficiente stock. Stock disponible: ${(product.stock ?? 0)}`)
        return
      }
      updateItemQuantity(String(product.id), newQuantity)
    } else {
      if (quantity > (product.stock ?? 0)) {
        showAlert("warning", `No hay suficiente stock. Stock disponible: ${(product.stock ?? 0)}`)
        return
      }
      const newItem: InvoiceItem = {
        product,
        quantity,
        subtotal: product.price * quantity,
      }
      setInvoiceData((prev) => ({
        ...prev,
        items: [...prev.items, newItem],
      }))
    }
    setShowProductModal(false)
    showAlert("success", `${product.name} agregado a la factura`)
  }

  const updateItemQuantity = (productId: string, newQuantity: number) => {
    if (newQuantity <= 0) {
      removeItem(productId)
      return
    }

    setInvoiceData((prev) => ({
      ...prev,
      items: prev.items.map((item) => {
        if (String(item.product.id) === String(productId)) {
          if (newQuantity > (item.product.stock ?? 0)) {
            showAlert("warning", `No hay suficiente stock. Stock disponible: ${(item.product.stock ?? 0)}`)
            return item
          }
          return {
            ...item,
            quantity: newQuantity,
            subtotal: item.product.price * newQuantity,
          }
        }
        return item
      }),
    }))
  }

  const removeItem = (productId: string) => {
    const product = invoiceData.items.find((item) => String(item.product.id) === String(productId))
    if (product) {
      setConfirmDialog({
        isOpen: true,
        title: "Eliminar Producto",
        message: `¿Estás seguro de que deseas eliminar "${product.product.name}" de la factura?`,
        onConfirm: () => {
          setInvoiceData((prev) => ({
            ...prev,
            items: prev.items.filter((item) => String(item.product.id) !== String(productId)),
          }))
          showAlert("info", "Producto eliminado de la factura")
          setConfirmDialog(null)
        },
      })
    }
  }

  const handleCreateOrder = async () => {
    if (!invoiceData.client) {
      showAlert("warning", "Debe seleccionar un cliente")
      return
    }

    if (invoiceData.items.length === 0) {
      showAlert("warning", "Debe agregar al menos un producto")
      return
    }

    setLoading(true)
    try {
      const orderData = {
        clientId: invoiceData.client.clientId,
        items: invoiceData.items.map((item) => ({
          productId: item.product.id,
          quantity: item.quantity,
          price: item.product.price,
        })),
        total: invoiceData.total,
        customerAddress: invoiceData.client.direccion,
      }

      const result = await createOrderService(orderData)
      if (result.create) {
        const resulDetail = await addDetailService(orderData.items, result.orderid);
        if (resulDetail.error)
          showAlert("error", resulDetail.error)
        else {
          setInvoiceData({
            client: null,
            items: [],
            total: 0,
          }
          )
          showAlert("success", "Orden creada exitosamente")
          getNextOrderId();
        }
      }
    } catch (error) {
      console.error("Error creating order:", error)
      showAlert("error", "Error al crear la orden")
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="invoice-manager">
      <header className="invoice-header">
        <h1>Sistema de Facturación</h1>
        <p>Crear nueva factura #{nextOrderId}</p>
      </header>

      {alert && <Alert type={alert.type} message={alert.message} onClose={() => setAlert(null)} />}

      <div className="invoice-actions">
        {invoiceData.client ? (
          <ClientDisplay client={invoiceData.client} onEdit={() => setShowClientModal(true)} />
        ) : (
          <>
            <button className="btn btn-primary" onClick={() => setShowClientModal(true)}>
              Seleccionar Cliente
            </button>
          </>
        )}

      </div>
      <div className="invoice-content">

        <button
          className="btn btn-secondary"
          onClick={() => setShowProductModal(true)}
          disabled={!invoiceData.client}
        >
          Agregar Productos
        </button>

        <InvoiceForm
          invoiceData={invoiceData}
          onUpdateQuantity={updateItemQuantity}
          onRemoveItem={removeItem}
          onCreateOrder={handleCreateOrder}
          loading={loading}
        />
      </div>

      {showClientModal && (
        <ClientSelector
          clients={clients}
          selectedClient={invoiceData.client}
          onSelect={handleClientSelect}
          onClose={() => setShowClientModal(false)}
        />
      )}

      {showProductModal && <ProductSelector onSelect={handleProductAdd} onClose={() => setShowProductModal(false)} />}
      {confirmDialog && (
        <ConfirmDialog
          isOpen={confirmDialog.isOpen}
          title={confirmDialog.title}
          message={confirmDialog.message}
          confirmText="Eliminar"
          cancelText="Cancelar"
          onConfirm={confirmDialog.onConfirm}
          onCancel={() => setConfirmDialog(null)}
          type="danger"
        />
      )}
    </div>
  )
}
