import type { ReactNode } from 'react';
import { NavLink, Outlet } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { IconLeaf, IconLogout, IconRefresh } from '../icons';

export type NavItem = {
  to: string;
  label: string;
  icon: ReactNode;
  end?: boolean;
};

export function DashboardLayout({
  brandTitle,
  brandSubtitle,
  navItems,
  basePath,
  onRefresh,
}: {
  brandTitle: string;
  brandSubtitle?: string;
  navItems: NavItem[];
  basePath: '/office' | '/admin';
  onRefresh?: () => void;
}) {
  const { profile, logout } = useAuth();

  return (
    <div className="dashboard">
      <aside className="sidebar">
        <div className="sidebar-brand">
          <div className="sidebar-logo">
            <IconLeaf size={28} />
          </div>
          <div>
            <strong>REA Services</strong>
            <span>{brandTitle}</span>
          </div>
        </div>

        {brandSubtitle && <p className="sidebar-subtitle">{brandSubtitle}</p>}

        <nav className="sidebar-nav">
          {navItems.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.end}
              className={({ isActive }) => (isActive ? 'nav-link active' : 'nav-link')}
            >
              {item.icon}
              <span>{item.label}</span>
            </NavLink>
          ))}
        </nav>

        <div className="sidebar-footer">
          {profile && (
            <NavLink to={`${basePath}/profile`} className="sidebar-user">
              <div className="avatar">{profile.fullName.charAt(0)}</div>
              <div>
                <strong>
                  {profile.fullName} {profile.surname}
                </strong>
                <span className="capitalize">{profile.role}</span>
              </div>
            </NavLink>
          )}
          <div className="sidebar-actions">
            {onRefresh && (
              <button type="button" className="btn btn-sm btn-ghost-dark" onClick={onRefresh}>
                <IconRefresh size={18} />
                Refresh
              </button>
            )}
            <button type="button" className="btn btn-sm btn-ghost-dark" onClick={() => logout()}>
              <IconLogout size={18} />
              Log out
            </button>
          </div>
        </div>
      </aside>

      <div className="dashboard-main">
        <Outlet />
      </div>
    </div>
  );
}
