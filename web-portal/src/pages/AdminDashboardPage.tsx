import { useCallback, useEffect, useState } from 'react';
import { AppShell } from '../components/AppShell';
import {
  fetchApplications,
  fetchOffices,
  fetchReports,
  updateApplicationStatus,
} from '../services/dataService';
import type { Application, Office, Report } from '../types';

const STATUSES = ['pending', 'in_progress', 'approved', 'rejected'];

export function AdminDashboardPage() {
  const [tab, setTab] = useState<'overview' | 'applications' | 'offices'>('overview');
  const [applications, setApplications] = useState<Application[]>([]);
  const [reports, setReports] = useState<Report[]>([]);
  const [offices, setOffices] = useState<Office[]>([]);
  const [statusFilter, setStatusFilter] = useState<string>('');
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

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

  const filtered = statusFilter
    ? applications.filter((a) => a.status === statusFilter)
    : applications;

  const counts = {
    total: applications.length,
    pending: applications.filter((a) => a.status === 'pending').length,
    approved: applications.filter((a) => a.status === 'approved').length,
    offices: offices.length,
    reports: reports.length,
  };

  async function onStatusChange(appId: string, status: string) {
    await updateApplicationStatus(appId, status);
    await load();
  }

  return (
    <AppShell
      title="National admin dashboard"
      subtitle="Full system view · same Firestore data as mobile clients & staff"
      onRefresh={load}
    >
      <div className="tabs">
        {(['overview', 'applications', 'offices'] as const).map((t) => (
          <button
            key={t}
            type="button"
            className={tab === t ? 'tab active' : 'tab'}
            onClick={() => setTab(t)}
          >
            {t.charAt(0).toUpperCase() + t.slice(1)}
          </button>
        ))}
      </div>

      {loading && <p className="muted">Loading…</p>}
      {error && <p className="error">{error}</p>}

      {!loading && tab === 'overview' && (
        <div className="stats-grid">
          <div className="stat-card">
            <span>Applications</span>
            <strong>{counts.total}</strong>
          </div>
          <div className="stat-card">
            <span>Pending</span>
            <strong>{counts.pending}</strong>
          </div>
          <div className="stat-card">
            <span>Approved</span>
            <strong>{counts.approved}</strong>
          </div>
          <div className="stat-card">
            <span>Offices</span>
            <strong>{counts.offices}</strong>
          </div>
          <div className="stat-card">
            <span>Staff reports</span>
            <strong>{counts.reports}</strong>
          </div>
        </div>
      )}

      {!loading && tab === 'applications' && (
        <>
          <div className="toolbar">
            <label>
              Filter status
              <select value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)}>
                <option value="">All</option>
                {STATUSES.map((s) => (
                  <option key={s} value={s}>
                    {s}
                  </option>
                ))}
              </select>
            </label>
          </div>
          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Office</th>
                  <th>Service</th>
                  <th>Status</th>
                  <th>Submitted</th>
                  <th>Update</th>
                </tr>
              </thead>
              <tbody>
                {filtered.map((a) => (
                  <tr key={a.id}>
                    <td className="mono">{a.id.slice(0, 8)}…</td>
                    <td>{a.officeId || '—'}</td>
                    <td>{a.serviceType}</td>
                    <td>
                      <span className={`badge ${a.status}`}>{a.status}</span>
                    </td>
                    <td>{a.submittedAt.toLocaleDateString()}</td>
                    <td>
                      <select
                        value={a.status}
                        onChange={(e) => onStatusChange(a.id, e.target.value)}
                      >
                        {STATUSES.map((s) => (
                          <option key={s} value={s}>
                            {s}
                          </option>
                        ))}
                      </select>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </>
      )}

      {!loading && tab === 'offices' && (
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Name</th>
                <th>Region</th>
                <th>Active</th>
                <th>ID</th>
              </tr>
            </thead>
            <tbody>
              {offices.map((o) => (
                <tr key={o.id}>
                  <td>{o.name}</td>
                  <td>{o.region ?? '—'}</td>
                  <td>{o.active ? 'Yes' : 'No'}</td>
                  <td className="mono">{o.id}</td>
                </tr>
              ))}
            </tbody>
          </table>
          {offices.length === 0 && (
            <p className="muted">No offices yet. Create offices from the mobile admin app.</p>
          )}
        </div>
      )}
    </AppShell>
  );
}
