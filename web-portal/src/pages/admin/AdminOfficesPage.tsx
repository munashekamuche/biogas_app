import { EmptyState } from '../../components/ui/EmptyState';
import { PageHeader } from '../../components/ui/PageHeader';
import { useAdminDataContext } from '../../context/AdminDataContext';
import { shortId } from '../../utils/format';

export function AdminOfficesPage() {
  const { offices, loading, error } = useAdminDataContext();

  return (
    <div className="dashboard-content">
      <PageHeader
        title="Regional offices"
        description="Offices created in the system. Manage new offices from the mobile admin app."
      />

      {error && <div className="alert alert-error">{error}</div>}

      {loading ? (
        <div className="skeleton-grid" />
      ) : offices.length === 0 ? (
        <EmptyState
          title="No offices configured"
          description="Create regional offices from the mobile admin dashboard."
        />
      ) : (
        <div className="office-grid">
          {offices.map((o) => (
            <article key={o.id} className={`office-card ${o.active ? '' : 'office-card--inactive'}`}>
              <div className="office-card-icon">
                <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <path d="M3 21h18" />
                  <path d="M5 21V7l8-4v18" />
                  <path d="M19 21V11l-6-4" />
                </svg>
              </div>
              <div>
                <h3>{o.name}</h3>
                <p className="muted">{o.region ?? 'No region set'}</p>
                <p className="mono office-id">{shortId(o.id, 12)}</p>
              </div>
              <span className={`pill ${o.active ? 'pill--success' : 'pill--muted'}`}>
                {o.active ? 'Active' : 'Inactive'}
              </span>
            </article>
          ))}
        </div>
      )}
    </div>
  );
}
