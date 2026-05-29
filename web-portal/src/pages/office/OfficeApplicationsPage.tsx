import { useState } from 'react';
import { ApplicationModal } from '../../components/ui/ApplicationModal';
import { EmptyState } from '../../components/ui/EmptyState';
import { PageHeader } from '../../components/ui/PageHeader';
import { StatusBadge } from '../../components/ui/StatusBadge';
import { useOfficeDataContext } from '../../context/OfficeDataContext';
import { updateApplicationStatus } from '../../services/dataService';
import type { Application } from '../../types';
import { formatDate, shortId } from '../../utils/format';

const STATUSES = ['pending', 'in_progress', 'approved', 'rejected'];

export function OfficeApplicationsPage() {
  const { applications, loading, error, refresh } = useOfficeDataContext();
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [selected, setSelected] = useState<Application | null>(null);

  const filtered = applications.filter((a) => {
    const matchStatus = !statusFilter || a.status === statusFilter;
    const q = search.toLowerCase();
    const matchSearch =
      !q ||
      a.serviceType.toLowerCase().includes(q) ||
      a.id.toLowerCase().includes(q) ||
      a.status.toLowerCase().includes(q);
    return matchStatus && matchSearch;
  });

  async function onStatusChange(appId: string, status: string) {
    await updateApplicationStatus(appId, status);
    await refresh();
    if (selected?.id === appId) {
      setSelected((s) => (s ? { ...s, status } : null));
    }
  }

  return (
    <div className="dashboard-content">
      <PageHeader
        title="Applications"
        description="Review and update status for client submissions from the mobile app."
      />

      {error && <div className="alert alert-error">{error}</div>}

      <div className="toolbar">
        <div className="search-field">
          <input
            type="search"
            placeholder="Search by service, ID, or status…"
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
      </div>

      {loading ? (
        <div className="skeleton-table" />
      ) : filtered.length === 0 ? (
        <EmptyState
          title="No applications found"
          description={
            applications.length === 0
              ? 'When clients submit via the mobile app, they appear here.'
              : 'Try adjusting your search or filters.'
          }
        />
      ) : (
        <div className="data-card">
          <table className="data-table">
            <thead>
              <tr>
                <th>Reference</th>
                <th>Service</th>
                <th>Status</th>
                <th>Submitted</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((a) => (
                <tr key={a.id} className="data-row-clickable" onClick={() => setSelected(a)}>
                  <td className="mono">{shortId(a.id)}</td>
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
