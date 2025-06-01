import React, { createContext, useContext, useState, useEffect } from 'react';
import { User } from '../types/User';
import { adaptarUsuario } from '../adapters/userAdapter';
import {jwtDecode} from 'jwt-decode';

interface AuthContextType {
  user: User | null;
  token: string | null;
  login: (token: string) => void;
  logout: () => void;
  loading: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider = ({ children }: { children: React.ReactNode }) => {
  const [user, setUser] = useState<User | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const savedToken = localStorage.getItem('token');
    if (savedToken) {
      try {
        const decoded = jwtDecode(savedToken);
        const adaptedUser = adaptarUsuario(decoded);
        setUser(adaptedUser);
        setToken(savedToken);
      } catch (err) {
        console.error('Token inválido o expirado');
        logout();
      }
    }
    setLoading(false);
  }, []);

  const login = (newToken: string) => {
    try {
      const decoded = jwtDecode(newToken);
      const adaptedUser = adaptarUsuario(decoded);
      localStorage.setItem('token', newToken);
      setUser(adaptedUser);
      setToken(newToken);
    } catch {
      console.error('Token inválido al hacer login');
    }
  };

  const logout = () => {
    localStorage.removeItem('token');
    setUser(null);
    setToken(null);
  };

  return (
    <AuthContext.Provider value={{ user, token, login, logout, loading }}>
      {children}
    </AuthContext.Provider>
  );
};

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth debe usarse dentro de AuthProvider');
  return context;
}
