import { useCallback, useEffect, useState } from 'react';
import { AppShell } from '../components/AppShell';
import { useAuth } from '../context/AuthContext';
import {
  fetchApplications,
  fetchClientsByOffice,
  fetchReports,
  updateApplicationStatus,
} from '../services/dataService';
import type { Application, AppUser, Report } from '../types';

const STATUSES = ['pending', 'in_progress', 'approved', 'rejected'];

export function OfficeDashboardPage() {
  const { profile } = useAuth();
  const officeId = profile?.officeId ?? '';
  const [tab, setTab] = useState<'applications' | 'reports' | 'clients'>('applications');
  const [applications, setApplications] = useState<Application[]>([]);
  const [reports, setReports] = useState<Report[]>([]);
  const [clients, setClients] = useState<AppUser[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    if (!officeId) {
      setError('No office assigned to your account.');
      setLoading(false);
      return;
    }
    setLoading(true);
    setError(null);
    try {
      const [apps, reps, cls] = await Promise.all([
        fetchApplications(officeId),
        fetchReports(officeId),
        fetchClientsByOffice(officeId),
      ]);
      setApplications(apps);
      setReports(reps);
      setClients(cls);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load data');
    } finally {
      setLoading(false);
    }
  }, [officeId]);

  useEffect(() => {
    load();
  }, [load]);

  async function onStatusChange(appId: string, status: string) {
    await updateApplicationStatus(appId, status);
    await load();
  }

  if (!officeId) {
    return (
      <AppShell title="Regional office portal">
        <p className="error">Your account has no office assigned. Contact national admin.</p>
      </AppShell>
    );
  }

  return (
    <AppShell
      title="Regional office portal"
      subtitle={`Office ID: ${officeId} · synced with mobile app via Firestore`}
      onRefresh={load}
    >
      <div className="tabs">
        {(['applications', 'reports', 'clients'] as const).map((t) => (
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

      {!loading && tab === 'applications' && (
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>ID</th>
                <th>Service</th>
                <th>Status</th>
                <th>Submitted</th>
                <th>Update</th>
              </tr>
            </thead>
            <tbody>
              {applications.map((a) => (
                <tr key={a.id}>
                  <td className="mono">{a.id.slice(0, 8)}…</td>
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
          {applications.length === 0 && <p className="muted">No applications for this office.</p>}
        </div>
      )}

      {!loading && tab === 'reports' && (
        <div className="card-list">
          {reports.map((r) => (
            <article key={r.id} className="card">
              <h3>{r.staffName}</h3>
              <p className="muted">{r.station}</p>
              <p>{r.content}</p>
              <p className="muted">{r.submittedAt.toLocaleString()}</p>
            </article>
          ))}
          {reports.length === 0 && <p className="muted">No reports for this office.</p>}
        </div>
      )}

      {!loading && tab === 'clients' && (
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Name</th>
                <th>Email</th>
                <th>Phone</th>
                <th>National ID</th>
              </tr>
            </thead>
            <tbody>
              {clients.map((c) => (
                <tr key={c.id}>
                  <td>
                    {c.fullName} {c.surname}
                  </td>
                  <td>{c.email}</td>
                  <td>{c.phoneNumber}</td>
                  <td>{c.nationalId}</td>
                </tr>
              ))}
            </tbody>
          </table>
          {clients.length === 0 && <p className="muted">No clients in this office.</p>}
        </div>
      )}
    </AppShell>
  );
}
