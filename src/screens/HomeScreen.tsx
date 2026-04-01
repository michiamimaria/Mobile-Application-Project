import React from 'react';
import {
  ActivityIndicator,
  FlatList,
  Platform,
  Pressable,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useLuggage } from '../context/LuggageContext';
import { colors } from '../constants/theme';
import type { LuggageItem } from '../types';

function formatTime(iso: string) {
  try {
    return new Date(iso).toLocaleString(undefined, {
      dateStyle: 'short',
      timeStyle: 'short',
    });
  } catch {
    return iso;
  }
}

function statusLabel(s: LuggageItem['status']) {
  switch (s) {
    case 'tracking':
      return 'Live tracking';
    case 'alert':
      return 'Attention';
    default:
      return 'Idle';
  }
}

function trackerLabel(item: LuggageItem) {
  return item.trackerType === 'airTag' ? 'AirTag' : 'Luggage tag';
}

export default function HomeScreen() {
  const { items, loading, removeItem } = useLuggage();
  const trackingCount = items.filter((i) => i.status === 'tracking').length;
  const alertCount = items.filter((i) => i.status === 'alert').length;

  if (loading) {
    return (
      <View style={styles.centered}>
        <ActivityIndicator size="large" color={colors.primary} />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Text style={styles.heading}>Your luggage</Text>
      <Text style={styles.sub}>
        Tagged bags and last known map positions. Pull the map tab to see all
        markers together.
      </Text>
      <View style={styles.metricsRow}>
        <View style={styles.metricCard}>
          <Text style={styles.metricValue}>{items.length}</Text>
          <Text style={styles.metricLabel}>Total tags</Text>
        </View>
        <View style={styles.metricCard}>
          <Text style={styles.metricValue}>{trackingCount}</Text>
          <Text style={styles.metricLabel}>Tracking</Text>
        </View>
        <View style={styles.metricCard}>
          <Text style={styles.metricValue}>{alertCount}</Text>
          <Text style={styles.metricLabel}>Alerts</Text>
        </View>
      </View>
      <FlatList
        data={items}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.list}
        ListEmptyComponent={
          <View style={styles.empty}>
            <MaterialCommunityIcons
              name="bag-suitcase-off-outline"
              size={48}
              color={colors.textMuted}
            />
            <Text style={styles.emptyTitle}>No luggage yet</Text>
            <Text style={styles.emptySub}>
              Add a tag from the Add tab to start tracking on the map.
            </Text>
          </View>
        }
        renderItem={({ item }) => (
          <View style={styles.card}>
            <View style={[styles.dot, { backgroundColor: item.color }]} />
            <View style={styles.cardBody}>
              <Text style={styles.cardTitle}>{item.name}</Text>
              <Text style={styles.cardTag}>{trackerLabel(item)}</Text>
              <Text style={styles.cardMeta}>
                {statusLabel(item.status)} · {formatTime(item.lastUpdated)}
              </Text>
              <Text style={styles.coords}>
                {item.latitude.toFixed(4)}, {item.longitude.toFixed(4)}
              </Text>
            </View>
            <Pressable
              onPress={() => removeItem(item.id)}
              hitSlop={12}
              style={({ pressed }) => [
                styles.trash,
                pressed && { opacity: 0.6 },
              ]}
            >
              <MaterialCommunityIcons
                name="trash-can-outline"
                size={22}
                color={colors.danger}
              />
            </Pressable>
          </View>
        )}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
    paddingTop: 16,
    paddingHorizontal: 16,
  },
  centered: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: colors.background,
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
    marginBottom: 16,
    lineHeight: 20,
  },
  list: {
    paddingBottom: 24,
    gap: 12,
  },
  metricsRow: {
    flexDirection: 'row',
    gap: 8,
    marginBottom: 14,
  },
  metricCard: {
    flex: 1,
    backgroundColor: colors.surface,
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: 12,
    paddingVertical: 10,
    alignItems: 'center',
  },
  metricValue: {
    fontSize: 20,
    fontWeight: '700',
    color: colors.primaryDark,
    lineHeight: 24,
  },
  metricLabel: {
    marginTop: 2,
    fontSize: 12,
    color: colors.textMuted,
    fontWeight: '600',
  },
  card: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.surface,
    borderRadius: 14,
    padding: 14,
    borderWidth: 1,
    borderColor: colors.border,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.06,
    shadowRadius: 4,
    elevation: Platform.OS === 'android' ? 2 : 0,
  },
  dot: {
    width: 12,
    height: 12,
    borderRadius: 6,
    marginRight: 12,
  },
  cardBody: {
    flex: 1,
  },
  cardTitle: {
    fontSize: 17,
    fontWeight: '600',
    color: colors.text,
  },
  cardMeta: {
    fontSize: 13,
    color: colors.textMuted,
    marginTop: 2,
  },
  cardTag: {
    fontSize: 12,
    color: colors.primary,
    marginTop: 2,
    fontWeight: '600',
  },
  coords: {
    fontSize: 12,
    color: colors.primaryDark,
    marginTop: 4,
    fontVariant: ['tabular-nums'],
  },
  trash: {
    padding: 4,
  },
  empty: {
    alignItems: 'center',
    paddingVertical: 48,
    paddingHorizontal: 24,
  },
  emptyTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: colors.text,
    marginTop: 12,
  },
  emptySub: {
    fontSize: 14,
    color: colors.textMuted,
    textAlign: 'center',
    marginTop: 8,
    lineHeight: 20,
  },
});
