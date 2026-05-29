export function formatDate(d: Date): string {
  return d.toLocaleDateString(undefined, { year: 'numeric', month: 'short', day: 'numeric' });
}

export function formatDateTime(d: Date): string {
  return d.toLocaleString(undefined, {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });
}

export function shortId(id: string, len = 8): string {
  return id.length <= len ? id : `${id.slice(0, len)}…`;
}

export function formatStatus(status: string): string {
  return status.replace(/_/g, ' ');
}
