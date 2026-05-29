import { useState, type FormEvent } from 'react';
import { Link, Navigate } from 'react-router-dom';
import { IconLeaf } from '../components/icons';
import { useAuth } from '../context/AuthContext';
import heroImage from '../assets/hero.png';

export function LoginPage() {
  const { profile, login } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  if (profile?.role === 'admin') return <Navigate to="/admin" replace />;
  if (profile?.role === 'office') return <Navigate to="/office" replace />;

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      const msg = await login(email.trim(), password);
      if (msg) setError(msg);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Login failed');
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="login-layout">
      <div className="login-visual">
        <div className="login-visual-content">
          <Link to="/" className="login-back">
            <IconLeaf size={28} />
            REA Services
          </Link>
          <h1>Office &amp; admin portal</h1>
          <p>
            Review applications, manage regional data, and stay synced with the mobile app in real
            time.
          </p>
          <img src={heroImage} alt="" className="login-hero-img" />
        </div>
      </div>

      <div className="login-form-panel">
        <form className="login-form" onSubmit={onSubmit}>
          <h2>Welcome back</h2>
          <p className="muted">Sign in with your web account credentials.</p>

          <label className="field">
            Email address
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              autoComplete="email"
              placeholder="you@rea.gov.zw"
            />
          </label>
          <label className="field">
            Password
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              autoComplete="current-password"
              placeholder="••••••••"
            />
          </label>

          {error && <div className="alert alert-error">{error}</div>}

          <button type="submit" className="btn btn-primary btn-block" disabled={busy}>
            {busy ? 'Signing in…' : 'Sign in'}
          </button>

          <p className="login-hint muted">
            Clients and field staff should use the <strong>mobile app</strong>.{' '}
            <Link to="/">Back to home</Link>
          </p>
        </form>
      </div>
    </div>
  );
}
