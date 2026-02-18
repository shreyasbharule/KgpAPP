import 'package:flutter/material.dart';
import 'package:login_app_page/app/features/auth/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.authService,
    required this.onLoggedIn,
    required this.demoMode,
    required this.onToggleDemoMode,
  });

  final AuthService authService;
  final VoidCallback onLoggedIn;
  final bool demoMode;
  final ValueChanged<bool> onToggleDemoMode;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'student@university.edu');
  final _passwordController = TextEditingController(text: 'StudentPass123!');
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await widget.authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      widget.onLoggedIn();
    } catch (_) {
      setState(() {
        _error = 'Unable to sign in. Verify credentials or contact support.';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'University Student App',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.demoMode ? 'Demo Mode enabled' : 'Live backend mode',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SwitchListTile(
                      value: widget.demoMode,
                      onChanged: widget.onToggleDemoMode,
                      title: const Text('Demo Mode'),
                      subtitle: const Text('Use local fixture data instead of backend APIs'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Institutional email'),
                      validator: (value) =>
                          (value == null || !value.contains('@')) ? 'Enter valid email' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password'),
                      validator: (value) =>
                          (value == null || value.length < 8) ? 'Minimum 8 characters' : null,
                    ),
                    const SizedBox(height: 20),
                    if (_error != null)
                      Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Sign in'),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Demo users: student@university.edu / StudentPass123!,\nfaculty@university.edu / FacultyPass123!, admin@university.edu / AdminPass123!',
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
