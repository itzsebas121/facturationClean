"use client"

import type React from "react"
import { useState, useEffect } from "react"
import { Edit, Plus, Ban, Check, Search, Filter } from 'lucide-react'
import "./ClientAdmin.css"
import type { Client } from "../../../types/User"
import { createClientService, getClientsService, updateClientService } from "../../../api/services/ClientService"
import { Pagination } from "../../../components/Pagination/Pagination"
import { ClientModal } from "./ClientModal"
import { adaptarCliente } from "../../../adapters/userAdapter"

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

  const pageSize = 10

  useEffect(() => {
    fetchClients()
  }, [currentPage, searchTerm])

  const fetchClients = async () => {
    setLoading(true)
    try {
      // Get all clients from API (no server-side pagination)
      const allClientsData = await getClientsService()
      
      // Adapt all clients
      const adaptedClients = allClientsData.map(adaptarCliente)
      
      // Apply client-side filtering
      let filteredClients = adaptedClients
      if (searchTerm.trim()) {
        const searchLower = searchTerm.toLowerCase()
        filteredClients = adaptedClients.filter((client: Client) => 
          client.nombre.toLowerCase().includes(searchLower) ||
          client.email.toLowerCase().includes(searchLower) ||
          client.cedula.toLowerCase().includes(searchLower)
        )
      }
      
      // Calculate pagination
      const total = filteredClients.length
      const startIndex = (currentPage - 1) * pageSize
      const endIndex = startIndex + pageSize
      const paginatedClients = filteredClients.slice(startIndex, endIndex)
      
      // Update state
      setClients(paginatedClients)
      setTotalClients(total)
      setTotalPages(Math.ceil(total / pageSize))
    } catch (error) {
      console.error("Error fetching clients:", error)
    } finally {
      setLoading(false)
    }
  }

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault()
    setCurrentPage(1)
    fetchClients()
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

  const handleToggleBlockClient = async (client: Client) => {
    setActionLoading(client.id)
    try {
      const updatedClient = { ...client, isBlocked: !client.isBlocked }
      await updateClientService(updatedClient)
      await fetchClients()
    } catch (error) {
      console.error("Error toggling client block status:", error)
    } finally {
      setActionLoading(null)
    }
  }

  const handleSaveClient = async (clientData: Omit<Client, "id"> | Client) => {
    setActionLoading("modal")
    try {
      if (isCreating) {
        await createClientService(clientData as Client)
      } else {
        await updateClientService(clientData as Client)
      }
      setIsModalOpen(false)
      await fetchClients()
    } catch (error) {
      console.error("Error saving client:", error)
    } finally {
      setActionLoading(null)
    }
  }

  const handlePageChange = (page: number) => {
    setCurrentPage(page)
  }

  return (
    <div className="client-admin">
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
        </form>
      </div>

      <div className="client-admin__stats">
        <p className="client-admin__stats-text">
          Total de clientes: <span className="client-admin__stats-number">{totalClients}</span>
        </p>
      </div>

      {loading ? (
        <div className="client-admin__loading">
          <div className="client-admin__spinner"></div>
          <p>Cargando clientes...</p>
        </div>
      ) : (
        <>
          <div className="client-admin__grid">
            {clients.map((client) => (
              <div key={client.id} className="client-admin__card">
                <div className="client-admin__card-header">
                  <h3 className="client-admin__card-title">{client.nombre}</h3>
                  <div className={`client-admin__status ${client.isBlocked ? "blocked" : "active"}`}>
                    {client.isBlocked ? "Bloqueado" : "Activo"}
                  </div>
                </div>

                <div className="client-admin__card-content">
                  <div className="client-admin__card-info">
                    <p>
                      <strong>Email:</strong> {client.email}
                    </p>
                    <p>
                      <strong>Teléfono:</strong> {client.telefono}
                    </p>
                    <p>
                      <strong>Cédula:</strong> {client.cedula}
                    </p>
                    <p>
                      <strong>Dirección:</strong> {client.direccion}
                    </p>
                  </div>
                </div>

                <div className="client-admin__card-actions">
                  <button
                    className="client-admin__edit-btn"
                    onClick={() => handleEditClient(client)}
                    disabled={actionLoading === client.id}
                  >
                    <Edit size={16} />
                    Editar
                  </button>
                  <button
                    className={`client-admin__toggle-btn ${client.isBlocked ? "unblock" : "block"}`}
                    onClick={() => handleToggleBlockClient(client)}
                    disabled={actionLoading === client.id}
                  >
                    {actionLoading === client.id ? (
                      <div className="client-admin__button-spinner"></div>
                    ) : client.isBlocked ? (
                      <Check size={16} />
                    ) : (
                      <Ban size={16} />
                    )}
                    {client.isBlocked ? "Desbloquear" : "Bloquear"}
                  </button>
                </div>
              </div>
            ))}
          </div>

          {clients.length === 0 && !loading && (
            <div className="client-admin__empty">
              <p>No se encontraron clientes</p>
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
