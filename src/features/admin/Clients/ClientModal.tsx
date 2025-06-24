"use client"

import type React from "react"
import { useState, useEffect } from "react"
import { X, Save } from "lucide-react"
import type { Client } from "../../../types/User"
import "./ClientModal.css"

interface ClientModalProps {
  client: Client | null
  isOpen: boolean
  onClose: () => void
  onSave: (client: Omit<Client, "id"> | Client) => void
  isCreating: boolean
  loading: boolean
}

export function ClientModal({ client, isOpen, onClose, onSave, isCreating, loading }: ClientModalProps) {
  const [formData, setFormData] = useState({
    nombre: "",
    email: "",
    telefono: "",
    cedula: "",
    direccion: "",
    isBlocked: false,
  })

  const [errors, setErrors] = useState<Record<string, string>>({})

  useEffect(() => {
    if (client) {
      setFormData({
        nombre: client.nombre,
        email: client.email,
        telefono: client.telefono,
        cedula: client.cedula,
        direccion: client.direccion,
        isBlocked: client.isBlocked,
      })
    } else {
      setFormData({
        nombre: "",
        email: "",
        telefono: "",
        cedula: "",
        direccion: "",
        isBlocked: false,
      })
    }
    setErrors({})
  }, [client, isOpen])

  const validateForm = () => {
    const newErrors: Record<string, string> = {}

    if (!formData.nombre.trim()) {
      newErrors.nombre = "El nombre es requerido"
    }

    if (!formData.email.trim()) {
      newErrors.email = "El email es requerido"
    } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
      newErrors.email = "El email no es válido"
    }

    if (!formData.telefono.trim()) {
      newErrors.telefono = "El teléfono es requerido"
    }

    if (!formData.cedula.trim()) {
      newErrors.cedula = "La cédula es requerida"
    }

    if (!formData.direccion.trim()) {
      newErrors.direccion = "La dirección es requerida"
    }

    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()

    if (!validateForm()) {
      return
    }

    const clientData = {
      ...formData,
      rol: "Client" as const,
    }

    if (isCreating) {
      onSave(clientData)
    } else {
      onSave({ ...clientData, id: client!.id })
    }
  }

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value, type } = e.target
    setFormData((prev) => ({
      ...prev,
      [name]: type === "checkbox" ? (e.target as HTMLInputElement).checked : value,
    }))

    // Clear error when user starts typing
    if (errors[name]) {
      setErrors((prev) => ({ ...prev, [name]: "" }))
    }
  }

  if (!isOpen) return null

  return (
    <div className="client-modal__overlay" onClick={onClose}>
      <div className="client-modal__content" onClick={(e) => e.stopPropagation()}>
        <div className="client-modal__header">
          <h2 className="client-modal__title">{isCreating ? "Crear Cliente" : "Editar Cliente"}</h2>
          <button className="client-modal__close-btn" onClick={onClose} disabled={loading}>
            <X size={24} />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="client-modal__form">
          <div className="client-modal__form-grid">
            <div className="client-modal__form-group">
              <label htmlFor="nombre" className="client-modal__label">
                Nombre *
              </label>
              <input
                type="text"
                id="nombre"
                name="nombre"
                value={formData.nombre}
                onChange={handleInputChange}
                className={`client-modal__input ${errors.nombre ? "error" : ""}`}
                disabled={loading}
              />
              {errors.nombre && <span className="client-modal__error">{errors.nombre}</span>}
            </div>

            <div className="client-modal__form-group">
              <label htmlFor="email" className="client-modal__label">
                Email *
              </label>
              <input
                type="email"
                id="email"
                name="email"
                value={formData.email}
                onChange={handleInputChange}
                className={`client-modal__input ${errors.email ? "error" : ""}`}
                disabled={loading}
              />
              {errors.email && <span className="client-modal__error">{errors.email}</span>}
            </div>

            <div className="client-modal__form-group">
              <label htmlFor="telefono" className="client-modal__label">
                Teléfono *
              </label>
              <input
                type="tel"
                id="telefono"
                name="telefono"
                value={formData.telefono}
                onChange={handleInputChange}
                className={`client-modal__input ${errors.telefono ? "error" : ""}`}
                disabled={loading}
              />
              {errors.telefono && <span className="client-modal__error">{errors.telefono}</span>}
            </div>

            <div className="client-modal__form-group">
              <label htmlFor="cedula" className="client-modal__label">
                Cédula *
              </label>
              <input
                type="text"
                id="cedula"
                name="cedula"
                value={formData.cedula}
                onChange={handleInputChange}
                className={`client-modal__input ${errors.cedula ? "error" : ""}`}
                disabled={loading}
              />
              {errors.cedula && <span className="client-modal__error">{errors.cedula}</span>}
            </div>
          </div>

          <div className="client-modal__form-group">
            <label htmlFor="direccion" className="client-modal__label">
              Dirección *
            </label>
            <textarea
              id="direccion"
              name="direccion"
              value={formData.direccion}
              onChange={handleInputChange}
              className={`client-modal__textarea ${errors.direccion ? "error" : ""}`}
              rows={3}
              disabled={loading}
            />
            {errors.direccion && <span className="client-modal__error">{errors.direccion}</span>}
          </div>

          {!isCreating && (
            <div className="client-modal__form-group">
              <label className="client-modal__checkbox-label">
                <input
                  type="checkbox"
                  name="isBlocked"
                  checked={formData.isBlocked}
                  onChange={handleInputChange}
                  className="client-modal__checkbox"
                  disabled={loading}
                />
                Cliente bloqueado
              </label>
            </div>
          )}

          <div className="client-modal__actions">
            <button type="button" onClick={onClose} className="client-modal__cancel-btn" disabled={loading}>
              Cancelar
            </button>
            <button type="submit" className="client-modal__save-btn" disabled={loading}>
              {loading ? <div className="client-modal__button-spinner"></div> : <Save size={20} />}
              {isCreating ? "Crear" : "Guardar"}
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}
