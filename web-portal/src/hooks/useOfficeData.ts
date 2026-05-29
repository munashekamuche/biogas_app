import { useCallback, useEffect, useState } from 'react';
import {
  fetchApplications,
  fetchClientsByOffice,
  fetchOffices,
  fetchReports,
} from '../services/dataService';
import type { Application, AppUser, Office, Report } from '../types';

export function useOfficeData(officeId: string) {
  const [applications, setApplications] = useState<Application[]>([]);
  const [reports, setReports] = useState<Report[]>([]);
  const [clients, setClients] = useState<AppUser[]>([]);
  const [office, setOffice] = useState<Office | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    if (!officeId) {
      setError('No office assigned to your account.');
      setLoading(false);
      return;
    }
    setLoading(true);
    setError(null);
    try {
      const [apps, reps, cls, offices] = await Promise.all([
        fetchApplications(officeId),
        fetchReports(officeId),
        fetchClientsByOffice(officeId),
        fetchOffices(),
      ]);
      setApplications(apps);
      setReports(reps);
      setClients(cls);
      setOffice(offices.find((o) => o.id === officeId) ?? null);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load data');
    } finally {
      setLoading(false);
    }
  }, [officeId]);

  useEffect(() => {
    load();
  }, [load]);

  return { applications, reports, clients, office, loading, error, refresh: load };
}
