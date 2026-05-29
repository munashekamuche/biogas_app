import type { ReactNode } from 'react';

export function StatCard({
  label,
  value,
  hint,
  icon,
  accent,
}: {
  label: string;
  value: string | number;
  hint?: string;
  icon?: ReactNode;
  accent?: 'green' | 'amber' | 'blue' | 'slate';
}) {
  return (
    <article className={`stat-card stat-card--${accent ?? 'green'}`}>
      {icon && <div className="stat-card-icon">{icon}</div>}
      <div className="stat-card-body">
        <span className="stat-card-label">{label}</span>
        <strong className="stat-card-value">{value}</strong>
        {hint && <span className="stat-card-hint">{hint}</span>}
      </div>
    </article>
  );
}
