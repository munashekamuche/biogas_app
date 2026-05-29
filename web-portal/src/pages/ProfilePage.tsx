import { useAuth } from '../context/AuthContext';
import { PageHeader } from '../components/ui/PageHeader';
import { formatDateTime } from '../utils/format';

export function ProfilePage() {
  const { profile } = useAuth();

  if (!profile) return null;

  return (
    <div className="dashboard-content">
      <PageHeader title="Your profile" description="Account details synced from Firestore." />

      <div className="profile-card">
        <div className="profile-hero">
          <div className="profile-avatar-lg">
            {profile.fullName.charAt(0)}
            {profile.surname.charAt(0)}
          </div>
          <div>
            <h2>
              {profile.fullName} {profile.surname}
            </h2>
            <span className="role-chip">{profile.role}</span>
          </div>
        </div>

        <dl className="profile-details">
          <div>
            <dt>Email</dt>
            <dd>{profile.email}</dd>
          </div>
          <div>
            <dt>Phone</dt>
            <dd>{profile.phoneNumber}</dd>
          </div>
          <div>
            <dt>National ID</dt>
            <dd>{profile.nationalId}</dd>
          </div>
          {profile.officeId && (
            <div>
              <dt>Office ID</dt>
              <dd className="mono">{profile.officeId}</dd>
            </div>
          )}
          {profile.station && (
            <div>
              <dt>Station</dt>
              <dd>{profile.station}</dd>
            </div>
          )}
          <div>
            <dt>Member since</dt>
            <dd>{formatDateTime(profile.createdAt)}</dd>
          </div>
        </dl>
      </div>

      <section className="panel panel--info">
        <h3>About this portal</h3>
        <p>
          The REA Service Management web portal connects to the same Firebase backend as the mobile
          app. Changes you make here (such as application status) are visible to clients and staff
          in real time.
        </p>
      </section>
    </div>
  );
}
