import { loginService } from '../../api/services/userService';
import React, { useState, useEffect } from 'react';
import { useAuth } from '../../auth/AuthContext';
import { jwtDecode } from 'jwt-decode';
import { useNavigate } from 'react-router-dom';
import { Mail, Lock, Eye, EyeOff, AlertCircle } from 'lucide-react';
import './Login.css';

export function LoginPage() {
  const [submitting, setSubmitting] = useState(false);
  const { login, user, loading } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [showPassword, setShowPassword] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    if (user) {
      if (user.rol === 'Admin') navigate('/admin', { replace: true });
      else if (user.rol === 'Client') navigate('/client', { replace: true });
      else setError('Rol no reconocido');
    }
  }, [user, navigate]);

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setError(null);
    setSubmitting(true);
    try {
      const { token } = await loginService({ email, password });
      if (token.Message) {
        setError(token.Message || 'Error al iniciar sesión');
        return;
      }

      login(token);
      const decoded: any = jwtDecode(token);
      const role = decoded.role;

      if (role === 'Admin') {
        navigate('/admin');
      } else if (role === 'Client') {
        navigate('/client');
      } else {
        setError('Rol no reconocido');
      }
    } catch (err: any) {
      setError(err.message || 'Error inesperado');
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) {
    return (
      <div className="loading-container">
        <div className="loader"></div>
        <p>Cargando...</p>
      </div>
    );
  }

  return (
    <div className="login-container">
      <div className="login-card">
        <div className="login-header">
          <h1>Iniciar Sesión</h1>
          <p>Accede a tu cuenta para continuar</p>
        </div>

        <form className="login-form" onSubmit={handleSubmit}>
          <div className="form-group">
            <label htmlFor="email">Correo Electrónico</label>
            <div className="input-container">
              <Mail className="input-icon" size={18} />
              <input
                id="email"
                type="email"
                placeholder="correo@ejemplo.com"
                value={email}
                onChange={e => setEmail(e.target.value)}
                required
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
                onChange={e => setPassword(e.target.value)}
                required
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

          {error && (
            <div className="error-message">
              <AlertCircle size={18} />
              <p>{error}</p>
            </div>
          )}

          <button
            type="submit"
            className={`login-button ${submitting ? 'submitting' : ''}`}
            disabled={submitting}
          >
            {submitting ? (
              <>
                <span className="button-loader"></span>
              </>
            ) : 'Ingresar'}
          </button>
        </form>

        <div className="login-footer">
          <a href="#" className="forgot-password">¿Olvidaste tu contraseña?</a>
        </div>
      </div>
    </div>
  );
}