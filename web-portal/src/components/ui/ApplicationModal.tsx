import type { Application } from '../../types';
import { formatDateTime } from '../../utils/format';
import { StatusBadge } from './StatusBadge';
import { IconClose } from '../icons';

const STATUSES = ['pending', 'in_progress', 'approved', 'rejected'];

export function ApplicationModal({
  application,
  onClose,
  onStatusChange,
}: {
  application: Application;
  onClose: () => void;
  onStatusChange: (id: string, status: string) => void;
}) {
  const formEntries = Object.entries(application.formData ?? {}).filter(
    ([, v]) => v !== null && v !== undefined && v !== '',
  );

  return (
    <div className="modal-backdrop" onClick={onClose} role="presentation">
      <div
        className="modal-panel"
        onClick={(e) => e.stopPropagation()}
        role="dialog"
        aria-labelledby="app-modal-title"
      >
        <div className="modal-header">
          <div>
            <p className="modal-kicker">Application</p>
            <h2 id="app-modal-title">{application.serviceType}</h2>
          </div>
          <button type="button" className="icon-btn" onClick={onClose} aria-label="Close">
            <IconClose />
          </button>
        </div>

        <div className="modal-body">
          <div className="detail-grid">
            <div>
              <span className="detail-label">Status</span>
              <StatusBadge status={application.status} />
            </div>
            <div>
              <span className="detail-label">Biogas type</span>
              <span>{application.biogasType || '—'}</span>
            </div>
            <div>
              <span className="detail-label">Submitted</span>
              <span>{formatDateTime(application.submittedAt)}</span>
            </div>
            <div>
              <span className="detail-label">Office</span>
              <span className="mono">{application.officeId || '—'}</span>
            </div>
          </div>

          {formEntries.length > 0 && (
            <section className="modal-section">
              <h3>Form details</h3>
              <dl className="detail-list">
                {formEntries.map(([key, value]) => (
                  <div key={key}>
                    <dt>{key.replace(/_/g, ' ')}</dt>
                    <dd>{String(value)}</dd>
                  </div>
                ))}
              </dl>
            </section>
          )}

          <label className="field">
            Update status
            <select
              value={application.status}
              onChange={(e) => onStatusChange(application.id, e.target.value)}
            >
              {STATUSES.map((s) => (
                <option key={s} value={s}>
                  {s.replace(/_/g, ' ')}
                </option>
              ))}
            </select>
          </label>
        </div>
      </div>
    </div>
  );
}
