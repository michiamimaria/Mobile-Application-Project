import React, { useState } from 'react';
import {
  Alert,
  KeyboardAvoidingView,
  Platform,
  Pressable,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { colors } from '../constants/theme';

type AuthMode = 'signIn' | 'create';

type Props = {
  onSignIn: (email: string, password: string) => Promise<boolean>;
  onCreateAccount: (name: string, email: string, password: string) => Promise<boolean>;
};

export default function AuthScreen({ onSignIn, onCreateAccount }: Props) {
  const [mode, setMode] = useState<AuthMode>('signIn');
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const submit = async () => {
    const cleanEmail = email.trim().toLowerCase();
    if (mode === 'create' && !name.trim()) {
      Alert.alert('Missing name', 'Enter your full name.');
      return;
    }
    if (!cleanEmail || !cleanEmail.includes('@')) {
      Alert.alert('Invalid email', 'Enter a valid email address.');
      return;
    }
    if (password.length < 4) {
      Alert.alert('Weak password', 'Use at least 4 characters.');
      return;
    }

    if (mode === 'create') {
      const ok = await onCreateAccount(name.trim(), cleanEmail, password);
      if (!ok) {
        Alert.alert('Account exists', 'An account with that email already exists.');
      }
      return;
    }

    const ok = await onSignIn(cleanEmail, password);
    if (!ok) {
      Alert.alert('Login failed', 'Wrong email or password.');
    }
  };

  return (
    <KeyboardAvoidingView
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      style={styles.container}
    >
      <View style={styles.card}>
        <View style={styles.brandRow}>
          <View style={styles.brandIcon}>
            <MaterialCommunityIcons name="bag-personal-tag" size={22} color={colors.primaryDark} />
          </View>
          <Text style={styles.brandCaption}>Travel smart</Text>
        </View>
        <Text style={styles.title}>Luggage Checker</Text>
        <Text style={styles.sub}>Sign in or create an account to continue.</Text>

        <View style={styles.modeRow}>
          <Pressable
            onPress={() => setMode('signIn')}
            style={[styles.modePill, mode === 'signIn' && styles.modePillActive]}
          >
            <Text style={[styles.modeText, mode === 'signIn' && styles.modeTextActive]}>
              Sign in
            </Text>
          </Pressable>
          <Pressable
            onPress={() => setMode('create')}
            style={[styles.modePill, mode === 'create' && styles.modePillActive]}
          >
            <Text style={[styles.modeText, mode === 'create' && styles.modeTextActive]}>
              Create account
            </Text>
          </Pressable>
        </View>

        {mode === 'create' && (
          <>
            <Text style={styles.label}>Name</Text>
            <TextInput
              style={styles.input}
              value={name}
              onChangeText={setName}
              placeholder="Your name"
              placeholderTextColor={colors.textMuted}
            />
          </>
        )}

        <Text style={styles.label}>Email</Text>
        <TextInput
          style={styles.input}
          value={email}
          onChangeText={setEmail}
          placeholder="you@example.com"
          autoCapitalize="none"
          keyboardType="email-address"
          placeholderTextColor={colors.textMuted}
        />

        <Text style={styles.label}>Password</Text>
        <TextInput
          style={styles.input}
          value={password}
          onChangeText={setPassword}
          placeholder="••••••"
          secureTextEntry
          placeholderTextColor={colors.textMuted}
        />

        <Pressable style={styles.submitBtn} onPress={submit}>
          <Text style={styles.submitText}>
            {mode === 'create' ? 'Create account' : 'Log in'}
          </Text>
        </Pressable>
      </View>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
    justifyContent: 'center',
    padding: 16,
  },
  card: {
    width: '100%',
    maxWidth: 460,
    alignSelf: 'center',
    backgroundColor: colors.surface,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: colors.border,
    padding: 18,
    shadowColor: '#0F172A',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.08,
    shadowRadius: 14,
    elevation: 4,
  },
  brandRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginBottom: 8,
  },
  brandIcon: {
    width: 34,
    height: 34,
    borderRadius: 17,
    backgroundColor: '#CCFBF1',
    alignItems: 'center',
    justifyContent: 'center',
  },
  brandCaption: {
    fontSize: 13,
    color: colors.primaryDark,
    fontWeight: '700',
  },
  title: {
    fontSize: 26,
    fontWeight: '700',
    color: colors.text,
  },
  sub: {
    marginTop: 4,
    marginBottom: 16,
    fontSize: 14,
    color: colors.textMuted,
  },
  modeRow: {
    flexDirection: 'row',
    gap: 8,
    marginBottom: 12,
  },
  modePill: {
    flex: 1,
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: 10,
    alignItems: 'center',
    paddingVertical: 10,
    backgroundColor: colors.background,
  },
  modePillActive: {
    backgroundColor: colors.primary,
    borderColor: colors.primary,
  },
  modeText: {
    color: colors.textMuted,
    fontWeight: '600',
  },
  modeTextActive: {
    color: '#fff',
  },
  label: {
    fontSize: 13,
    color: colors.text,
    fontWeight: '600',
    marginBottom: 6,
  },
  input: {
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: 12,
    backgroundColor: colors.background,
    paddingHorizontal: 12,
    paddingVertical: 11,
    color: colors.text,
    marginBottom: 12,
  },
  submitBtn: {
    marginTop: 4,
    backgroundColor: colors.primaryDark,
    borderRadius: 12,
    alignItems: 'center',
    paddingVertical: 14,
  },
  submitText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '700',
  },
});
