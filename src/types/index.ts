export type LuggageStatus = 'tracking' | 'idle' | 'alert';
export type TrackerType = 'luggageTag' | 'airTag';

export interface LuggageItem {
  id: string;
  name: string;
  trackerType?: TrackerType;
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
