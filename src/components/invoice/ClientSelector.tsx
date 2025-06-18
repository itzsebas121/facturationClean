"use client"

import { useState, useMemo } from "react"
import type { Client } from "../../types/User"
import { Search, X, User, Mail, Phone, MapPin, CreditCard } from "lucide-react"
import "./ClientSelector.css"

interface ClientSelectorProps {
  clients: Client[]
  selectedClient: Client | null
  onSelect: (client: Client) => void
  onClose: () => void
}

export default function ClientSelector({ clients, selectedClient, onSelect, onClose }: ClientSelectorProps) {
  const [searchTerm, setSearchTerm] = useState("")
  const [filterField, setFilterField] = useState<keyof Client | "all">("all")

  const filteredClients = useMemo(() => {
    if (!searchTerm) return clients

    return clients.filter((client) => {
      const searchLower = searchTerm.toLowerCase()

      if (filterField === "all") {
        return (
          client.nombre.toLowerCase().includes(searchLower) ||
          client.email.toLowerCase().includes(searchLower) ||
          client.telefono.includes(searchTerm) ||
          client.direccion.toLowerCase().includes(searchLower) ||
          client.cedula.includes(searchTerm)
        )
      }

      const fieldValue = client[filterField]
      return fieldValue?.toString().toLowerCase().includes(searchLower)
    })
  }, [clients, searchTerm, filterField])

  return (
    <div className="modal-overlay">
      <div className="client-selector-modal">
        <div className="modal-header">
          <h2>Seleccionar Cliente</h2>
          <button className="close-btn" onClick={onClose}>
            <X size={24} />
          </button>
        </div>

        <div className="search-section">
          <div className="search-input-container">
            <Search className="search-icon" size={20} />
            <input
              type="text"
              placeholder="Buscar cliente..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="search-input"
            />
          </div>

          <select
            value={filterField}
            onChange={(e) => setFilterField(e.target.value as keyof Client | "all")}
            className="filter-select"
          >
            <option value="all">Todos los campos</option>
            <option value="nombre">Nombre</option>
            <option value="email">Email</option>
            <option value="telefono">Teléfono</option>
            <option value="direccion">Dirección</option>
            <option value="cedula">Cédula</option>
          </select>
        </div>

        <div className="clients-list">
          {filteredClients.length === 0 ? (
            <div className="no-results">
              <p>No se encontraron clientes</p>
            </div>
          ) : (
            filteredClients.map((client) => (
              <div
                key={client.id}
                className={`client-card ${selectedClient?.id === client.id ? "selected" : ""} ${client.isBlocked ? "blocked" : ""}`}
                onClick={() => !client.isBlocked && onSelect(client)}
              >
                <div className="client-info">
                  <div className="client-name">
                    <User size={16} />
                    <span>{client.nombre}</span>
                    {client.isBlocked && <span className="blocked-badge">Bloqueado</span>}
                  </div>

                  <div className="client-details">
                    <div className="detail-item">
                      <Mail size={14} />
                      <span>{client.email}</span>
                    </div>

                    <div className="detail-item">
                      <Phone size={14} />
                      <span>{client.telefono}</span>
                    </div>

                    <div className="detail-item">
                      <MapPin size={14} />
                      <span>{client.direccion}</span>
                    </div>

                    <div className="detail-item">
                      <CreditCard size={14} />
                      <span>{client.cedula}</span>
                    </div>
                  </div>
                </div>

                {selectedClient?.id === client.id && <div className="selected-indicator">✓</div>}
              </div>
            ))
          )}
        </div>

        <div className="modal-footer">
          <p className="results-count">
            {filteredClients.length} cliente{filteredClients.length !== 1 ? "s" : ""} encontrado
            {filteredClients.length !== 1 ? "s" : ""}
          </p>
        </div>
      </div>
    </div>
  )
}
