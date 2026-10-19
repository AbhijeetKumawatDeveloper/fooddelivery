import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_core/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shared_core/features/auth/presentation/cubit/auth_state.dart';
import 'package:shared_core/features/auth/presentation/screens/register_screen.dart';
import 'package:shared_core/features/restaurants/presentation/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  void _fillDemo(String email, String pass) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = pass;
    });
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(
      text: _emailController.text,
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter your email address and we will send you a link to reset your password.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: resetEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE23744),
              ),
              onPressed: () {
                final email = resetEmailController.text.trim();
                if (email.isNotEmpty) {
                  context.read<AuthCubit>().forgotPassword(email);
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Password reset email sent if account exists.',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Send Link'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Brand Header (Zomato-style)
              Container(
                height: 220,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE23744), Color(0xFFD32F2F)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(25),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.delivery_dining,
                        size: 42,
                        color: Color(0xFFE23744),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'FoodGo',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "India's #1 Food Delivery & Dining Platform",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: BlocConsumer<AuthCubit, AuthState>(
                  listener: (context, state) {
                    if (state.status == AuthStatus.failure &&
                        state.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.errorMessage!),
                          backgroundColor: Colors.red.shade700,
                        ),
                      );
                    } else if (state.status == AuthStatus.authenticated) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state.status == AuthStatus.loading;

                    return Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Sign In or Sign Up',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Enter your email credentials to continue',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Quick 1-Tap Demo Credentials (Zomato multi-role)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.bolt,
                                      size: 16,
                                      color: Color(0xFFE23744),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Quick 1-Tap Demo Logins:',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF475569),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    ActionChip(
                                      avatar: const Icon(
                                        Icons.person,
                                        size: 14,
                                        color: Color(0xFFE23744),
                                      ),
                                      label: const Text(
                                        'Customer',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                      onPressed: () => _fillDemo(
                                        'customer@foodgo.com',
                                        'password123',
                                      ),
                                    ),
                                    ActionChip(
                                      avatar: const Icon(
                                        Icons.storefront,
                                        size: 14,
                                        color: Color(0xFFE65100),
                                      ),
                                      label: const Text(
                                        'Restaurant',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                      onPressed: () => _fillDemo(
                                        'partner@foodgo.com',
                                        'password123',
                                      ),
                                    ),
                                    ActionChip(
                                      avatar: const Icon(
                                        Icons.two_wheeler,
                                        size: 14,
                                        color: Color(0xFF00897B),
                                      ),
                                      label: const Text(
                                        'Rider',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                      onPressed: () => _fillDemo(
                                        'driver@foodgo.com',
                                        'password123',
                                      ),
                                    ),
                                    ActionChip(
                                      avatar: const Icon(
                                        Icons.admin_panel_settings,
                                        size: 14,
                                        color: Color(0xFF1E293B),
                                      ),
                                      label: const Text(
                                        'Admin',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                      onPressed: () => _fillDemo(
                                        'admin@foodgo.com',
                                        'password123',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Email Input
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            enabled: !isLoading,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: Color(0xFFE23744),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@') ||
                                  !value.contains('.')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Password Input
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            enabled: !isLoading,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Color(0xFFE23744),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: isLoading
                                  ? null
                                  : _showForgotPasswordDialog,
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Color(0xFFE23744),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Sign In Button
                          SizedBox(
                            height: 52,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFE23744),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: isLoading ? null : _onLoginPressed,
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Continue',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Divider: OR
                          Row(
                            children: [
                              Expanded(
                                child: Divider(color: Colors.grey.shade300),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  'or continue with',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(color: Colors.grey.shade300),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Social Logins
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    _fillDemo(
                                      'google.user@foodgo.com',
                                      'password123',
                                    );
                                    _onLoginPressed();
                                  },
                                  icon: const Icon(
                                    Icons.g_mobiledata,
                                    size: 24,
                                    color: Colors.red,
                                  ),
                                  label: const Text('Google'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    _fillDemo(
                                      'apple.user@foodgo.com',
                                      'password123',
                                    );
                                    _onLoginPressed();
                                  },
                                  icon: const Icon(
                                    Icons.apple,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                  label: const Text('Apple'),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Sign Up Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              GestureDetector(
                                onTap: isLoading
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const RegisterScreen(),
                                          ),
                                        );
                                      },
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Color(0xFFE23744),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
