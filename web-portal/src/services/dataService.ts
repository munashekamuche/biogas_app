import {
  collection,
  doc,
  getDoc,
  getDocs,
  orderBy,
  query,
  updateDoc,
  where,
  Timestamp,
} from 'firebase/firestore';
import { db } from '../firebase/config';
import type { AppUser, Application, Office, Report } from '../types';

function toDate(value: unknown): Date {
  if (value instanceof Timestamp) return value.toDate();
  if (value instanceof Date) return value;
  return new Date();
}

function sortBySubmittedAtDesc<T extends { submittedAt: Date }>(items: T[]): T[] {
  return [...items].sort((a, b) => b.submittedAt.getTime() - a.submittedAt.getTime());
}

export async function fetchUserProfile(uid: string): Promise<AppUser | null> {
  const snap = await getDoc(doc(db, 'users', uid));
  if (!snap.exists()) return null;
  const d = snap.data();
  return {
    id: (d.id as string) ?? uid,
    fullName: (d.fullName as string) ?? '',
    surname: (d.surname as string) ?? '',
    email: (d.email as string) ?? '',
    phoneNumber: (d.phoneNumber as string) ?? '',
    nationalId: (d.nationalId as string) ?? '',
    role: (d.role as AppUser['role']) ?? 'client',
    officeId: d.officeId as string | undefined,
    station: d.station as string | undefined,
    createdAt: toDate(d.createdAt),
  };
}

export async function fetchOffices(): Promise<Office[]> {
  const snap = await getDocs(collection(db, 'offices'));
  return snap.docs.map((docSnap) => {
    const d = docSnap.data();
    return {
      id: (d.id as string) ?? docSnap.id,
      name: (d.name as string) ?? docSnap.id,
      region: d.region as string | undefined,
      active: (d.active as boolean) ?? true,
    };
  });
}

export async function fetchApplications(officeId?: string): Promise<Application[]> {
  const q = officeId
    ? query(collection(db, 'applications'), where('officeId', '==', officeId))
    : query(collection(db, 'applications'), orderBy('submittedAt', 'desc'));
  const snap = await getDocs(q);
  const items = snap.docs.map(mapApplication);
  return officeId ? sortBySubmittedAtDesc(items) : items;
}

export async function updateApplicationStatus(
  applicationId: string,
  status: string,
): Promise<void> {
  await updateDoc(doc(db, 'applications', applicationId), {
    status,
    updatedAt: Timestamp.now(),
  });
}

export async function fetchReports(officeId?: string): Promise<Report[]> {
  const q = officeId
    ? query(collection(db, 'reports'), where('officeId', '==', officeId))
    : query(collection(db, 'reports'), orderBy('submittedAt', 'desc'));
  const snap = await getDocs(q);
  const items = snap.docs.map((docSnap) => {
    const d = docSnap.data();
    return {
      id: (d.id as string) ?? docSnap.id,
      userId: (d.userId as string) ?? '',
      officeId: (d.officeId as string) ?? '',
      staffName: (d.staffName as string) ?? '',
      station: (d.station as string) ?? '',
      content: (d.content as string) ?? '',
      submittedAt: toDate(d.submittedAt),
    };
  });
  return officeId ? sortBySubmittedAtDesc(items) : items;
}

export async function fetchClientsByOffice(officeId: string): Promise<AppUser[]> {
  const q = query(collection(db, 'users'), where('officeId', '==', officeId));
  const snap = await getDocs(q);
  return snap.docs.map(mapUser).filter((u) => u.role === 'client');
}

function mapApplication(docSnap: { id: string; data: () => Record<string, unknown> }): Application {
  const d = docSnap.data();
  return {
    id: (d.id as string) ?? docSnap.id,
    userId: (d.userId as string) ?? '',
    officeId: (d.officeId as string) ?? '',
    serviceType: (d.serviceType as string) ?? '',
    biogasType: (d.biogasType as string) ?? '',
    formData: (d.formData as Record<string, unknown>) ?? {},
    status: (d.status as string) ?? 'pending',
    submittedAt: toDate(d.submittedAt),
    updatedAt: d.updatedAt ? toDate(d.updatedAt) : undefined,
  };
}

function mapUser(docSnap: { id: string; data: () => Record<string, unknown> }): AppUser {
  const d = docSnap.data();
  return {
    id: (d.id as string) ?? docSnap.id,
    fullName: (d.fullName as string) ?? '',
    surname: (d.surname as string) ?? '',
    email: (d.email as string) ?? '',
    phoneNumber: (d.phoneNumber as string) ?? '',
    nationalId: (d.nationalId as string) ?? '',
    role: (d.role as AppUser['role']) ?? 'client',
    officeId: d.officeId as string | undefined,
    station: d.station as string | undefined,
    createdAt: toDate(d.createdAt),
  };
}
