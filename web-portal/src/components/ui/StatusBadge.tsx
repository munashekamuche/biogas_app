import { formatStatus } from '../../utils/format';

export function StatusBadge({ status }: { status: string }) {
  const normalized = status.toLowerCase().replace(/\s+/g, '_');
  return <span className={`status-badge status-${normalized}`}>{formatStatus(status)}</span>;
}
