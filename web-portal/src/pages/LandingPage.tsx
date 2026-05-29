import { Link } from 'react-router-dom';
import { IconFile, IconLeaf, IconUsers } from '../components/icons';
import heroImage from '../assets/hero.png';

export function LandingPage() {
  return (
    <div className="landing">
      <header className="landing-nav">
        <div className="landing-brand">
          <IconLeaf size={32} />
          <span>REA Service Management</span>
        </div>
        <nav>
          <a href="#features">Features</a>
          <a href="#how-it-works">How it works</a>
          <Link to="/login" className="btn btn-primary">
            Sign in
          </Link>
        </nav>
      </header>

      <section className="landing-hero">
        <div className="landing-hero-text">
          <p className="eyebrow">Rural Electrification &amp; Biogas Services</p>
          <h1>
            Manage applications and field work from one connected platform
          </h1>
          <p className="lead">
            Regional offices and national administrators use this portal. Clients and field staff
            continue on the mobile app — everything stays in sync through Firebase.
          </p>
          <div className="landing-cta">
            <Link to="/login" className="btn btn-primary btn-lg">
              Open portal
            </Link>
            <a href="#features" className="btn btn-outline btn-lg">
              Learn more
            </a>
          </div>
        </div>
        <div className="landing-hero-visual">
          <img src={heroImage} alt="Renewable energy services" />
          <div className="hero-glow" aria-hidden />
        </div>
      </section>

      <section id="features" className="landing-section">
        <h2>Built for your team</h2>
        <div className="feature-grid">
          <article className="feature-card">
            <div className="feature-icon">
              <IconFile size={28} />
            </div>
            <h3>Application workflow</h3>
            <p>
              Review electrification and biogas applications submitted on mobile. Update status and
              keep clients informed.
            </p>
          </article>
          <article className="feature-card">
            <div className="feature-icon">
              <IconUsers size={28} />
            </div>
            <h3>Regional visibility</h3>
            <p>
              Office users see only their region. National admins get a full picture across all
              offices and reports.
            </p>
          </article>
          <article className="feature-card">
            <div className="feature-icon">
              <IconLeaf size={28} />
            </div>
            <h3>Real-time sync</h3>
            <p>
              Powered by Cloud Firestore — no duplicate data entry. What you change here appears on
              phones instantly.
            </p>
          </article>
        </div>
      </section>

      <section id="how-it-works" className="landing-section landing-section--alt">
        <h2>How it works</h2>
        <ol className="steps">
          <li>
            <strong>Clients apply on mobile</strong>
            <span>Submissions land in Firestore with office and service details.</span>
          </li>
          <li>
            <strong>Office staff review on web</strong>
            <span>Approve, reject, or mark applications in progress.</span>
          </li>
          <li>
            <strong>Field staff report in the field</strong>
            <span>Reports sync to the portal for supervisors and admins.</span>
          </li>
        </ol>
      </section>

      <footer className="landing-footer">
        <p>© REA Service Management · Office &amp; admin portal</p>
        <Link to="/login">Sign in</Link>
      </footer>
    </div>
  );
}
