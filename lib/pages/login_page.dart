import 'home_page.dart';
import '../di/locator.dart';
import '../state/auth_state.dart';
import '../widgets/app_button.dart';
import '../widgets/error_dialog.dart';
import 'package:flutter/material.dart';
import '../dialog/register_dialog.dart';
import 'package:provider/provider.dart';
import '../widgets/loading_overlay.dart';
import '../viewmodel/login_viewmodel.dart';


class LoginPage extends StatefulWidget{
  static const routeName = '/login';
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = true;
  late final LoginViewModel _loginViewModel;

  @override
  void initState() {
    super.initState();
    _loginViewModel = locator<LoginViewModel>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  void _showSignUpDialog() {
    showDialog(
      context: context,
      builder: (context) => RegisterDialog(),
    );
  }

  
  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final result = await _loginViewModel.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        if (!mounted) return; // Check if the widget is still mounted
        // Update the auth state with the logged in user
          final authState = Provider.of<AuthState>(context, listen: false);
          authState.setUser(result.data!);
          
        
          // Navigate to home page
          Navigator.of(context).pushReplacementNamed(HomePage.routeName);

        // result.whenSuccess((user) {
        //   // Update the auth state with the logged in user
        //   final authState = Provider.of<AuthState>(context, listen: false);
        //   authState.setUser(user);
        
        //   // Navigate to home page
        //   Navigator.of(context).pushReplacementNamed(HomePage.routeName);
        // });
        // result.whenFailure((error) {
        //   ErrorDialog(errorMessage: error.toString());
        // });
      } catch (error) {
        ErrorDialog(errorMessage: error.toString());
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      final result = await _loginViewModel.loginWithGoogle();
      if (!mounted) return; // Check if the widget is still mounted
      result.whenSuccess((user) {
        // Update the auth state with the logged in user
        final authState = Provider.of<AuthState>(context, listen: false);
        authState.setUser(user);
        
        // Navigate to home page
        Navigator.of(context).pushReplacementNamed(HomePage.routeName);
      });
      result.whenFailure((error) {
        ErrorDialog(errorMessage: error.toString());
      });
    } catch (error) {
      ErrorDialog(errorMessage: error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return ChangeNotifierProvider.value(
      value: _loginViewModel,
      child: Consumer<LoginViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Login'),
            ),
            body: LoadingOverlay(
              isLoading: viewModel.isLoading,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SafeArea(
                  child: Stack(
                    children: [
                       Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child:Container(
                          height: 0.4 * deviceSize.height,
                          color: const Color(0xFF00BFA6),
                        ),
                      ),
                      SingleChildScrollView(
                        child: SizedBox(
                          width: deviceSize.width,
                          height: deviceSize.height,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 0.15 * deviceSize.height),
                              const Image(
                                image: AssetImage('assets/images/milk-bottle.png'),
                                width: 85,
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 20),
                                child: Text("Login",
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: Colors.white,
                                  )),
                              ),
                              SizedBox(height: 0.01 * deviceSize.height),
                              _buildLoginForm()
                            ],
                          ),
                        )
                      )
                    ],
                  ) 
                )
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoginForm() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', 
                  prefixIcon: Icon(Icons.email)),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure 
                          ? Icons.visibility_off 
                          : Icons.visibility,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                obscureText: _isObscure,
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
              SizedBox(height: 20),
              AppButton(
                text: 'LOGIN',
                onPressed: _login,
                icon: Icons.login,
              ),
              const SizedBox(height: 12),
              AppButton(
                text: 'SIGN UP',
                type: AppButtonType.secondary,
                onPressed: _showSignUpDialog,
                icon: Icons.person_add,
              ),
              const SizedBox(height: 12),
              AppButton(
                text: 'SIGN IN WITH GOOGLE',
                type: AppButtonType.secondary,
                onPressed: _loginWithGoogle,
                icon: Icons.g_mobiledata,
              ),
            ],
          ),
        ),
      ),
    );
  }
}