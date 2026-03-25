import React, { useState } from 'react';
import {
  Pressable,
  StyleSheet,
  Switch,
  Text,
  View,
} from 'react-native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useLuggage } from '../context/LuggageContext';
import { colors } from '../constants/theme';
import { requestNotificationPermissions } from '../hooks/useNotifications';

export default function SettingsScreen() {
  const { settings, setSettings } = useLuggage();
  const [permissionHint, setPermissionHint] = useState<string | null>(null);

  const requestPerms = async () => {
    const ok = await requestNotificationPermissions();
    setPermissionHint(
      ok
        ? 'Notifications are allowed. Scheduled reminders will fire at the chosen time.'
        : 'Permission denied. Enable notifications in system settings for this app.'
    );
  };

  return (
    <View style={styles.container}>
      <Text style={styles.heading}>Notifications & tracking</Text>
      <Text style={styles.sub}>
        Local reminders and optional alerts when simulated positions refresh
        (demo mode for moving tags).
      </Text>

      <View style={styles.card}>
        <View style={styles.row}>
          <View style={styles.rowText}>
            <Text style={styles.title}>Enable notifications</Text>
            <Text style={styles.desc}>
              Required for reminders and tracking alerts on this device.
            </Text>
          </View>
          <Switch
            value={settings.notificationsEnabled}
            onValueChange={(v) => setSettings({ notificationsEnabled: v })}
          />
        </View>

        <View style={styles.divider} />

        <View style={styles.row}>
          <View style={styles.rowText}>
            <Text style={styles.title}>Alert on location refresh</Text>
            <Text style={styles.desc}>
              Throttled message when live simulation updates coordinates.
            </Text>
          </View>
          <Switch
            value={settings.notifyOnLocationUpdate}
            onValueChange={(v) => setSettings({ notifyOnLocationUpdate: v })}
            disabled={!settings.notificationsEnabled}
          />
        </View>

        <View style={styles.divider} />

        <View style={styles.row}>
          <View style={styles.rowText}>
            <Text style={styles.title}>Simulate movement</Text>
            <Text style={styles.desc}>
              Gently drift markers to demo map updates without hardware tags.
            </Text>
          </View>
          <Switch
            value={settings.simulateMovement}
            onValueChange={(v) => setSettings({ simulateMovement: v })}
          />
        </View>
      </View>

      <Pressable style={styles.btn} onPress={requestPerms}>
        <MaterialCommunityIcons name="bell-ring-outline" size={22} color="#fff" />
        <Text style={styles.btnText}>Request notification permission</Text>
      </Pressable>

      {permissionHint && (
        <Text style={styles.hint}>{permissionHint}</Text>
      )}

      <View style={styles.note}>
        <MaterialCommunityIcons name="information-outline" size={20} color={colors.textMuted} />
        <Text style={styles.noteText}>
          Pairing with Bluetooth or airline APIs would need a backend service.
          This app stores tags locally and uses maps plus scheduled local
          notifications.
        </Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
    padding: 16,
  },
  heading: {
    fontSize: 24,
    fontWeight: '700',
    color: colors.text,
    marginBottom: 4,
  },
  sub: {
    fontSize: 14,
    color: colors.textMuted,
    marginBottom: 20,
    lineHeight: 20,
  },
  card: {
    backgroundColor: colors.surface,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: colors.border,
    padding: 4,
    marginBottom: 20,
  },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 12,
    paddingHorizontal: 12,
    gap: 12,
  },
  rowText: {
    flex: 1,
  },
  title: {
    fontSize: 16,
    fontWeight: '600',
    color: colors.text,
  },
  desc: {
    fontSize: 13,
    color: colors.textMuted,
    marginTop: 4,
    lineHeight: 18,
  },
  divider: {
    height: 1,
    backgroundColor: colors.border,
    marginHorizontal: 8,
  },
  btn: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 10,
    backgroundColor: colors.primaryDark,
    paddingVertical: 14,
    borderRadius: 12,
  },
  btnText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  hint: {
    fontSize: 14,
    color: colors.text,
    marginTop: 14,
    lineHeight: 20,
  },
  note: {
    flexDirection: 'row',
    gap: 10,
    marginTop: 28,
    padding: 14,
    backgroundColor: colors.surface,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: colors.border,
  },
  noteText: {
    flex: 1,
    fontSize: 13,
    color: colors.textMuted,
    lineHeight: 18,
  },
});
