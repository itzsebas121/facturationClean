import { createContext, useContext, useState } from 'react';
import { User } from '../types/User';
import { adaptarUsuario } from '../adapters/userAdapter';
import { jwtDecode } from 'jwt-decode';

interface AuthContextType {
  user: User | null;
  token: string | null;
  login: (token: string) => void;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider = ({ children }: { children: React.ReactNode }) => {
  const [user, setUser] = useState<User | null>(null);
  const [token, setToken] = useState<string | null>(null);

  const login = (newToken: string) => {
    const decodedToken: { user: User } = jwtDecode(newToken);
    const rawUser = decodedToken;
    const adaptedUser = adaptarUsuario(rawUser);
    console.log('Raw User:', adaptedUser);
    localStorage.setItem('token', newToken);
    setUser(adaptedUser);
    setToken(newToken);
  };

  const logout = () => {
    localStorage.removeItem('token');
    setUser(null);
    setToken(null);
  };

  return (
    <AuthContext.Provider value={{ user, token, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
};

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth debe usarse dentro de AuthProvider');
  return context;
}
