import { Link } from 'react-router-dom';
import { IconChevronRight, IconFile, IconReport, IconUsers } from '../../components/icons';
import { PageHeader } from '../../components/ui/PageHeader';
import { StatCard } from '../../components/ui/StatCard';
import { StatusBadge } from '../../components/ui/StatusBadge';
import { useOfficeDataContext } from '../../context/OfficeDataContext';
import { formatDate } from '../../utils/format';

export function OfficeOverviewPage() {
  const { applications, reports, clients, loading, error } = useOfficeDataContext();

  const pending = applications.filter((a) => a.status === 'pending').length;
  const recent = applications.slice(0, 5);

  if (loading) {
    return (
      <div className="dashboard-content">
        <div className="skeleton-grid" />
      </div>
    );
  }

  return (
    <div className="dashboard-content">
      <PageHeader
        title="Office overview"
        description="Live data from the mobile app — applications, reports, and clients in your region."
      />

      {error && <div className="alert alert-error">{error}</div>}

      <div className="stats-grid">
        <StatCard label="Applications" value={applications.length} accent="green" />
        <StatCard label="Pending review" value={pending} accent="amber" />
        <StatCard label="Field reports" value={reports.length} accent="blue" />
        <StatCard label="Registered clients" value={clients.length} accent="slate" />
      </div>

      <div className="content-grid">
        <section className="panel">
          <div className="panel-header">
            <h2>Recent applications</h2>
            <Link to="/office/applications" className="link-arrow">
              View all <IconChevronRight size={16} />
            </Link>
          </div>
          {recent.length === 0 ? (
            <p className="muted">No applications yet for this office.</p>
          ) : (
            <ul className="activity-list">
              {recent.map((a) => (
                <li key={a.id}>
                  <div>
                    <strong>{a.serviceType}</strong>
                    <span className="muted">{formatDate(a.submittedAt)}</span>
                  </div>
                  <StatusBadge status={a.status} />
                </li>
              ))}
            </ul>
          )}
        </section>

        <section className="panel panel--accent">
          <h2>Quick links</h2>
          <div className="quick-links">
            <Link to="/office/applications" className="quick-link">
              <IconFile />
              <span>Review applications</span>
              <IconChevronRight size={18} />
            </Link>
            <Link to="/office/reports" className="quick-link">
              <IconReport />
              <span>Staff field reports</span>
              <IconChevronRight size={18} />
            </Link>
            <Link to="/office/clients" className="quick-link">
              <IconUsers />
              <span>Client directory</span>
              <IconChevronRight size={18} />
            </Link>
          </div>
        </section>
      </div>
    </div>
  );
}
