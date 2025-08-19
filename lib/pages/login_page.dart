// login_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import '../di/locator.dart';
import '../state/auth_state.dart';
import '../widgets/error_dialog.dart';
import '../dialog/register_dialog.dart';
import '../widgets/loading_overlay.dart';
import '../viewmodel/login_viewmodel.dart';

// 引入可重用的組件
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import '../widgets/social_button.dart';
import '../widgets/floating_shapes.dart';
import '../widgets/gradient_background.dart';
import '../widgets/logo_section.dart';
import '../widgets/form_container.dart';
import '../widgets/divider_with_text.dart';
import '../utils/form_validators.dart';
import '../mixins/animation_mixin.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with TickerProviderStateMixin, AnimationMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = true;
  late final LoginViewModel _loginViewModel;

  // 定義浮動形狀數據
  static const List<FloatingShapeData> _floatingShapesData = [
    FloatingShapeData(emoji: '👶', delay: 0, top: 80, left: 30),
    FloatingShapeData(emoji: '🎈', delay: 2, top: 200, right: 50),
    FloatingShapeData(emoji: '⭐', delay: 4, bottom: 150, left: 60),
  ];

  @override
  void initState() {
    super.initState();
    _loginViewModel = locator<LoginViewModel>();
    initializeAnimations();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    disposeAnimations();
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
        if (result.error != null) {
          ErrorDialog(errorMessage: result.error!)
              .showErrorDialog(context, result.error!);
          return;
        }
        if (!mounted) return;

        final authState = Provider.of<AuthState>(context, listen: false);
        authState.setUser(result.data!);
        Navigator.of(context).pushReplacementNamed(HomePage.routeName);
      } catch (error) {
        ErrorDialog(errorMessage: error.toString())
            .showErrorDialog(context, error.toString());
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      final result = await _loginViewModel.loginWithGoogle();
      if (!mounted) return;

      result.whenSuccess((user) {
        final authState = Provider.of<AuthState>(context, listen: false);
        authState.setUser(user);
        Navigator.of(context).pushReplacementNamed(HomePage.routeName);
      });

      result.whenFailure((error) {
        ErrorDialog(errorMessage: error.toString())
            .showErrorDialog(context, error.toString());
      });
    } catch (error) {
      ErrorDialog(errorMessage: error.toString())
          .showErrorDialog(context, error.toString());
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
            body: LoadingOverlay(
              isLoading: viewModel.isLoading,
              child: GradientBackground(
                child: SafeArea(
                  child: Stack(
                    children: [
                      // 浮動形狀背景
                      const FloatingShapes(shapes: _floatingShapesData),

                      // 主要內容
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: SizedBox(
                          width: deviceSize.width,
                          height: deviceSize.height -
                              MediaQuery.of(context).padding.top,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Spacer(),

                                // Logo 區域
                                buildAnimatedWidget(
                                  const LogoSection(
                                    icon: Icons.child_care,
                                    title: '成長記錄',
                                    subtitle: '記錄寶貝每個珍貴時刻',
                                  ),
                                ),

                                const SizedBox(height: 40),

                                // 登入表單
                                buildAnimatedWidget(_buildLoginForm()),

                                const Spacer(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoginForm() {
    return FormContainer(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Email 輸入框
            CustomTextField(
              controller: _emailController,
              label: '電子信箱',
              hint: '請輸入您的電子信箱',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: FormValidators.emailValidator,
            ),

            const SizedBox(height: 24),

            // 密碼輸入框
            CustomTextField(
              controller: _passwordController,
              label: '密碼',
              hint: '請輸入密碼',
              icon: Icons.lock_outlined,
              obscureText: _isObscure,
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF4A90E2),
                ),
                onPressed: _togglePasswordVisibility,
              ),
              validator: FormValidators.passwordValidator,
            ),

            const SizedBox(height: 16),

            // 忘記密碼
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: 實作忘記密碼功能
                },
                child: const Text(
                  '忘記密碼？',
                  style: TextStyle(
                    color: Color(0xFF4A90E2),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 登入按鈕
            GradientButton(
              text: '登入',
              onPressed: _login,
              icon: Icons.login,
            ),

            const SizedBox(height: 16),

            // 分隔線
            const DividerWithText(text: '或'),

            const SizedBox(height: 16),

            // 社交登入按鈕
            Row(
              children: [
                Expanded(
                  child: SocialButton(
                    icon: Icons.g_mobiledata,
                    onPressed: _loginWithGoogle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SocialButton(
                    icon: Icons.facebook,
                    onPressed: () {
                      // TODO: Facebook 登入
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SocialButton(
                    icon: Icons.apple,
                    onPressed: () {
                      // TODO: Apple 登入
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 註冊連結
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '還沒有帳號？ ',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                GestureDetector(
                  onTap: _showSignUpDialog,
                  child: const Text(
                    '立即註冊',
                    style: TextStyle(
                      color: Color(0xFF4A90E2),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
