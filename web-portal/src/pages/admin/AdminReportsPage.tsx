import { EmptyState } from '../../components/ui/EmptyState';
import { PageHeader } from '../../components/ui/PageHeader';
import { useAdminDataContext } from '../../context/AdminDataContext';
import { formatDateTime } from '../../utils/format';

export function AdminReportsPage() {
  const { reports, offices, loading, error } = useAdminDataContext();
  const officeNames = Object.fromEntries(offices.map((o) => [o.id, o.name]));

  return (
    <div className="dashboard-content">
      <PageHeader title="Field reports" description="Staff submissions from all regional offices." />

      {error && <div className="alert alert-error">{error}</div>}

      {loading ? (
        <div className="skeleton-list" />
      ) : reports.length === 0 ? (
        <EmptyState title="No field reports" description="Reports from staff on mobile will appear here." />
      ) : (
        <div className="report-grid">
          {reports.map((r) => (
            <article key={r.id} className="report-card">
              <header>
                <div className="report-avatar">{r.staffName.charAt(0)}</div>
                <div>
                  <h3>{r.staffName}</h3>
                  <p className="muted">
                    {r.station || '—'} · {officeNames[r.officeId] ?? r.officeId}
                  </p>
                </div>
                <time>{formatDateTime(r.submittedAt)}</time>
              </header>
              <p className="report-body">{r.content}</p>
            </article>
          ))}
        </div>
      )}
    </div>
  );
}
