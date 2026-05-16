import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../widgets/custom_input.dart';
import 'task_list_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoginMode = true;
  bool _processingState = false;

  void _processAuthentication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _processingState = true);
    final user = ParseUser(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
      _isLoginMode ? null : _emailController.text.trim(),
    );

    final ParseResponse response = _isLoginMode
        ? await user.login()
        : await user.signUp();

    setState(() => _processingState = false);

    if (response.success) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TaskListScreen()),
      );
    } else {
      if (!mounted) return;
      AlertUtility.showNotice(
        context,
        response.error?.message ?? "Authentication failed.",
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.assignment_turned_in_rounded,
                  size: 72,
                  color: colors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  _isLoginMode ? "Welcome Back" : "Register Workspace Account",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                CustomInputField(
                  controller: _usernameController,
                  label: "Username",
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (val) =>
                      val!.trim().isEmpty ? "Username cannot be blank" : null,
                ),
                if (!_isLoginMode) ...[
                  const SizedBox(height: 16),
                  CustomInputField(
                    controller: _emailController,
                    label: "Student Email",
                    prefixIcon: Icons.alternate_email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => !val!.contains('@')
                        ? "Please enter a valid institutional address"
                        : null,
                  ),
                ],
                const SizedBox(height: 16),
                CustomInputField(
                  controller: _passwordController,
                  label: "Password",
                  prefixIcon: Icons.lock_open_outlined,
                  obscureText: true,
                  validator: (val) => val!.length < 6
                      ? "Password must contain at least 6 characters"
                      : null,
                ),
                const SizedBox(height: 28),
                _processingState
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _processAuthentication,
                        child: Text(
                          _isLoginMode ? "Sign In" : "Register Credentials",
                        ),
                      ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() => _isLoginMode = !_isLoginMode),
                  child: Text(
                    _isLoginMode
                        ? "Create an account"
                        : "Already have an account? Login",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
