import { createContext, useContext, type ReactNode } from 'react';
import { useAdminData } from '../hooks/useAdminData';

type AdminDataContextValue = ReturnType<typeof useAdminData>;

const AdminDataContext = createContext<AdminDataContextValue | null>(null);

export function AdminDataProvider({ children }: { children: ReactNode }) {
  const value = useAdminData();
  return <AdminDataContext.Provider value={value}>{children}</AdminDataContext.Provider>;
}

export function useAdminDataContext() {
  const ctx = useContext(AdminDataContext);
  if (!ctx) throw new Error('useAdminDataContext must be used within AdminDataProvider');
  return ctx;
}
