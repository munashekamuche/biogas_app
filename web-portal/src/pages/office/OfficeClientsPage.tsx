import { EmptyState } from '../../components/ui/EmptyState';
import { PageHeader } from '../../components/ui/PageHeader';
import { useOfficeDataContext } from '../../context/OfficeDataContext';

export function OfficeClientsPage() {
  const { clients, loading, error } = useOfficeDataContext();

  return (
    <div className="dashboard-content">
      <PageHeader
        title="Clients"
        description="Registered clients linked to your regional office."
      />

      {error && <div className="alert alert-error">{error}</div>}

      {loading ? (
        <div className="skeleton-table" />
      ) : clients.length === 0 ? (
        <EmptyState
          title="No clients in this office"
          description="Clients who register on the mobile app and select your office appear here."
        />
      ) : (
        <div className="client-grid">
          {clients.map((c) => (
            <article key={c.id} className="client-card">
              <div className="client-avatar">
                {c.fullName.charAt(0)}
                {c.surname.charAt(0)}
              </div>
              <div>
                <h3>
                  {c.fullName} {c.surname}
                </h3>
                <p className="muted">{c.email}</p>
                <dl className="client-meta">
                  <div>
                    <dt>Phone</dt>
                    <dd>{c.phoneNumber}</dd>
                  </div>
                  <div>
                    <dt>National ID</dt>
                    <dd>{c.nationalId}</dd>
                  </div>
                </dl>
              </div>
            </article>
          ))}
        </div>
      )}
    </div>
  );
}
