import type React from "react"
import { useState, useEffect } from "react"
import { Edit, Plus, Ban, Check, Search, Filter, RotateCcw } from "lucide-react"
import "./ClientAdmin.css"
import type { Client } from "../../../types/User"
import {
  createClientService,
  disableClientService,
  enableClientService,
  getClientsService,
  updateClientService,
} from "../../../api/services/ClientService"
import { Pagination } from "../../../components/Pagination/Pagination"
import { ClientModal } from "./ClientModal"
import { adaptarCliente } from "../../../adapters/userAdapter"
import { Alert } from "../../../components/UI/Alert"
import { ConfirmDialog } from "../../../components/UI/ConfirmDialog"

interface AlertState {
  show: boolean
  type: "success" | "error" | "info" | "warning"
  message: string
}

interface ConfirmState {
  show: boolean
  title: string
  message: string
  onConfirm: () => void
}

export function ClientAdmin() {
  const [clients, setClients] = useState<Client[]>([])
  const [loading, setLoading] = useState(false)
  const [currentPage, setCurrentPage] = useState(1)
  const [totalPages, setTotalPages] = useState(1)
  const [totalClients, setTotalClients] = useState(0)
  const [searchTerm, setSearchTerm] = useState("")
  const [isModalOpen, setIsModalOpen] = useState(false)
  const [selectedClient, setSelectedClient] = useState<Client | null>(null)
  const [isCreating, setIsCreating] = useState(false)
  const [actionLoading, setActionLoading] = useState<string | null>(null)
  const [alert, setAlert] = useState<AlertState>({ show: false, type: "info", message: "" })
  const [confirm, setConfirm] = useState<ConfirmState>({ show: false, title: "", message: "", onConfirm: () => {} })

  const pageSize = 20 // Increased for more compact view

  useEffect(() => {
    fetchClients()
  }, [currentPage, searchTerm])

  const showAlert = (type: AlertState["type"], message: string) => {
    setAlert({ show: true, type, message })
  }

  const hideAlert = () => {
    setAlert({ show: false, type: "info", message: "" })
  }

  const showConfirm = (title: string, message: string, onConfirm: () => void) => {
    setConfirm({ show: true, title, message, onConfirm })
  }

  const hideConfirm = () => {
    setConfirm({ show: false, title: "", message: "", onConfirm: () => {} })
  }

  const fetchClients = async () => {
    setLoading(true)
    try {
      const response = await getClientsService()

      if (response.error) {
        showAlert("error", response.error)
      } else {
        const adaptedClients = response.map(adaptarCliente)
        let filteredClients = adaptedClients
        if (searchTerm.trim()) {
          const searchLower = searchTerm.toLowerCase()
          filteredClients = adaptedClients.filter(
            (client: Client) =>
              client.nombre.toLowerCase().includes(searchLower) ||
              client.email.toLowerCase().includes(searchLower) ||
              client.cedula.toLowerCase().includes(searchLower),
          )
        }
        const total = filteredClients.length
        const startIndex = (currentPage - 1) * pageSize
        const endIndex = startIndex + pageSize
        const paginatedClients = filteredClients.slice(startIndex, endIndex)

        setClients(paginatedClients)
        setTotalClients(total)
        setTotalPages(Math.ceil(total / pageSize))
      }
    } catch (error) {
      showAlert("error", "Error al cargar los clientes")
    } finally {
      setLoading(false)
    }
  }

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault()
    setCurrentPage(1)
    fetchClients()
  }

  const handleClearFilters = () => {
    setSearchTerm("")
    setCurrentPage(1)
    setTimeout(() => {
      fetchClients()
    }, 0)
  }

  const handleCreateClient = () => {
    setSelectedClient(null)
    setIsCreating(true)
    setIsModalOpen(true)
  }

  const handleEditClient = (client: Client) => {
    setSelectedClient(client)
    setIsCreating(false)
    setIsModalOpen(true)
  }

  const handleToggleBlockClient = (client: Client) => {
    const action = client.isBlocked ? "desbloquear" : "bloquear"
    showConfirm("Confirmar acción", `¿Estás seguro de que deseas ${action} al cliente "${client.nombre}"?`, () =>
      confirmToggleBlockClient(client),
    )
  }

  const confirmToggleBlockClient = async (client: Client) => {
    setActionLoading(client.id)
    try {
      let response
      if (client.isBlocked) {
        response = await enableClientService(Number(client.id))
      } else {
        response = await disableClientService(Number(client.id))
      }

      if (response.error || response.Error) {
        showAlert("error", response.error || response.Error || "Error al actualizar el estado del cliente")
      } else {
        showAlert("success", response.message || response.Message)
        await fetchClients()
      }
    } catch (error) {
      showAlert("error", "Error al actualizar el estado del cliente")
    } finally {
      setActionLoading(null)
      hideConfirm()
    }
  }

  const handleSaveClient = async (clientData: any) => {
    setActionLoading("modal")
    try {
      let response
      if (isCreating) {
        response = await createClientService(clientData)
      } else {
        response = await updateClientService(clientData)
      }
      console.log(response)
      if (response.error || response.Error) {
        showAlert("error", response.error || response.Error)
      } else {
        showAlert("success", response.message || response.Message)
        setIsModalOpen(false)
        await fetchClients()
      }
    } catch (error) {
      showAlert("error", `Error al ${isCreating ? "crear" : "actualizar"} el cliente`)
    } finally {
      setActionLoading(null)
    }
  }

  const handlePageChange = (page: number) => {
    setCurrentPage(page)
  }

  const getClientInitial = (name: string) => {
    return name.charAt(0).toUpperCase()
  }

  const hasActiveFilters = searchTerm.trim() !== ""

  return (
    <div className="client-admin">
      {alert.show && <Alert type={alert.type} message={alert.message} onClose={hideAlert} />}

      <ConfirmDialog
        isOpen={confirm.show}
        title={confirm.title}
        message={confirm.message}
        onConfirm={confirm.onConfirm}
        onCancel={hideConfirm}
        type="warning"
      />

      <div className="client-admin__header">
        <h1 className="client-admin__title">Gestión de Clientes</h1>
        <button className="client-admin__create-btn" onClick={handleCreateClient} disabled={loading}>
          <Plus size={20} />
          Crear Cliente
        </button>
      </div>

      <div className="client-admin__filters">
        <form onSubmit={handleSearch} className="client-admin__search-form">
          <div className="client-admin__search-input-wrapper">
            <Search className="client-admin__search-icon" size={20} />
            <input
              type="text"
              placeholder="Buscar por nombre, email, cédula..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="client-admin__search-input"
            />
          </div>
          <button type="submit" className="client-admin__search-btn" disabled={loading}>
            <Filter size={20} />
            Filtrar
          </button>
          {hasActiveFilters && (
            <button type="button" className="client-admin__clear-btn" onClick={handleClearFilters} disabled={loading}>
              <RotateCcw size={20} />
              Limpiar
            </button>
          )}
        </form>
      </div>

      <div className="client-admin__stats">
        <p className="client-admin__stats-text">
          Total de clientes: <span className="client-admin__stats-number">{totalClients}</span>
          {hasActiveFilters && <span className="client-admin__filter-indicator">(filtrado)</span>}
        </p>
      </div>

      {loading ? (
        <div className="client-admin__loading">
          <div className="client-admin__spinner"></div>
          <p>Cargando clientes...</p>
        </div>
      ) : (
        <>
          <div className="client-admin__list">
            {clients.map((client) => (
              <div key={client.id} className="client-item">
                <div className="client-item__avatar">
                  <div className="client-initial">{getClientInitial(client.nombre)}</div>
                </div>

                <div className="client-item__content">
                  <div className="client-item__main">
                    <h3 className="client-item__name">{client.nombre}</h3>
                    <div className={`client-item__status ${client.isBlocked ? "blocked" : "active"}`}>
                      {client.isBlocked ? "Bloqueado" : "Activo"}
                    </div>
                  </div>

                  <div className="client-item__details">
                    <div className="client-item__info">
                      <span className="client-item__email">{client.email}</span>
                      <span className="client-item__cedula">CI: {client.cedula}</span>
                    </div>
                    <div className="client-item__contact">
                      <span className="client-item__phone">{client.telefono}</span>
                      <span className="client-item__address">{client.direccion}</span>
                    </div>
                  </div>
                </div>

                <div className="client-item__actions">
                  <button
                    className="client-item__edit-btn"
                    onClick={() => handleEditClient(client)}
                    disabled={actionLoading === client.id}
                    title="Editar cliente"
                  >
                    <Edit size={16} />
                  </button>
                  <button
                    className={`client-item__toggle-btn ${client.isBlocked ? "unblock" : "block"}`}
                    onClick={() => handleToggleBlockClient(client)}
                    disabled={actionLoading === client.id}
                    title={client.isBlocked ? "Desbloquear cliente" : "Bloquear cliente"}
                  >
                    {actionLoading === client.id ? (
                      <div className="client-admin__button-spinner"></div>
                    ) : client.isBlocked ? (
                      <Check size={16} />
                    ) : (
                      <Ban size={16} />
                    )}
                  </button>
                </div>
              </div>
            ))}
          </div>

          {clients.length === 0 && !loading && (
            <div className="client-admin__empty">
              <p>No se encontraron clientes</p>
              {hasActiveFilters && (
                <button className="client-admin__clear-empty-btn" onClick={handleClearFilters}>
                  <RotateCcw size={16} />
                  Limpiar filtros
                </button>
              )}
            </div>
          )}

          {totalPages > 1 && (
            <div className="client-admin__pagination">
              <Pagination currentPage={currentPage} totalPages={totalPages} onPageChange={handlePageChange} />
            </div>
          )}
        </>
      )}

      {isModalOpen && (
        <ClientModal
          client={selectedClient}
          isOpen={isModalOpen}
          onClose={() => setIsModalOpen(false)}
          onSave={handleSaveClient}
          isCreating={isCreating}
          loading={actionLoading === "modal"}
        />
      )}
    </div>
  )
}
