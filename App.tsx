import { useEffect, useCallback } from 'react';
import {
  NavigationContainer,
  createNavigationContainerRef,
} from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { StatusBar } from 'expo-status-bar';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import * as Notifications from 'expo-notifications';
import { LuggageProvider } from './src/context/LuggageContext';
import HomeScreen from './src/screens/HomeScreen';
import MapScreen from './src/screens/MapScreen';
import AddLuggageScreen from './src/screens/AddLuggageScreen';
import SettingsScreen from './src/screens/SettingsScreen';
import { colors } from './src/constants/theme';
import { ensureAndroidChannel } from './src/hooks/useNotifications';
import type { RootTabParamList } from './src/navigation/types';

const Tab = createBottomTabNavigator();
const navigationRef = createNavigationContainerRef<RootTabParamList>();

export default function App() {

  useEffect(() => {
    ensureAndroidChannel().catch(() => {});
  }, []);

  const onNotificationOpen = useCallback(() => {
    if (navigationRef.isReady()) {
      navigationRef.navigate('Map');
    }
  }, []);

  useEffect(() => {
    const sub = Notifications.addNotificationResponseReceivedListener(() => {
      onNotificationOpen();
    });
    return () => sub.remove();
  }, [onNotificationOpen]);

  return (
    <SafeAreaProvider>
      <LuggageProvider>
        <NavigationContainer ref={navigationRef}>
          <StatusBar style="dark" />
          <Tab.Navigator
            screenOptions={{
              headerStyle: { backgroundColor: colors.surface },
              headerTitleStyle: { fontWeight: '700', color: colors.text },
              headerShadowVisible: false,
              tabBarActiveTintColor: colors.primaryDark,
              tabBarInactiveTintColor: colors.textMuted,
              tabBarStyle: {
                backgroundColor: colors.surface,
                borderTopColor: colors.border,
              },
            }}
          >
            <Tab.Screen
              name="Home"
              component={HomeScreen}
              options={{
                title: 'Luggage',
                tabBarIcon: ({ color, size }) => (
                  <MaterialCommunityIcons name="bag-suitcase" color={color} size={size} />
                ),
              }}
            />
            <Tab.Screen
              name="Map"
              component={MapScreen}
              options={{
                title: 'Map',
                tabBarIcon: ({ color, size }) => (
                  <MaterialCommunityIcons name="map-marker-radius" color={color} size={size} />
                ),
              }}
            />
            <Tab.Screen
              name="Add"
              component={AddLuggageScreen}
              options={{
                title: 'Add tag',
                tabBarIcon: ({ color, size }) => (
                  <MaterialCommunityIcons name="plus-circle-outline" color={color} size={size} />
                ),
              }}
            />
            <Tab.Screen
              name="Settings"
              component={SettingsScreen}
              options={{
                title: 'Settings',
                tabBarIcon: ({ color, size }) => (
                  <MaterialCommunityIcons name="cog-outline" color={color} size={size} />
                ),
              }}
            />
          </Tab.Navigator>
        </NavigationContainer>
      </LuggageProvider>
    </SafeAreaProvider>
  );
}
