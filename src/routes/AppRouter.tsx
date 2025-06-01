import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { useAuth } from '../auth/AuthContext';
import { LoginPage } from '../features/login/LoginPage';
import { AdminDashboard } from '../features/admin/AdminDashboard';
import { ClientDashboard } from '../features/client/ClientDashboard';

function PrivateRoute({ children, allowedRoles }: { children: React.ReactNode; allowedRoles: string[] }) {
  const { user, loading } = useAuth();

  if (loading) return <div>Cargando...</div>;

  if (!user) return <Navigate to="/login" replace />;

  if (!allowedRoles.some(role => role === user.rol)) return <Navigate to="/" replace />;

  return <>{children}</>;
}
export default function AppRouter() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<LoginPage />} />

        <Route
          path="/admin/*"
          element={
            <PrivateRoute allowedRoles={['Admin']}>
              <AdminDashboard />
            </PrivateRoute>
          }
        />

        <Route
          path="/client/*"
          element={
            <PrivateRoute allowedRoles={['Client']}>
              <ClientDashboard />
            </PrivateRoute>
          }
        />

        <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
    </BrowserRouter>
  );
}
