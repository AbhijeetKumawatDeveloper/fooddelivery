import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_core/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shared_core/features/auth/presentation/cubit/auth_state.dart';
import 'package:shared_core/features/restaurants/presentation/screens/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  String _selectedRole = 'customer';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().register(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Create Account',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
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
                      'Join FoodGo Today',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Experience food ordering, restaurant tools, and fast delivery',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Role Selection (Zomato multi-role)
                    const Text(
                      'I am joining as a:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Customer 🛍️'),
                            selected: _selectedRole == 'customer',
                            selectedColor: const Color(0xFFFEE2E2),
                            onSelected: (val) {
                              if (val) setState(() => _selectedRole = 'customer');
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Partner 🏪'),
                            selected: _selectedRole == 'partner',
                            selectedColor: const Color(0xFFFEE2E2),
                            onSelected: (val) {
                              if (val) setState(() => _selectedRole = 'partner');
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Rider 🛵'),
                            selected: _selectedRole == 'rider',
                            selectedColor: const Color(0xFFFEE2E2),
                            onSelected: (val) {
                              if (val) setState(() => _selectedRole = 'rider');
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Name
                    TextFormField(
                      controller: _nameController,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: Color(0xFFE23744),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email
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
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password
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
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscurePassword,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(
                          Icons.lock_reset,
                          color: Color(0xFFE23744),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    // Submit Button
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFE23744),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isLoading ? null : _onRegisterPressed,
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
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        GestureDetector(
                          onTap: isLoading ? null : () => Navigator.pop(context),
                          child: const Text(
                            'Sign In',
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
      ),
    );
  }
}
