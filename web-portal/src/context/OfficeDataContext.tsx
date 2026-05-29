import { createContext, useContext, type ReactNode } from 'react';
import { useOfficeData } from '../hooks/useOfficeData';
import type { Application, AppUser, Office, Report } from '../types';

type OfficeDataContextValue = ReturnType<typeof useOfficeData>;

const OfficeDataContext = createContext<OfficeDataContextValue | null>(null);

export function OfficeDataProvider({
  officeId,
  children,
}: {
  officeId: string;
  children: ReactNode;
}) {
  const value = useOfficeData(officeId);
  return <OfficeDataContext.Provider value={value}>{children}</OfficeDataContext.Provider>;
}

export function useOfficeDataContext() {
  const ctx = useContext(OfficeDataContext);
  if (!ctx) throw new Error('useOfficeDataContext must be used within OfficeDataProvider');
  return ctx;
}

export type { Application, AppUser, Office, Report };
