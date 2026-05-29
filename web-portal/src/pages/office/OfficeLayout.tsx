import { DashboardLayout } from '../../components/layout/DashboardLayout';
import {
  IconDashboard,
  IconFile,
  IconReport,
  IconUsers,
  IconUser,
} from '../../components/icons';
import { OfficeDataProvider, useOfficeDataContext } from '../../context/OfficeDataContext';
import { useAuth } from '../../context/AuthContext';

function OfficeShell() {
  const { office, refresh } = useOfficeDataContext();
  const officeName = office?.name ?? 'Regional office';

  return (
    <DashboardLayout
      brandTitle="Office portal"
      brandSubtitle={officeName}
      basePath="/office"
      onRefresh={refresh}
      navItems={[
        { to: '/office', label: 'Overview', icon: <IconDashboard />, end: true },
        { to: '/office/applications', label: 'Applications', icon: <IconFile /> },
        { to: '/office/reports', label: 'Field reports', icon: <IconReport /> },
        { to: '/office/clients', label: 'Clients', icon: <IconUsers /> },
        { to: '/office/profile', label: 'Profile', icon: <IconUser /> },
      ]}
    />
  );
}

export function OfficeLayout() {
  const { profile } = useAuth();
  const officeId = profile?.officeId ?? '';

  if (!officeId) {
    return (
      <div className="dashboard dashboard--single">
        <main className="dashboard-content">
          <div className="alert alert-error">
            Your account has no office assigned. Contact national admin.
          </div>
        </main>
      </div>
    );
  }

  return (
    <OfficeDataProvider officeId={officeId}>
      <OfficeShell />
    </OfficeDataProvider>
  );
}
