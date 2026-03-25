import React, { useEffect, useRef } from 'react';
import {
  Platform,
  Pressable,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import MapView, { Marker, PROVIDER_GOOGLE, Region } from 'react-native-maps';
import * as Location from 'expo-location';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useLuggage } from '../context/LuggageContext';
import { colors } from '../constants/theme';

const DEFAULT_REGION: Region = {
  latitude: 41.9965,
  longitude: 21.4314,
  latitudeDelta: 0.35,
  longitudeDelta: 0.35,
};

export default function MapScreen() {
  const { items } = useLuggage();
  const mapRef = useRef<MapView>(null);

  useEffect(() => {
    if (items.length === 0 || !mapRef.current) return;
    const coords = items.map((i) => ({
      latitude: i.latitude,
      longitude: i.longitude,
    }));
    mapRef.current.fitToCoordinates(coords, {
      edgePadding: { top: 80, right: 40, bottom: 120, left: 40 },
      animated: true,
    });
  }, [items]);

  const centerOnUser = async () => {
    const { status } = await Location.requestForegroundPermissionsAsync();
    if (status !== 'granted') return;
    const pos = await Location.getCurrentPositionAsync({
      accuracy: Location.Accuracy.Balanced,
    });
    const c = {
      latitude: pos.coords.latitude,
      longitude: pos.coords.longitude,
    };
    mapRef.current?.animateToRegion(
      {
        ...c,
        latitudeDelta: 0.08,
        longitudeDelta: 0.08,
      },
      400
    );
  };

  if (Platform.OS === 'web') {
    return (
      <View style={styles.webFallback}>
        <MaterialCommunityIcons
          name="map-marker-off"
          size={56}
          color={colors.textMuted}
        />
        <Text style={styles.webTitle}>Map on native only</Text>
        <Text style={styles.webSub}>
          Run the app in Expo Go on Android or iOS for the interactive map. The
          list tab still shows coordinates.
        </Text>
      </View>
    );
  }

  return (
    <View style={styles.wrap}>
      <MapView
        ref={mapRef}
        style={styles.map}
        initialRegion={DEFAULT_REGION}
        showsUserLocation
        showsMyLocationButton={false}
        provider={Platform.OS === 'android' ? PROVIDER_GOOGLE : undefined}
      >
        {items.map((item) => (
          <Marker
            key={item.id}
            coordinate={{
              latitude: item.latitude,
              longitude: item.longitude,
            }}
            title={item.name}
            description={`Updated ${new Date(item.lastUpdated).toLocaleString()}`}
          >
            <View style={[styles.tagPin, { backgroundColor: item.color }]} />
          </Marker>
        ))}
      </MapView>
      <Pressable style={styles.fab} onPress={centerOnUser}>
        <MaterialCommunityIcons name="crosshairs-gps" size={26} color="#fff" />
      </Pressable>
      <View style={styles.legend}>
        <Text style={styles.legendText}>
          {items.length} tag{items.length === 1 ? '' : 's'} on map
        </Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: { flex: 1 },
  map: { flex: 1 },
  fab: {
    position: 'absolute',
    right: 16,
    bottom: 32,
    width: 52,
    height: 52,
    borderRadius: 26,
    backgroundColor: colors.primary,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 4,
    elevation: 6,
  },
  legend: {
    position: 'absolute',
    left: 16,
    right: 80,
    bottom: 24,
    backgroundColor: 'rgba(255,255,255,0.92)',
    paddingVertical: 8,
    paddingHorizontal: 12,
    borderRadius: 10,
    borderWidth: 1,
    borderColor: colors.border,
  },
  legendText: {
    fontSize: 13,
    color: colors.text,
    fontWeight: '500',
  },
  tagPin: {
    width: 22,
    height: 22,
    borderRadius: 11,
    borderWidth: 3,
    borderColor: '#fff',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.35,
    shadowRadius: 2,
    elevation: 4,
  },
  webFallback: {
    flex: 1,
    backgroundColor: colors.background,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 24,
  },
  webTitle: {
    fontSize: 20,
    fontWeight: '700',
    color: colors.text,
    marginTop: 16,
  },
  webSub: {
    fontSize: 15,
    color: colors.textMuted,
    textAlign: 'center',
    marginTop: 8,
    lineHeight: 22,
  },
});
