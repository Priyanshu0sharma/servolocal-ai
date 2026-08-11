export type CoreStepId = 0 | 1 | 2 | 3 | 4 | 5 | 6;

export type UserRole = 'user' | 'technician' | 'dual' | 'admin';


export interface PitchDeckStep {
  id: CoreStepId;
  number: string;
  title: string;
  shortTitle: string;
  icon: string;
  description: string;
  technicalDetails: string;
}

export type JobStatus =
  | 'DRAFT'
  | 'DISPATCHING'
  | 'ASSIGNED'
  | 'ON_THE_WAY'
  | 'ARRIVED'
  | 'INSPECTION'
  | 'REPAIR_IN_PROGRESS'
  | 'TESTING'
  | 'COMPLETED'
  | 'RATED';

export interface AIDiagnosisResult {
  detectedIssue: string;
  category: string;
  severity: 'Low' | 'Medium' | 'High' | 'Critical Emergency';
  confidence: number;
  visionBoundingBox?: string;
  recommendedParts: { name: string; estimatedCost: number; inStock: boolean }[];
  estimatedLaborHours: number;
  estimatedLaborCost: number;
  estimatedTotal: number;
}

export interface MediaProof {
  id: string;
  url: string;
  name: string;
  type: 'image' | 'video';
  size: string;
}

export interface TechnicianProfile {
  id: string;
  name: string;
  avatar: string;
  phone: string;
  speciality: string;
  rating: number;
  reviewsCount: number;
  distanceKm: number;
  isOnline: boolean;
  vehicle: string;
  completedJobs: number;
}

export interface ChatMessage {
  id: string;
  sender: 'user' | 'technician';
  senderName: string;
  text: string;
  timestamp: string;
}

export interface ServoLocalJob {
  id: string;
  requestCode: string;
  createdAt: string;
  user: {
    name: string;
    phone: string;
    email: string;
    avatar: string;
  };
  status: JobStatus;
  machineName: string;
  category: string;
  problemDescription: string;
  urgency: 'Low' | 'Medium' | 'High' | 'Emergency';
  media: MediaProof[];
  location: {
    address: string;
    landmark: string;
    city: string;
    lat: number;
    lng: number;
  };
  aiDiagnosis: AIDiagnosisResult;
  assignedTechnician?: TechnicianProfile;
  chatMessages: ChatMessage[];
  proofOfRepair?: {
    beforeUrl: string;
    afterUrl: string;
    technicianNotes: string;
    completedAt: string;
  };
  rating?: {
    stars: number;
    feedback: string;
    ratedAt: string;
  };
}

export interface PaymentRecord {
  id: string;
  jobId: string;
  customerName: string;
  machineCategory: string;
  totalAmount: number;
  techPayout: number;
  platformFee: number;
  status: 'PAID' | 'PROCESSING' | 'PENDING';
  paymentMethod: 'UPI' | 'Direct Bank Transfer' | 'Card';
  date: string;
}

export interface TechnicianEarningsSummary {
  todayEarnings: number;
  weeklyEarnings: number;
  monthlyEarnings: number;
  pendingPayouts: number;
  completedJobsCount: number;
  averageRating: number;
  paymentHistory: PaymentRecord[];
}

export interface RealtimeSyncMessage {
  type:
    | 'JOB_CREATED'
    | 'JOB_ACCEPTED'
    | 'STATUS_CHANGED'
    | 'CHAT_SENT'
    | 'JOB_COMPLETED'
    | 'RATING_SUBMITTED'
    | 'TECH_ONLINE_TOGGLE';
  jobId?: string;
  payload?: any;
  timestamp: number;
}

