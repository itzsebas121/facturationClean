"use client"

import { AlertTriangle, X } from "lucide-react"
import "./ConfirmDialog.css"

interface ConfirmDialogProps {
  isOpen: boolean
  title: string
  message: string
  confirmText?: string
  cancelText?: string
  onConfirm: () => void
  onCancel: () => void
  type?: "danger" | "warning" | "info"
}

export function ConfirmDialog({
  isOpen,
  title,
  message,
  confirmText = "Confirmar",
  cancelText = "Cancelar",
  onConfirm,
  onCancel,
  type = "warning",
}: ConfirmDialogProps) {
  if (!isOpen) return null

  return (
    <div className="confirm-overlay">
      <div className={`confirm-dialog confirm-${type}`}>
        <div className="confirm-header">
          <div className="confirm-icon">
            <AlertTriangle size={24} />
          </div>
          <h3 className="confirm-title">{title}</h3>
          <button className="confirm-close" onClick={onCancel}>
            <X size={20} />
          </button>
        </div>

        <div className="confirm-content">
          <p className="confirm-message">{message}</p>
        </div>

        <div className="confirm-actions">
          <button className="confirm-btn confirm-cancel" onClick={onCancel}>
            {cancelText}
          </button>
          <button className={`confirm-btn confirm-${type}`} onClick={onConfirm}>
            {confirmText}
          </button>
        </div>
      </div>
    </div>
  )
}
