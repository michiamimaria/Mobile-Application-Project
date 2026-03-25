export type LuggageStatus = 'tracking' | 'idle' | 'alert';

export interface LuggageItem {
  id: string;
  name: string;
  color: string;
  latitude: number;
  longitude: number;
  lastUpdated: string;
  status: LuggageStatus;
  reminderAt?: string;
  reminderNotificationId?: string;
}

export interface AppSettings {
  notificationsEnabled: boolean;
  notifyOnLocationUpdate: boolean;
  simulateMovement: boolean;
}
