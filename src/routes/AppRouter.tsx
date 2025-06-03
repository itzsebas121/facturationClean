import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { useAuth } from '../auth/AuthContext';
import { LoginPage } from '../features/login/LoginPage';
import { AdminDashboard } from '../features/admin/AdminDashboard';
import { ClientDashboard } from '../features/client/ClientDashboard';

import { HomeAdmin } from '../features/admin/HomeAdmin/HomeAdmin';

import { HomeClient } from '../features/client/Home/HomeClient';
import { HistoryClient } from '../features/client/History/HistoryClient';
import { ProductPageClient } from '../features/client/Products/ProductPageClient';

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
          path="/admin/*" element={<PrivateRoute allowedRoles={['Admin']}>
            <AdminDashboard />
          </PrivateRoute>
          }>
          <Route index element={<HomeAdmin />} />
          <Route path='home' element={<HomeAdmin />} />
        </Route>

        <Route
          path="/client/*"
          element={
            <PrivateRoute allowedRoles={['Client']}>
              <ClientDashboard />
            </PrivateRoute>
          }
        >
          <Route index element={<HomeClient />} />
          <Route path='home' element={<HomeClient />} />
          <Route path='history' element={<HistoryClient />} />
          <Route path='products' element={<ProductPageClient />} />
        </Route>
        <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
    </BrowserRouter>
  );
}
