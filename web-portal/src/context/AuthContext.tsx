import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react';
import {
  onAuthStateChanged,
  signInWithEmailAndPassword,
  signOut,
  type User,
} from 'firebase/auth';
import { auth } from '../firebase/config';
import { fetchUserProfile } from '../services/dataService';
import type { AppUser } from '../types';

interface AuthContextValue {
  firebaseUser: User | null;
  profile: AppUser | null;
  loading: boolean;
  login: (email: string, password: string) => Promise<string | null>;
  logout: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [firebaseUser, setFirebaseUser] = useState<User | null>(null);
  const [profile, setProfile] = useState<AppUser | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsub = onAuthStateChanged(auth, async (user) => {
      setFirebaseUser(user);
      if (!user) {
        setProfile(null);
        setLoading(false);
        return;
      }
      const p = await fetchUserProfile(user.uid);
      if (p && (p.role === 'admin' || p.role === 'office')) {
        setProfile(p);
      } else {
        await signOut(auth);
        setProfile(null);
      }
      setLoading(false);
    });
    return unsub;
  }, []);

  const login = useCallback(async (email: string, password: string) => {
    const cred = await signInWithEmailAndPassword(auth, email, password);
    const p = await fetchUserProfile(cred.user.uid);
    if (!p) return 'User profile not found in Firestore.';
    if (p.role !== 'admin' && p.role !== 'office') {
      await signOut(auth);
      return 'This portal is for office and admin users only. Use the mobile app for client/staff access.';
    }
    setProfile(p);
    return null;
  }, []);

  const logout = useCallback(async () => {
    await signOut(auth);
    setProfile(null);
  }, []);

  const value = useMemo(
    () => ({ firebaseUser, profile, loading, login, logout }),
    [firebaseUser, profile, loading, login, logout],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
}
