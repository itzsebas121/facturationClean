import { registerService } from "../../api/services/userService"
import type React from "react"
import { useState } from "react"
import { Link } from "react-router-dom"
import {
  User,
  Mail,
  Lock,
  Eye,
  EyeOff,
  Phone,
  MapPin,
  CreditCard,
  CheckCircle,
  ArrowLeft,
  UserPlus,
  KeyRound,
} from "lucide-react"
import { Alert } from "../../components/UI/Alert"
import "./Login.css"

interface AlertState {
  show: boolean
  type: "success" | "error" | "info" | "warning"
  message: string
}

interface FormData {
  firstName: string
  lastName: string
  email: string
  cedula: string
  phone: string
  address: string
  password: string
  confirmPassword: string
}

interface FormErrors {
  [key: string]: string
}

export function Register() {
  const [submitting, setSubmitting] = useState(false)
  const [showPassword, setShowPassword] = useState(false)
  const [showConfirmPassword, setShowConfirmPassword] = useState(false)
  const [alert, setAlert] = useState<AlertState>({ show: false, type: "info", message: "" })
  const [isSuccess, setIsSuccess] = useState(false)
  const [formData, setFormData] = useState<FormData>({
    firstName: "",
    lastName: "",
    email: "",
    cedula: "",
    phone: "",
    address: "",
    password: "",
    confirmPassword: "",
  })
  const [errors, setErrors] = useState<FormErrors>({})

  const showAlert = (type: AlertState["type"], message: string) => {
    setAlert({ show: true, type, message })
  }

  const hideAlert = () => {
    setAlert({ show: false, type: "info", message: "" })
  }

  const validateCedula = (cedula: string): boolean => {
    const cedulaRegex = /^\d{10}$/
    return cedulaRegex.test(cedula)
  }
  const validatePhone = (phone: string): boolean => {
    const phoneRegex = /^09\d{8}$/
    return phoneRegex.test(phone)
  }

  const validateForm = (): boolean => {
    const newErrors: FormErrors = {}

    if (!formData.firstName.trim()) newErrors.firstName = "El nombre es requerido"
    if (!formData.lastName.trim()) newErrors.lastName = "El apellido es requerido"
    if (!formData.email.trim()) newErrors.email = "El correo es requerido"
    if (!formData.cedula.trim()) newErrors.cedula = "La cédula es requerida"
    if (!formData.password) newErrors.password = "La contraseña es requerida"
    if (!formData.confirmPassword) newErrors.confirmPassword = "Confirma tu contraseña"

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (formData.email && !emailRegex.test(formData.email)) {
      newErrors.email = "Correo electrónico inválido"
    }

    if (formData.cedula && !validateCedula(formData.cedula)) {
      newErrors.cedula = "La cédula debe tener 10 dígitos numéricos"
    }

    if (formData.phone && !validatePhone(formData.phone)) {
      newErrors.phone = "El teléfono debe empezar con 09 y tener 10 dígitos"
    }

    if (formData.password && formData.password.length < 6) {
      newErrors.password = "La contraseña debe tener al menos 6 caracteres"
    }
    if (formData.password !== formData.confirmPassword) {
      newErrors.confirmPassword = "Las contraseñas no coinciden"
    }
    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target
    if (name === "cedula" || name === "phone") {
      const numericValue = value.replace(/\D/g, "")
      setFormData((prev) => ({ ...prev, [name]: numericValue }))
    } else {
      setFormData((prev) => ({ ...prev, [name]: value }))
    }
    if (errors[name]) {
      setErrors((prev) => ({ ...prev, [name]: "" }))
    }
  }

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    hideAlert()

    if (!validateForm()) {
      showAlert("error", "Por favor corrige los errores en el formulario")
      return
    }

    setSubmitting(true)

    try {
      const clientData = {
        firstName: formData.firstName.trim(),
        lastName: formData.lastName.trim(),
        email: formData.email.trim(),
        cedula: formData.cedula,
        phone: formData.phone || null,
        address: formData.address.trim() || null,
        password: formData.password,
      }

      const response = await registerService(clientData)
      
      if (response.error || response.Error || response.ERROR) {
        showAlert("error", response.error || response.Error || response.ERROR|| "Error al crear la cuenta")
      } else if (response.message || response.Message) {
        showAlert("success", response.message || response.Message )
        setIsSuccess(true)
      } else {
        showAlert("error", "Respuesta inesperada del servidor")
      }
    } catch (err: any) {
      showAlert("error", err.message || "Error inesperado al crear la cuenta")
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <div className="auth-container">
      {alert.show && <Alert type={alert.type} message={alert.message} onClose={hideAlert} />}

      <div className="auth-card large animate-slide-up">
        <div className="auth-header">
          <div className="auth-logo">
            <UserPlus size={32} />
          </div>
          <h1>Crear Cuenta</h1>
          <p>{isSuccess ? "¡Bienvenido! Tu cuenta ha sido creada" : "Completa tus datos para registrarte"}</p>
        </div>

        {!isSuccess ? (
          <form className="auth-form" onSubmit={handleSubmit}>
            <div className="form-grid">
              <div className="form-group">
                <label htmlFor="firstName">Nombre *</label>
                <div className="input-container">
                  <User className="input-icon" size={18} />
                  <input
                    id="firstName"
                    name="firstName"
                    type="text"
                    placeholder="Tu nombre"
                    value={formData.firstName}
                    onChange={handleInputChange}
                    required
                    className={`animate-focus ${errors.firstName ? "error" : ""}`}
                  />
                </div>
                {errors.firstName && <span className="field-error">{errors.firstName}</span>}
              </div>

              <div className="form-group">
                <label htmlFor="lastName">Apellido *</label>
                <div className="input-container">
                  <User className="input-icon" size={18} />
                  <input
                    id="lastName"
                    name="lastName"
                    type="text"
                    placeholder="Tu apellido"
                    value={formData.lastName}
                    onChange={handleInputChange}
                    required
                    className={`animate-focus ${errors.lastName ? "error" : ""}`}
                  />
                </div>
                {errors.lastName && <span className="field-error">{errors.lastName}</span>}
              </div>
            </div>

            <div className="form-group">
              <label htmlFor="email">Correo Electrónico *</label>
              <div className="input-container">
                <Mail className="input-icon" size={18} />
                <input
                  id="email"
                  name="email"
                  type="email"
                  placeholder="correo@ejemplo.com"
                  value={formData.email}
                  onChange={handleInputChange}
                  required
                  className={`animate-focus ${errors.email ? "error" : ""}`}
                />
              </div>
              {errors.email && <span className="field-error">{errors.email}</span>}
            </div>

            <div className="form-grid">
              <div className="form-group">
                <label htmlFor="cedula">Cédula *</label>
                <div className="input-container">
                  <CreditCard className="input-icon" size={18} />
                  <input
                    id="cedula"
                    name="cedula"
                    type="text"
                    placeholder="1234567890"
                    value={formData.cedula}
                    onChange={handleInputChange}
                    maxLength={10}
                    required
                    className={`animate-focus ${errors.cedula ? "error" : ""}`}
                  />
                </div>
                {errors.cedula && <span className="field-error">{errors.cedula}</span>}
              </div>

              <div className="form-group">
                <label htmlFor="phone">Teléfono</label>
                <div className="input-container">
                  <Phone className="input-icon" size={18} />
                  <input
                    id="phone"
                    name="phone"
                    type="text"
                    placeholder="0987654321"
                    value={formData.phone}
                    onChange={handleInputChange}
                    maxLength={10}
                    className={`animate-focus ${errors.phone ? "error" : ""}`}
                  />
                </div>
                {errors.phone && <span className="field-error">{errors.phone}</span>}
              </div>
            </div>

            <div className="form-group">
              <label htmlFor="address">Dirección</label>
              <div className="input-container">
                <MapPin className="input-icon" size={18} />
                <input
                  id="address"
                  name="address"
                  type="text"
                  placeholder="Tu dirección (opcional)"
                  value={formData.address}
                  onChange={handleInputChange}
                  className="animate-focus"
                />
              </div>
            </div>

            <div className="form-grid">
              <div className="form-group">
                <label htmlFor="password">Contraseña *</label>
                <div className="input-container">
                  <Lock className="input-icon" size={18} />
                  <input
                    id="password"
                    name="password"
                    type={showPassword ? "text" : "password"}
                    placeholder="Contraseña"
                    value={formData.password}
                    onChange={handleInputChange}
                    required
                    className={`animate-focus ${errors.password ? "error" : ""}`}
                  />
                  <button
                    type="button"
                    className="password-toggle"
                    onClick={() => setShowPassword(!showPassword)}
                    aria-label={showPassword ? "Ocultar contraseña" : "Mostrar contraseña"}
                  >
                    {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                  </button>
                </div>
                {errors.password && <span className="field-error">{errors.password}</span>}
              </div>

              <div className="form-group">
                <label htmlFor="confirmPassword">Confirmar *</label>
                <div className="input-container">
                  <Lock className="input-icon" size={18} />
                  <input
                    id="confirmPassword"
                    name="confirmPassword"
                    type={showConfirmPassword ? "text" : "password"}
                    placeholder="Confirmar contraseña"
                    value={formData.confirmPassword}
                    onChange={handleInputChange}
                    required
                    className={`animate-focus ${errors.confirmPassword ? "error" : ""}`}
                  />
                  <button
                    type="button"
                    className="password-toggle"
                    onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                    aria-label={showConfirmPassword ? "Ocultar contraseña" : "Mostrar contraseña"}
                  >
                    {showConfirmPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                  </button>
                </div>
                {errors.confirmPassword && <span className="field-error">{errors.confirmPassword}</span>}
              </div>
            </div>

            <button
              type="submit"
              className={`auth-button primary ${submitting ? "loading" : ""}`}
              disabled={submitting}
            >
              {submitting ? (
                <>
                  <span className="button-spinner"></span>
                  Creando cuenta...
                </>
              ) : (
                <>
                  <UserPlus size={18} />
                  Crear Cuenta
                </>
              )}
            </button>
          </form>
        ) : (
          <div className="auth-success animate-fade-in">
            <CheckCircle size={64} className="success-icon" />
            <h3>¡Cuenta Creada!</h3>
            <p>Tu cuenta ha sido creada exitosamente. Ya puedes iniciar sesión.</p>
          </div>
        )}

        <div className="auth-divider">
          <span>o</span>
        </div>

        <div className="auth-actions">
          <Link to="/auth/login" className="auth-button outline">
            <ArrowLeft size={18} />
            {isSuccess ? "Ir al inicio de sesión" : "Ya tengo cuenta"}
          </Link>
          {!isSuccess && (
            <Link to="/recovery" className="auth-button secondary">
              <KeyRound size={18} />
              ¿Olvidaste tu contraseña?
            </Link>
          )}
        </div>
      </div>
    </div>
  )
}
