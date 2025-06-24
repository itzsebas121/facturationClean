import { loginService } from "../../api/services/userService"
import type React from "react"
import { useState, useEffect } from "react"
import { useAuth } from "../../auth/AuthContext"
import { jwtDecode } from "jwt-decode"
import { useNavigate, Link } from "react-router-dom"
import { Mail, Lock, Eye, EyeOff, LogIn, UserPlus, KeyRound } from 'lucide-react'
import { Alert } from "../../components/UI/Alert"
import "./Login.css"

interface AlertState {
  show: boolean
  type: "success" | "error" | "info" | "warning"
  message: string
}

export function LoginPage() {
  const [submitting, setSubmitting] = useState(false)
  const { login, user, loading } = useAuth()
  const [email, setEmail] = useState("")
  const [password, setPassword] = useState("")
  const [alert, setAlert] = useState<AlertState>({ show: false, type: "info", message: "" })
  const [showPassword, setShowPassword] = useState(false)
  const navigate = useNavigate()

  const showAlert = (type: AlertState["type"], message: string) => {
    setAlert({ show: true, type, message })
  }

  const hideAlert = () => {
    setAlert({ show: false, type: "info", message: "" })
  }

  useEffect(() => {
    if (user) {
      if (user.rol === "Admin") navigate("/admin", { replace: true })
      else if (user.rol === "Client") navigate("/client", { replace: true })
      else showAlert("error", "Rol no reconocido")
    }
  }, [user, navigate])

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    hideAlert()
    setSubmitting(true)

    try {
      const { token } = await loginService({ email, password })
      if (token.Message) {
        showAlert("error", token.Message || "Error al iniciar sesión")
        return
      }

      login(token)
      const decoded: any = jwtDecode(token)
      const role = decoded.role

      if (role === "Admin") {
        navigate("/admin")
      } else if (role === "Client") {
        navigate("/client")
      } else {
        showAlert("error", "Rol no reconocido")
      }
    } catch (err: any) {
      showAlert("error", err.message || "Error inesperado")
    } finally {
      setSubmitting(false)
    }
  }

  if (loading) {
    return (
      <div className="auth-loading">
        <div className="auth-spinner"></div>
        <p>Cargando...</p>
      </div>
    )
  }

  return (
    <div className="auth-container">
      {alert.show && <Alert type={alert.type} message={alert.message} onClose={hideAlert} />}

      <div className="auth-card animate-slide-up">
        <div className="auth-header">
          <div className="auth-logo">
            <LogIn size={32} />
          </div>
          <h1>Iniciar Sesión</h1>
          <p>Accede a tu cuenta para continuar</p>
        </div>

        <form className="auth-form" onSubmit={handleSubmit}>
          <div className="form-group">
            <label htmlFor="email">Correo Electrónico</label>
            <div className="input-container">
              <Mail className="input-icon" size={18} />
              <input
                id="email"
                type="email"
                placeholder="correo@ejemplo.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                className="animate-focus"
              />
            </div>
          </div>

          <div className="form-group">
            <label htmlFor="password">Contraseña</label>
            <div className="input-container">
              <Lock className="input-icon" size={18} />
              <input
                id="password"
                type={showPassword ? "text" : "password"}
                placeholder="Contraseña"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                className="animate-focus"
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
          </div>

          <button type="submit" className={`auth-button primary ${submitting ? "loading" : ""}`} disabled={submitting}>
            {submitting ? (
              <>
                <span className="button-spinner"></span>
                Ingresando...
              </>
            ) : (
              <>
                <LogIn size={18} />
                Ingresar
              </>
            )}
          </button>
        </form>

        <div className="auth-divider">
          <span>o</span>
        </div>

        <div className="auth-actions">
          <Link to="/recovery" className="auth-button secondary">
            <KeyRound size={18} />
            ¿Olvidaste tu contraseña?
          </Link>
          <Link to="/register" className="auth-button outline">
            <UserPlus size={18} />
            Crear cuenta nueva
          </Link>
        </div>
      </div>
    </div>
  )
}
