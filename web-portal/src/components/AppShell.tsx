import { useAuth } from '../context/AuthContext';

export function AppShell({
  title,
  subtitle,
  onRefresh,
  children,
}: {
  title: string;
  subtitle?: string;
  onRefresh?: () => void;
  children: React.ReactNode;
}) {
  const { profile, logout } = useAuth();

  return (
    <div className="shell">
      <header className="shell-header">
        <div>
          <p className="shell-kicker">REA Service Management</p>
          <h1>{title}</h1>
          {subtitle && <p className="shell-subtitle">{subtitle}</p>}
        </div>
        <div className="shell-actions">
          {profile && (
            <span className="user-pill">
              {profile.fullName} {profile.surname} · {profile.role}
            </span>
          )}
          {onRefresh && (
            <button type="button" className="btn secondary" onClick={onRefresh}>
              Refresh
            </button>
          )}
          <button type="button" className="btn ghost" onClick={() => logout()}>
            Log out
          </button>
        </div>
      </header>
      <main className="shell-main">{children}</main>
    </div>
  );
}
