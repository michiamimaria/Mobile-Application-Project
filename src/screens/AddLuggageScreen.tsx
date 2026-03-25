import React, { useState } from 'react';
import {
  Alert,
  Pressable,
  ScrollView,
  StyleSheet,
  Switch,
  Text,
  TextInput,
  View,
} from 'react-native';
import DateTimePicker from '@react-native-community/datetimepicker';
import * as Location from 'expo-location';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useLuggage } from '../context/LuggageContext';
import { colors, luggagePalette } from '../constants/theme';
import type { LuggageStatus } from '../types';

export default function AddLuggageScreen() {
  const { addItem } = useLuggage();
  const [name, setName] = useState('');
  const [color, setColor] = useState(luggagePalette[0]);
  const [status, setStatus] = useState<LuggageStatus>('tracking');
  const [lat, setLat] = useState('41.9965');
  const [lng, setLng] = useState('21.4314');
  const [reminderOn, setReminderOn] = useState(false);
  const [reminder, setReminder] = useState(() => {
    const d = new Date();
    d.setHours(d.getHours() + 2);
    return d;
  });
  const [showPicker, setShowPicker] = useState(false);

  const useMyLocation = async () => {
    const { status } = await Location.requestForegroundPermissionsAsync();
    if (status !== 'granted') {
      Alert.alert(
        'Location needed',
        'Allow location to drop a pin where you are standing (e.g. check-in).'
      );
      return;
    }
    const pos = await Location.getCurrentPositionAsync({
      accuracy: Location.Accuracy.Balanced,
    });
    setLat(pos.coords.latitude.toFixed(6));
    setLng(pos.coords.longitude.toFixed(6));
  };

  const submit = async () => {
    const trimmed = name.trim();
    if (!trimmed) {
      Alert.alert('Name', 'Enter a name for this luggage tag.');
      return;
    }
    const latitude = parseFloat(lat.replace(',', '.'));
    const longitude = parseFloat(lng.replace(',', '.'));
    if (Number.isNaN(latitude) || Number.isNaN(longitude)) {
      Alert.alert('Coordinates', 'Use valid numbers for latitude and longitude.');
      return;
    }
    await addItem({
      name: trimmed,
      color,
      latitude,
      longitude,
      status,
      reminderAt: reminderOn ? reminder.toISOString() : undefined,
    });
    setName('');
    Alert.alert('Saved', 'Luggage tag added. It appears on the map and list.');
  };

  return (
    <ScrollView
      style={styles.container}
      contentContainerStyle={styles.inner}
      keyboardShouldPersistTaps="handled"
    >
      <Text style={styles.heading}>Add luggage tag</Text>
      <Text style={styles.sub}>
        Store a label and starting coordinates. Reminders use local
        notifications on this device.
      </Text>

      <Text style={styles.label}>Name</Text>
      <TextInput
        style={styles.input}
        placeholder="e.g. Blue Samsonite"
        placeholderTextColor={colors.textMuted}
        value={name}
        onChangeText={setName}
      />

      <Text style={styles.label}>Marker color</Text>
      <View style={styles.colors}>
        {luggagePalette.map((c) => (
          <Pressable
            key={c}
            onPress={() => setColor(c)}
            style={[
              styles.colorChip,
              { backgroundColor: c },
              color === c && styles.colorChipActive,
            ]}
          />
        ))}
      </View>

      <Text style={styles.label}>Status</Text>
      <View style={styles.row}>
        {(['tracking', 'idle', 'alert'] as const).map((s) => (
          <Pressable
            key={s}
            onPress={() => setStatus(s)}
            style={[
              styles.pill,
              status === s && styles.pillActive,
            ]}
          >
            <Text
              style={[
                styles.pillText,
                status === s && styles.pillTextActive,
              ]}
            >
              {s}
            </Text>
          </Pressable>
        ))}
      </View>

      <Text style={styles.label}>Starting coordinates</Text>
      <View style={styles.coordRow}>
        <TextInput
          style={[styles.input, styles.coordInput]}
          keyboardType="decimal-pad"
          value={lat}
          onChangeText={setLat}
        />
        <TextInput
          style={[styles.input, styles.coordInput]}
          keyboardType="decimal-pad"
          value={lng}
          onChangeText={setLng}
        />
      </View>
      <Pressable style={styles.locBtn} onPress={useMyLocation}>
        <MaterialCommunityIcons name="crosshairs-gps" size={20} color={colors.primary} />
        <Text style={styles.locBtnText}>Use my current location</Text>
      </Pressable>

      <View style={styles.reminderRow}>
        <Text style={styles.label}>Reminder</Text>
        <Switch value={reminderOn} onValueChange={setReminderOn} />
      </View>
      {reminderOn && (
        <>
          <Pressable
            style={styles.timeBtn}
            onPress={() => setShowPicker(true)}
          >
            <MaterialCommunityIcons name="clock-outline" size={20} color={colors.text} />
            <Text style={styles.timeBtnText}>
              {reminder.toLocaleString(undefined, {
                dateStyle: 'medium',
                timeStyle: 'short',
              })}
            </Text>
          </Pressable>
          {showPicker && (
            <DateTimePicker
              value={reminder}
              mode="datetime"
              display="default"
              onChange={(_, d) => {
                setShowPicker(false);
                if (d) setReminder(d);
              }}
            />
          )}
        </>
      )}

      <Pressable style={styles.save} onPress={submit}>
        <Text style={styles.saveText}>Save luggage tag</Text>
      </Pressable>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  inner: {
    padding: 16,
    paddingBottom: 40,
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
  label: {
    fontSize: 13,
    fontWeight: '600',
    color: colors.text,
    marginBottom: 8,
    marginTop: 4,
  },
  input: {
    backgroundColor: colors.surface,
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: 12,
    paddingHorizontal: 14,
    paddingVertical: 12,
    fontSize: 16,
    color: colors.text,
    marginBottom: 12,
  },
  colors: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 10,
    marginBottom: 12,
  },
  colorChip: {
    width: 36,
    height: 36,
    borderRadius: 18,
    borderWidth: 3,
    borderColor: 'transparent',
  },
  colorChipActive: {
    borderColor: colors.text,
  },
  row: {
    flexDirection: 'row',
    gap: 8,
    marginBottom: 12,
    flexWrap: 'wrap',
  },
  pill: {
    paddingVertical: 8,
    paddingHorizontal: 14,
    borderRadius: 20,
    backgroundColor: colors.surface,
    borderWidth: 1,
    borderColor: colors.border,
  },
  pillActive: {
    backgroundColor: colors.primary,
    borderColor: colors.primary,
  },
  pillText: {
    fontSize: 14,
    color: colors.textMuted,
    textTransform: 'capitalize',
  },
  pillTextActive: {
    color: '#fff',
    fontWeight: '600',
  },
  coordRow: {
    flexDirection: 'row',
    gap: 10,
  },
  coordInput: {
    flex: 1,
    marginBottom: 8,
  },
  locBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginBottom: 16,
  },
  locBtnText: {
    fontSize: 15,
    color: colors.primary,
    fontWeight: '600',
  },
  reminderRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 8,
  },
  timeBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    backgroundColor: colors.surface,
    padding: 14,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: colors.border,
    marginBottom: 20,
  },
  timeBtnText: {
    fontSize: 16,
    color: colors.text,
  },
  save: {
    backgroundColor: colors.primary,
    paddingVertical: 16,
    borderRadius: 14,
    alignItems: 'center',
  },
  saveText: {
    color: '#fff',
    fontSize: 17,
    fontWeight: '700',
  },
});
