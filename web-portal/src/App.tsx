import { BrowserRouter, Route, Routes } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import { ProtectedRoute } from './components/ProtectedRoute';
import { LandingPage } from './pages/LandingPage';
import { LoginPage } from './pages/LoginPage';
import { NotFoundPage } from './pages/NotFoundPage';
import { ProfilePage } from './pages/ProfilePage';
import { OfficeLayout } from './pages/office/OfficeLayout';
import { OfficeOverviewPage } from './pages/office/OfficeOverviewPage';
import { OfficeApplicationsPage } from './pages/office/OfficeApplicationsPage';
import { OfficeReportsPage } from './pages/office/OfficeReportsPage';
import { OfficeClientsPage } from './pages/office/OfficeClientsPage';
import { AdminLayout } from './pages/admin/AdminLayout';
import { AdminOverviewPage } from './pages/admin/AdminOverviewPage';
import { AdminApplicationsPage } from './pages/admin/AdminApplicationsPage';
import { AdminReportsPage } from './pages/admin/AdminReportsPage';
import { AdminOfficesPage } from './pages/admin/AdminOfficesPage';

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<LandingPage />} />
          <Route path="/login" element={<LoginPage />} />

          <Route
            path="/office"
            element={
              <ProtectedRoute roles={['office']}>
                <OfficeLayout />
              </ProtectedRoute>
            }
          >
            <Route index element={<OfficeOverviewPage />} />
            <Route path="applications" element={<OfficeApplicationsPage />} />
            <Route path="reports" element={<OfficeReportsPage />} />
            <Route path="clients" element={<OfficeClientsPage />} />
            <Route path="profile" element={<ProfilePage />} />
          </Route>

          <Route
            path="/admin"
            element={
              <ProtectedRoute roles={['admin']}>
                <AdminLayout />
              </ProtectedRoute>
            }
          >
            <Route index element={<AdminOverviewPage />} />
            <Route path="applications" element={<AdminApplicationsPage />} />
            <Route path="reports" element={<AdminReportsPage />} />
            <Route path="offices" element={<AdminOfficesPage />} />
            <Route path="profile" element={<ProfilePage />} />
          </Route>

          <Route path="*" element={<NotFoundPage />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}
