import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:children/models/appuser.dart';

class AppState extends ChangeNotifier {
  List<String> selectedRecordIDs = [];
  bool isLoading = false;
  String uid = '';
  AppUser? currentUser;
  String profileImageDownloadUrl = '';
  String fcmToken = '';

  void addSelectedRecordID(String id) {
    selectedRecordIDs.add(id);
    notifyListeners();
  }

  void removeSelectedRecordID(String id) {
    selectedRecordIDs.remove(id);
    notifyListeners();
  }

  void setFcmToken(String? token) {
    fcmToken = token!;
    notifyListeners();
  }
  void setIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void setUserId(String value) {
    uid = value;
    notifyListeners();
  }

  void setUser(AppUser user) {
    currentUser = user;
    notifyListeners();

  }

  void setProfileImageUrl(String url) {
    profileImageDownloadUrl = url;
    notifyListeners();
  } 

  static AppState of(BuildContext context) {
    return Provider.of<AppState>(context, listen: false);
  }
}
