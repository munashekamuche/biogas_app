import { DashboardLayout } from '../../components/layout/DashboardLayout';
import {
  IconBuilding,
  IconDashboard,
  IconFile,
  IconReport,
  IconUser,
} from '../../components/icons';
import { AdminDataProvider, useAdminDataContext } from '../../context/AdminDataContext';

function AdminShell() {
  const { refresh } = useAdminDataContext();

  return (
    <DashboardLayout
      brandTitle="National admin"
      brandSubtitle="Full system visibility"
      basePath="/admin"
      onRefresh={refresh}
      navItems={[
        { to: '/admin', label: 'Overview', icon: <IconDashboard />, end: true },
        { to: '/admin/applications', label: 'Applications', icon: <IconFile /> },
        { to: '/admin/reports', label: 'Field reports', icon: <IconReport /> },
        { to: '/admin/offices', label: 'Offices', icon: <IconBuilding /> },
        { to: '/admin/profile', label: 'Profile', icon: <IconUser /> },
      ]}
    />
  );
}

export function AdminLayout() {
  return (
    <AdminDataProvider>
      <AdminShell />
    </AdminDataProvider>
  );
}
