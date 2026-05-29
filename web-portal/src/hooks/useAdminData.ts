import { useCallback, useEffect, useState } from 'react';
import {
  fetchApplications,
  fetchOffices,
  fetchReports,
} from '../services/dataService';
import type { Application, Office, Report } from '../types';

export function useAdminData() {
  const [applications, setApplications] = useState<Application[]>([]);
  const [reports, setReports] = useState<Report[]>([]);
  const [offices, setOffices] = useState<Office[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const [apps, reps, offs] = await Promise.all([
        fetchApplications(),
        fetchReports(),
        fetchOffices(),
      ]);
      setApplications(apps);
      setReports(reps);
      setOffices(offs);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load data');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  return { applications, reports, offices, loading, error, refresh: load };
}
