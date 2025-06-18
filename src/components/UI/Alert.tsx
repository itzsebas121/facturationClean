import { useState, useEffect } from "react"
import { X, CheckCircle, AlertCircle, Info, AlertTriangle } from "lucide-react"
import "./Alert.css"

interface AlertProps {
  type: "success" | "error" | "info" | "warning"
  message: string
  onClose?: () => void
  autoClose?: boolean
  duration?: number
}

export function Alert({ type, message, onClose, autoClose = true, duration = 5000 }: AlertProps) {
  const [isVisible, setIsVisible] = useState(true)

  useEffect(() => {
    if (autoClose) {
      const timer = setTimeout(() => {
        setIsVisible(false)
        setTimeout(() => onClose?.(), 300)
      }, duration)

      return () => clearTimeout(timer)
    }
  }, [autoClose, duration, onClose])

  const getIcon = () => {
    switch (type) {
      case "success":
        return <CheckCircle size={20} />
      case "error":
        return <AlertCircle size={20} />
      case "warning":
        return <AlertTriangle size={20} />
      case "info":
        return <Info size={20} />
      default:
        return <Info size={20} />
    }
  }

  const handleClose = () => {
    setIsVisible(false)
    setTimeout(() => onClose?.(), 300)
  }

  return (
    <div className={`alert alert-${type} ${isVisible ? "alert-visible" : "alert-hidden"}`}>
      <div className="alert-content">
        <div className="alert-icon">{getIcon()}</div>
        <div className="alert-message">{message}</div>
        {onClose && (
          <button className="alert-close" onClick={handleClose}>
            <X size={18} />
          </button>
        )}
      </div>
    </div>
  )
}
