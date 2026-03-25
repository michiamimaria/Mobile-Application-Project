import React, {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
} from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import type { AppSettings, LuggageItem } from '../types';
import {
  cancelScheduledNotification,
  scheduleReminder,
  sendImmediateNotification,
} from '../hooks/useNotifications';

const STORAGE_ITEMS = '@luggage/items';
const STORAGE_SETTINGS = '@luggage/settings';

const defaultSettings: AppSettings = {
  notificationsEnabled: true,
  notifyOnLocationUpdate: true,
  simulateMovement: true,
};

function jitterCoord(v: number, scale: number): number {
  return v + (Math.random() - 0.5) * scale;
}

type LuggageContextValue = {
  items: LuggageItem[];
  settings: AppSettings;
  loading: boolean;
  addItem: (item: Omit<LuggageItem, 'id' | 'lastUpdated'>) => Promise<void>;
  removeItem: (id: string) => Promise<void>;
  setSettings: (patch: Partial<AppSettings>) => Promise<void>;
};

const LuggageContext = createContext<LuggageContextValue | null>(null);

export function LuggageProvider({ children }: { children: React.ReactNode }) {
  const [items, setItems] = useState<LuggageItem[]>([]);
  const [settings, setSettingsState] = useState<AppSettings>(defaultSettings);
  const [loading, setLoading] = useState(true);
  const lastBulkNotify = useRef(0);
  const itemsRef = useRef(items);
  itemsRef.current = items;

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const [rawItems, rawSettings] = await Promise.all([
          AsyncStorage.getItem(STORAGE_ITEMS),
          AsyncStorage.getItem(STORAGE_SETTINGS),
        ]);
        if (cancelled) return;
        if (rawItems) setItems(JSON.parse(rawItems) as LuggageItem[]);
        if (rawSettings)
          setSettingsState({ ...defaultSettings, ...JSON.parse(rawSettings) });
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  const persistItems = useCallback(async (next: LuggageItem[]) => {
    setItems(next);
    await AsyncStorage.setItem(STORAGE_ITEMS, JSON.stringify(next));
  }, []);

  const setSettings = useCallback(
    async (patch: Partial<AppSettings>) => {
      const next = { ...settings, ...patch };
      setSettingsState(next);
      await AsyncStorage.setItem(STORAGE_SETTINGS, JSON.stringify(next));
    },
    [settings]
  );

  const addItem = useCallback(
    async (input: Omit<LuggageItem, 'id' | 'lastUpdated'>) => {
      const id = `${Date.now()}-${Math.random().toString(36).slice(2, 9)}`;
      let reminderNotificationId: string | undefined;

      if (
        input.reminderAt &&
        settings.notificationsEnabled &&
        new Date(input.reminderAt) > new Date()
      ) {
        const nid = await scheduleReminder(
          'Luggage reminder',
          `Check on: ${input.name}`,
          new Date(input.reminderAt)
        );
        reminderNotificationId = nid ?? undefined;
      }

      const item: LuggageItem = {
        ...input,
        id,
        lastUpdated: new Date().toISOString(),
        reminderNotificationId,
      };
      await persistItems([...items, item]);
    },
    [items, persistItems, settings.notificationsEnabled]
  );

  const removeItem = useCallback(
    async (id: string) => {
      const target = items.find((i) => i.id === id);
      if (target?.reminderNotificationId) {
        await cancelScheduledNotification(target.reminderNotificationId);
      }
      await persistItems(items.filter((i) => i.id !== id));
    },
    [items, persistItems]
  );

  useEffect(() => {
    if (!settings.simulateMovement) return;
    const id = setInterval(async () => {
      const current = itemsRef.current;
      if (current.length === 0) return;
      const next = current.map((i) =>
        i.status === 'tracking'
          ? {
              ...i,
              latitude: jitterCoord(i.latitude, 0.0004),
              longitude: jitterCoord(i.longitude, 0.0004),
              lastUpdated: new Date().toISOString(),
            }
          : i
      );
      itemsRef.current = next;
      setItems(next);
      await AsyncStorage.setItem(STORAGE_ITEMS, JSON.stringify(next));

      const now = Date.now();
      if (
        settings.notificationsEnabled &&
        settings.notifyOnLocationUpdate &&
        now - lastBulkNotify.current > 120_000
      ) {
        lastBulkNotify.current = now;
        await sendImmediateNotification(
          'Luggage tracking',
          'Live location estimates were updated for your tagged items.'
        );
      }
    }, 50_000);
    return () => clearInterval(id);
  }, [
    settings.simulateMovement,
    settings.notificationsEnabled,
    settings.notifyOnLocationUpdate,
  ]);

  const value = useMemo(
    () => ({
      items,
      settings,
      loading,
      addItem,
      removeItem,
      setSettings,
    }),
    [items, settings, loading, addItem, removeItem, setSettings]
  );

  return (
    <LuggageContext.Provider value={value}>{children}</LuggageContext.Provider>
  );
}

export function useLuggage() {
  const ctx = useContext(LuggageContext);
  if (!ctx) throw new Error('useLuggage must be used within LuggageProvider');
  return ctx;
}
