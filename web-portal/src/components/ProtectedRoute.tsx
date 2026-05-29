import { Navigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import type { UserRole } from '../types';

export function ProtectedRoute({
  children,
  roles,
}: {
  children: React.ReactNode;
  roles: UserRole[];
}) {
  const { profile, loading } = useAuth();

  if (loading) {
    return <div className="center-page">Loading…</div>;
  }
  if (!profile) {
    return <Navigate to="/login" replace />;
  }
  if (!roles.includes(profile.role)) {
    return <Navigate to="/login" replace />;
  }
  return <>{children}</>;
}
