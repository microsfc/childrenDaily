import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:children/helper/button.dart';
import 'package:children/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:children/widgets/error_dialog.dart';
import 'package:children/services/auth_service.dart';

const childPrimaryColor = Color(0xFF00BFA6);

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  static const routeName = '/login';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: Colors.deepPurple,
        body: SafeArea(
            child: Stack(children: [
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Container(
              height: 0.4 * deviceSize.height,
              color: childPrimaryColor,
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
                  SizedBox(
                    height: 0.15 * deviceSize.height,
                  ),
                  const Image(
                      image: AssetImage('assets/images/milk-bottle.png'), width: 85),
                  Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: Text("Login",
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                          ))),
                  SizedBox(
                    height: 0.01 * deviceSize.height,
                  ),
                  AuthCard(),
                ],
              ),
            ),
          )
        ])));
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({super.key});
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  bool isObscure = true;
  bool confirmIsObscure = true;

  final errorDialog = ErrorDialog();

  final GlobalKey<FormState> _formKey = GlobalKey();
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  var _isLoading = false;
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // void _resetTextfields() {
  //   _emailController.clear();
  //   _passwordController.clear();
  // }


  void _resetTextfields() {
    _emailController.clear();
    _passwordController.clear();
  }

  void _signUp() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final User? user = await authService.signUpWithEmailAndPassword(
        _emailController.text, _passwordController.text);
    if (!mounted) return;
    if (user != null) {
      Navigator.of(context).pushNamed(HomePage.routeName);
    } else {
      if (!mounted) return;
      errorDialog.showErrorDialog(context, 'Sign up with Email and Passowrd failed');
    }
  }

  void _signInWithGoogle() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final User? user = await authService.signInWithGoogle();
    if (!mounted) return;
    if (user != null) {
        Navigator.of(context).pushNamed(HomePage.routeName);
    } else {
      if (!mounted) return;
      errorDialog.showErrorDialog(context, 'Sign in with Google failed');
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      authService
          .signInWithEmailAndPassword(
              _emailController.text, _passwordController.text)
          .then((value) {
        if (value != null) {
          Navigator.of(context).pushNamed(HomePage.routeName);
        } else {
          if (!mounted) return;
          errorDialog.showErrorDialog(context, 'Login failed');
        }
      });
    } catch (e) {
      if (!mounted) return;
      errorDialog.showErrorDialog(context, 'Login failed = ${e.toString()}');
    }

    print(_authData);
    setState(() {
      _isLoading = false;
    });
  }

  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        height: 450,
        constraints: BoxConstraints(
          minHeight: 450,
        ),
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'E-Mail'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@')) {
                    return 'Invalid email!';
                  }
                  return null;
                },
                onSaved: (value) {
                  _authData['email'] = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                controller: _passwordController,
                validator: (value) {
                  if (value!.isEmpty || value.length < 5) {
                    return 'Password is too short!';
                  }
                  return null;
                },
                onSaved: (value) {
                  _authData['password'] = value!;
                },
              ),
              SizedBox(
                height: 20,
              ),
              if (_isLoading)
                CircularProgressIndicator()
              else
                MyButtons(
                  text: 'LOGIN',
                  onTap: _submit,
                ),
              MyButtons(onTap: _signUp, text: 'Sign Up'),
              MyButtons(onTap: _signInWithGoogle, text: 'Sign In With Google')
            ],
          ),
        ),
      ),
    );
  }
}
