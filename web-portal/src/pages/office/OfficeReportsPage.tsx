import { EmptyState } from '../../components/ui/EmptyState';
import { PageHeader } from '../../components/ui/PageHeader';
import { useOfficeDataContext } from '../../context/OfficeDataContext';
import { formatDateTime } from '../../utils/format';

export function OfficeReportsPage() {
  const { reports, loading, error } = useOfficeDataContext();

  return (
    <div className="dashboard-content">
      <PageHeader
        title="Field reports"
        description="Submitted by staff through the mobile app from your region."
      />

      {error && <div className="alert alert-error">{error}</div>}

      {loading ? (
        <div className="skeleton-list" />
      ) : reports.length === 0 ? (
        <EmptyState
          title="No reports yet"
          description="Staff reports from the mobile app will show up here when submitted."
        />
      ) : (
        <div className="report-grid">
          {reports.map((r) => (
            <article key={r.id} className="report-card">
              <header>
                <div className="report-avatar">{r.staffName.charAt(0)}</div>
                <div>
                  <h3>{r.staffName}</h3>
                  <p className="muted">{r.station || 'No station'}</p>
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
