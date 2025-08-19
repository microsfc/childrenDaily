import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:children/models/appuser.dart';
import 'package:children/state/AppState.dart';
import 'package:children/pages/home_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:children/widgets/error_dialog.dart';
import 'package:children/services/auth_service.dart';
import 'package:children/widgets/custom_text_field.dart';

class RegisterDialog extends StatefulWidget {
  const RegisterDialog({super.key});
  @override
  _RegisterDialogState createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();

  String _errorMessage = '';
  final errorDialog = ErrorDialog(errorMessage: '');
  File? _profileImage; // 用來存放上傳的頭像

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // _cropImage(File(pickedFile.path));
      _profileImage = File(pickedFile.path);
    }
  }

  Future<void> _registerWithEmailPassword() async {
    setState(() {
      _errorMessage = ''; // 清空錯誤訊息
    });
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      final AppUser? user = await authService.signUpWithEmailAndPassword(
          _emailController.text,
          _passwordController.text,
          _displayNameController.text,
          _profileImage);
      if (user != null) {
        // ignore: use_build_context_synchronously
        final appState = AppState.of(context);
        appState.setUserId(user.uid);
        appState.setProfileImageUrl(user.profileImageUrl);
        appState.setUser(user);
        appState.setFcmToken(user.fcmToken);
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
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[200],
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : AssetImage('assets/images/default_avatar.png'),
                child: _profileImage == null
                    ? Icon(Icons.camera_alt, color: Colors.grey[800])
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextButton(onPressed: _pickImage, child: Text('選擇頭像')),
            ),
            CustomTextField(
              controller: _emailController,
              label: 'Email',
              hint: '請輸入電子信箱',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _passwordController,
              label: '密碼',
              hint: '請輸入密碼',
              icon: Icons.lock,
              obscureText: true,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _displayNameController,
              label: '顯示名稱',
              hint: '請輸入顯示名稱',
              icon: Icons.person,
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
