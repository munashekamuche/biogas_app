export type UserRole = 'client' | 'staff' | 'admin' | 'office';

export interface AppUser {
  id: string;
  fullName: string;
  surname: string;
  email: string;
  phoneNumber: string;
  nationalId: string;
  role: UserRole;
  officeId?: string;
  station?: string;
  createdAt: Date;
}

export interface Office {
  id: string;
  name: string;
  region?: string;
  active: boolean;
}

export interface Application {
  id: string;
  userId: string;
  officeId: string;
  serviceType: string;
  biogasType: string;
  formData: Record<string, unknown>;
  status: string;
  submittedAt: Date;
  updatedAt?: Date;
}

export interface Report {
  id: string;
  userId: string;
  officeId: string;
  staffName: string;
  station: string;
  content: string;
  submittedAt: Date;
}
