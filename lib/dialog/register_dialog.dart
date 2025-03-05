import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:children/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:children/widgets/error_dialog.dart';
import 'package:children/services/auth_service.dart';

class RegisterDialog extends StatefulWidget {
  const RegisterDialog({super.key});
  @override
  _RegisterDialogState createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  final errorDialog = ErrorDialog(errorMessage: '');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registerWithEmailPassword() async {
    setState(() {
      _errorMessage = ''; // 清空錯誤訊息
    });
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
     final User? user = await authService.signUpWithEmailAndPassword(
                      _emailController.text, _passwordController.text);
     if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('註冊成功，請登入')),
        );
        Navigator.of(context).pop(); // 註冊成功後關閉 Dialog
        Navigator.of(context).pushNamed(HomePage.routeName);
    } 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('註冊'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: '密碼'),
              obscureText: true,
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('取消'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: Text('註冊'),
          onPressed: _registerWithEmailPassword,
        ),
      ],
    );
  }
}