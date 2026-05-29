import { useState } from 'react';
import { ApplicationModal } from '../../components/ui/ApplicationModal';
import { EmptyState } from '../../components/ui/EmptyState';
import { PageHeader } from '../../components/ui/PageHeader';
import { StatusBadge } from '../../components/ui/StatusBadge';
import { useAdminDataContext } from '../../context/AdminDataContext';
import { updateApplicationStatus } from '../../services/dataService';
import type { Application } from '../../types';
import { formatDate, shortId } from '../../utils/format';

const STATUSES = ['pending', 'in_progress', 'approved', 'rejected'];

export function AdminApplicationsPage() {
  const { applications, offices, loading, error, refresh } = useAdminDataContext();
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [officeFilter, setOfficeFilter] = useState('');
  const [selected, setSelected] = useState<Application | null>(null);

  const officeNames = Object.fromEntries(offices.map((o) => [o.id, o.name]));

  const filtered = applications.filter((a) => {
    const matchStatus = !statusFilter || a.status === statusFilter;
    const matchOffice = !officeFilter || a.officeId === officeFilter;
    const q = search.toLowerCase();
    const matchSearch =
      !q ||
      a.serviceType.toLowerCase().includes(q) ||
      a.id.toLowerCase().includes(q) ||
      (a.officeId && a.officeId.toLowerCase().includes(q));
    return matchStatus && matchOffice && matchSearch;
  });

  async function onStatusChange(appId: string, status: string) {
    await updateApplicationStatus(appId, status);
    await refresh();
    if (selected?.id === appId) setSelected((s) => (s ? { ...s, status } : null));
  }

  return (
    <div className="dashboard-content">
      <PageHeader title="All applications" description="National view of every client submission." />

      {error && <div className="alert alert-error">{error}</div>}

      <div className="toolbar toolbar-wrap">
        <div className="search-field">
          <input
            type="search"
            placeholder="Search applications…"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
        <label className="field field-inline">
          Status
          <select value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)}>
            <option value="">All</option>
            {STATUSES.map((s) => (
              <option key={s} value={s}>
                {s.replace(/_/g, ' ')}
              </option>
            ))}
          </select>
        </label>
        <label className="field field-inline">
          Office
          <select value={officeFilter} onChange={(e) => setOfficeFilter(e.target.value)}>
            <option value="">All offices</option>
            {offices.map((o) => (
              <option key={o.id} value={o.id}>
                {o.name}
              </option>
            ))}
          </select>
        </label>
      </div>

      {loading ? (
        <div className="skeleton-table" />
      ) : filtered.length === 0 ? (
        <EmptyState title="No applications match your filters" />
      ) : (
        <div className="data-card">
          <table className="data-table">
            <thead>
              <tr>
                <th>Reference</th>
                <th>Office</th>
                <th>Service</th>
                <th>Status</th>
                <th>Submitted</th>
                <th>Update</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((a) => (
                <tr key={a.id} className="data-row-clickable" onClick={() => setSelected(a)}>
                  <td className="mono">{shortId(a.id)}</td>
                  <td>{officeNames[a.officeId] ?? (a.officeId || '—')}</td>
                  <td>{a.serviceType}</td>
                  <td>
                    <StatusBadge status={a.status} />
                  </td>
                  <td>{formatDate(a.submittedAt)}</td>
                  <td onClick={(e) => e.stopPropagation()}>
                    <select
                      className="select-sm"
                      value={a.status}
                      onChange={(e) => onStatusChange(a.id, e.target.value)}
                    >
                      {STATUSES.map((s) => (
                        <option key={s} value={s}>
                          {s.replace(/_/g, ' ')}
                        </option>
                      ))}
                    </select>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {selected && (
        <ApplicationModal
          application={selected}
          onClose={() => setSelected(null)}
          onStatusChange={onStatusChange}
        />
      )}
    </div>
  );
}
