import { Link } from 'react-router-dom';
import { IconChevronRight, IconBuilding, IconFile } from '../../components/icons';
import { PageHeader } from '../../components/ui/PageHeader';
import { StatCard } from '../../components/ui/StatCard';
import { StatusBadge } from '../../components/ui/StatusBadge';
import { useAdminDataContext } from '../../context/AdminDataContext';
import { formatDate } from '../../utils/format';

export function AdminOverviewPage() {
  const { applications, reports, offices, loading, error } = useAdminDataContext();

  const pending = applications.filter((a) => a.status === 'pending').length;
  const approved = applications.filter((a) => a.status === 'approved').length;
  const recent = applications.slice(0, 6);

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
        title="National overview"
        description="Monitor applications, offices, and field activity across all regions."
      />

      {error && <div className="alert alert-error">{error}</div>}

      <div className="stats-grid stats-grid--wide">
        <StatCard label="Total applications" value={applications.length} accent="green" />
        <StatCard label="Pending" value={pending} accent="amber" />
        <StatCard label="Approved" value={approved} accent="blue" />
        <StatCard label="Regional offices" value={offices.length} accent="slate" />
        <StatCard label="Staff reports" value={reports.length} accent="green" />
      </div>

      <div className="content-grid">
        <section className="panel">
          <div className="panel-header">
            <h2>Latest applications</h2>
            <Link to="/admin/applications" className="link-arrow">
              View all <IconChevronRight size={16} />
            </Link>
          </div>
          {recent.length === 0 ? (
            <p className="muted">No applications in the system yet.</p>
          ) : (
            <ul className="activity-list">
              {recent.map((a) => (
                <li key={a.id}>
                  <div>
                    <strong>{a.serviceType}</strong>
                    <span className="muted">
                      {a.officeId || 'No office'} · {formatDate(a.submittedAt)}
                    </span>
                  </div>
                  <StatusBadge status={a.status} />
                </li>
              ))}
            </ul>
          )}
        </section>

        <section className="panel panel--accent">
          <h2>Manage</h2>
          <div className="quick-links">
            <Link to="/admin/applications" className="quick-link">
              <IconFile />
              <span>All applications</span>
              <IconChevronRight size={18} />
            </Link>
            <Link to="/admin/offices" className="quick-link">
              <IconBuilding />
              <span>Regional offices</span>
              <IconChevronRight size={18} />
            </Link>
          </div>
        </section>
      </div>
    </div>
  );
}
