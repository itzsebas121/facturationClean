import { loginService } from '../../api/services/userService';
import React, { useState, useEffect } from 'react';
import { useAuth } from '../../auth/AuthContext';
import {jwtDecode} from 'jwt-decode';
import { useNavigate } from 'react-router-dom';

export function LoginPage() {
  const { login, user, loading} = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
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
    }
  };
  if (loading) {
    return <div>Cargando...</div>;
  }
  return (
    <form onSubmit={handleSubmit}>
      <input type="email" placeholder="Email" value={email} onChange={e => setEmail(e.target.value)} required />
      <input type="password" placeholder="Password" value={password} onChange={e => setPassword(e.target.value)} required />
      <button type="submit">Entrar</button>
      {error && <p style={{ color: 'red' }}>{error}</p>}
    </form>
  );
}
