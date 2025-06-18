"use client"

import type { Client } from "../../types/User"
import { User, Mail, Phone, MapPin, CreditCard, Edit3 } from "lucide-react"
import "./ClientDisplay.css"

interface ClientDisplayProps {
  client: Client
  onEdit: () => void
}

export default function ClientDisplay({ client, onEdit }: ClientDisplayProps) {
  return (
    <div className="client-display">
      <div className="client-header">
        <div className="client-title">
          <User className="title-icon" size={20} />
          <h3>Cliente Seleccionado</h3>
        </div>
        <button className="edit-client-btn" onClick={onEdit} title="Cambiar cliente">
          <Edit3 size={16} />
          Cambiar
        </button>
      </div>

      <div className="client-details-grid">
        <div className="detail-card">
          <div className="detail-header">
            <User className="detail-icon" size={16} />
            <span className="detail-label">Nombre</span>
          </div>
          <span className="detail-value">{client.nombre}</span>
        </div>

        <div className="detail-card">
          <div className="detail-header">
            <Mail className="detail-icon" size={16} />
            <span className="detail-label">Email</span>
          </div>
          <span className="detail-value">{client.email}</span>
        </div>

        <div className="detail-card">
          <div className="detail-header">
            <Phone className="detail-icon" size={16} />
            <span className="detail-label">Teléfono</span>
          </div>
          <span className="detail-value">{client.telefono}</span>
        </div>

        <div className="detail-card">
          <div className="detail-header">
            <CreditCard className="detail-icon" size={16} />
            <span className="detail-label">Cédula</span>
          </div>
          <span className="detail-value">{client.cedula}</span>
        </div>

        <div className="detail-card address-card">
          <div className="detail-header">
            <MapPin className="detail-icon" size={16} />
            <span className="detail-label">Dirección</span>
          </div>
          <span className="detail-value">{client.direccion}</span>
        </div>
      </div>
    </div>
  )
}
