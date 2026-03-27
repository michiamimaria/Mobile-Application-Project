import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/brand_hero_icon.dart';

/// Called after successful sign-in or account creation.
typedef AuthSuccessCallback = void Function(
  String email, {
  required String displayName,
});

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.onSuccess,
  });

  final AuthSuccessCallback onSuccess;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static const _signIn = 0;
  static const _signUp = 1;

  int _mode = _signIn;
  bool _submitting = false;

  final _signInForm = GlobalKey<FormState>();
  final _signUpForm = GlobalKey<FormState>();

  final _loginEmail = TextEditingController();
  final _loginPassword = TextEditingController();

  final _regName = TextEditingController();
  final _regEmail = TextEditingController();
  final _regPassword = TextEditingController();
  final _regConfirm = TextEditingController();

  bool _obscureLoginPassword = true;
  bool _obscureRegPassword = true;
  bool _obscureRegConfirm = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _loginEmail.dispose();
    _loginPassword.dispose();
    _regName.dispose();
    _regEmail.dispose();
    _regPassword.dispose();
    _regConfirm.dispose();
    super.dispose();
  }

  Future<void> _submitSignIn() async {
    if (!(_signInForm.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() => _submitting = false);
    await HapticFeedback.lightImpact();
    if (!mounted) return;
    widget.onSuccess(
      _loginEmail.text.trim(),
      displayName: '',
    );
  }

  Future<void> _submitSignUp() async {
    if (!(_signUpForm.currentState?.validate() ?? false)) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms to continue.'),
        ),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (!mounted) return;
    setState(() => _submitting = false);
    await HapticFeedback.mediumImpact();
    if (!mounted) return;
    widget.onSuccess(
      _regEmail.text.trim(),
      displayName: _regName.text.trim(),
    );
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Text('Demo — use any valid email and password on Sign in.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isSignUp = _mode == _signUp;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary.withValues(alpha: 0.12),
              scheme.primaryContainer.withValues(alpha: 0.38),
              scheme.surface,
              scheme.surfaceContainerLowest,
            ],
            stops: const [0.0, 0.32, 0.68, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Card(
                  elevation: 2,
                  shadowColor: scheme.shadow.withValues(alpha: 0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topCenter,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Semantics(
                            header: true,
                            child: Center(
                              child: BrandHeroIcon(
                                size: 52,
                                color: scheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Luggage Checker',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isSignUp ? 'Create your account' : 'Welcome back',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isSignUp
                                ? 'Create an account to track baggage and save discoveries.'
                                : 'Sign in to continue',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 22),
                          SegmentedButton<int>(
                            segments: const [
                              ButtonSegment<int>(
                                value: _signIn,
                                label: Text('Sign in'),
                                icon: Icon(Icons.login_rounded, size: 18),
                              ),
                              ButtonSegment<int>(
                                value: _signUp,
                                label: Text('Create account'),
                                icon: Icon(Icons.person_add_rounded, size: 18),
                              ),
                            ],
                            selected: {_mode},
                            onSelectionChanged: (s) {
                              if (s.isEmpty) return;
                              HapticFeedback.selectionClick();
                              setState(() => _mode = s.first);
                            },
                            showSelectedIcon: false,
                          ),
                          const SizedBox(height: 22),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 260),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            child: KeyedSubtree(
                              key: ValueKey<int>(_mode),
                              child: isSignUp
                                  ? _buildSignUpForm(scheme)
                                  : _buildSignInForm(scheme),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm(ColorScheme scheme) {
    return Form(
      key: _signInForm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _loginEmail,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.next,
            enabled: !_submitting,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return 'Enter your email';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _loginPassword,
            obscureText: _obscureLoginPassword,
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
            enabled: !_submitting,
            onFieldSubmitted: (_) => _submitSignIn(),
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                tooltip: _obscureLoginPassword ? 'Show' : 'Hide',
                onPressed: _submitting
                    ? null
                    : () => setState(() => _obscureLoginPassword = !_obscureLoginPassword),
                icon: Icon(
                  _obscureLoginPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            validator: (value) {
              final v = value ?? '';
              if (v.isEmpty) return 'Enter your password';
              if (v.length < 6) return 'At least 6 characters';
              return null;
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _submitting ? null : _forgotPassword,
              child: const Text('Forgot password?'),
            ),
          ),
          const SizedBox(height: 6),
          FilledButton(
            onPressed: _submitting ? null : _submitSignIn,
            child: _submitting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text('Sign in'),
          ),
          const SizedBox(height: 14),
          Text(
            'Demo: any email with @ and password 6+ characters.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.outline,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm(ColorScheme scheme) {
    return Form(
      key: _signUpForm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _regName,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            enabled: !_submitting,
            decoration: const InputDecoration(
              labelText: 'Full name',
              hintText: 'How we will greet you',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return 'Enter your name';
              if (v.length < 2) return 'Name is too short';
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _regEmail,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.next,
            enabled: !_submitting,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return 'Enter your email';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _regPassword,
            obscureText: _obscureRegPassword,
            textInputAction: TextInputAction.next,
            enabled: !_submitting,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                tooltip: _obscureRegPassword ? 'Show' : 'Hide',
                onPressed: _submitting
                    ? null
                    : () => setState(() => _obscureRegPassword = !_obscureRegPassword),
                icon: Icon(
                  _obscureRegPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            validator: (value) {
              final v = value ?? '';
              if (v.length < 6) return 'At least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _regConfirm,
            obscureText: _obscureRegConfirm,
            textInputAction: TextInputAction.done,
            enabled: !_submitting,
            onFieldSubmitted: (_) => _submitSignUp(),
            decoration: InputDecoration(
              labelText: 'Confirm password',
              prefixIcon: const Icon(Icons.lock_person_outlined),
              suffixIcon: IconButton(
                tooltip: _obscureRegConfirm ? 'Show' : 'Hide',
                onPressed: _submitting
                    ? null
                    : () => setState(() => _obscureRegConfirm = !_obscureRegConfirm),
                icon: Icon(
                  _obscureRegConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            validator: (value) {
              if ((value ?? '') != _regPassword.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            value: _agreedToTerms,
            onChanged: _submitting
                ? null
                : (v) => setState(() => _agreedToTerms = v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: Text(
              'I agree to the Terms & Privacy (demo)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _submitting ? null : _submitSignUp,
            child: _submitting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text('Create account'),
          ),
          const SizedBox(height: 10),
          Text(
            'Your account is stored only on this device in this demo.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}
