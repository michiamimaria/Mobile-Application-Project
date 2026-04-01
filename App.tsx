import { useEffect, useCallback, useMemo, useState } from 'react';
import {
  NavigationContainer,
  createNavigationContainerRef,
} from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { StatusBar } from 'expo-status-bar';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import * as Notifications from 'expo-notifications';
import { ActivityIndicator, Platform, View } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { LuggageProvider } from './src/context/LuggageContext';
import HomeScreen from './src/screens/HomeScreen';
import MapScreen from './src/screens/MapScreen';
import AddLuggageScreen from './src/screens/AddLuggageScreen';
import SettingsScreen from './src/screens/SettingsScreen';
import AuthScreen from './src/screens/AuthScreen';
import { colors } from './src/constants/theme';
import { ensureAndroidChannel } from './src/hooks/useNotifications';
import type { RootTabParamList } from './src/navigation/types';

const Tab = createBottomTabNavigator();
const navigationRef = createNavigationContainerRef<RootTabParamList>();
const STORAGE_ACCOUNTS = '@auth/accounts';
const STORAGE_SESSION = '@auth/session';

type Account = {
  name: string;
  email: string;
  password: string;
};

export default function App() {
  const [accounts, setAccounts] = useState<Account[]>([]);
  const [sessionEmail, setSessionEmail] = useState<string | null>(null);
  const [loadingAuth, setLoadingAuth] = useState(true);

  useEffect(() => {
    ensureAndroidChannel().catch(() => {});
  }, []);

  const onNotificationOpen = useCallback(() => {
    if (navigationRef.isReady()) {
      navigationRef.navigate('Map');
    }
  }, []);

  useEffect(() => {
    if (Platform.OS === 'web') return;
    const sub = Notifications.addNotificationResponseReceivedListener(() => {
      onNotificationOpen();
    });
    return () => sub.remove();
  }, [onNotificationOpen]);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const [rawAccounts, rawSession] = await Promise.all([
          AsyncStorage.getItem(STORAGE_ACCOUNTS),
          AsyncStorage.getItem(STORAGE_SESSION),
        ]);
        if (cancelled) return;
        const parsed = rawAccounts ? (JSON.parse(rawAccounts) as Account[]) : [];
        setAccounts(parsed);
        setSessionEmail(rawSession ?? null);
      } finally {
        if (!cancelled) setLoadingAuth(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  const persistAccounts = useCallback(async (next: Account[]) => {
    setAccounts(next);
    await AsyncStorage.setItem(STORAGE_ACCOUNTS, JSON.stringify(next));
  }, []);

  const signIn = useCallback(
    async (email: string, password: string) => {
      const match = accounts.find(
        (a) => a.email.toLowerCase() === email.toLowerCase() && a.password === password
      );
      if (!match) return false;
      setSessionEmail(match.email);
      await AsyncStorage.setItem(STORAGE_SESSION, match.email);
      return true;
    },
    [accounts]
  );

  const createAccount = useCallback(
    async (name: string, email: string, password: string) => {
      const exists = accounts.some((a) => a.email.toLowerCase() === email.toLowerCase());
      if (exists) return false;
      const next: Account[] = [...accounts, { name, email, password }];
      await persistAccounts(next);
      setSessionEmail(email);
      await AsyncStorage.setItem(STORAGE_SESSION, email);
      return true;
    },
    [accounts, persistAccounts]
  );

  const signOut = useCallback(async () => {
    setSessionEmail(null);
    await AsyncStorage.removeItem(STORAGE_SESSION);
  }, []);

  const activeUserName = useMemo(() => {
    if (!sessionEmail) return '';
    return accounts.find((a) => a.email === sessionEmail)?.name ?? '';
  }, [accounts, sessionEmail]);

  if (loadingAuth) {
    return (
      <SafeAreaProvider>
        <View style={styles.loaderWrap}>
          <ActivityIndicator color={colors.primary} size="large" />
        </View>
      </SafeAreaProvider>
    );
  }

  return (
    <SafeAreaProvider>
      {sessionEmail ? (
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
                tabBarLabelStyle: { fontSize: 12, fontWeight: '600' },
                tabBarStyle: {
                  position: 'absolute',
                  left: 14,
                  right: 14,
                  bottom: 12,
                  borderRadius: 16,
                  height: 62,
                  paddingBottom: 6,
                  paddingTop: 6,
                  backgroundColor: colors.surface,
                  borderTopColor: colors.border,
                  borderWidth: 1,
                  shadowColor: '#0F172A',
                  shadowOffset: { width: 0, height: 4 },
                  shadowOpacity: 0.1,
                  shadowRadius: 10,
                  elevation: 6,
                },
              }}
            >
              <Tab.Screen
                name="Home"
                component={HomeScreen}
                options={{
                  title: activeUserName ? `Luggage - ${activeUserName}` : 'Luggage',
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
                options={{
                  title: 'Settings',
                  tabBarIcon: ({ color, size }) => (
                    <MaterialCommunityIcons name="cog-outline" color={color} size={size} />
                  ),
                }}
              >
                {() => <SettingsScreen onSignOut={signOut} />}
              </Tab.Screen>
            </Tab.Navigator>
          </NavigationContainer>
        </LuggageProvider>
      ) : (
        <AuthScreen onSignIn={signIn} onCreateAccount={createAccount} />
      )}
    </SafeAreaProvider>
  );
}

const styles = {
  loaderWrap: {
    flex: 1,
    backgroundColor: colors.background,
    alignItems: 'center' as const,
    justifyContent: 'center' as const,
  },
};
