import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppState extends ChangeNotifier {
  List<String> selectedRecordIDs = [];
  bool isLoading = false;
  String uid = '';

  void addSelectedRecordID(String id) {
    selectedRecordIDs.add(id);
    notifyListeners();
  }

  void removeSelectedRecordID(String id) {
    selectedRecordIDs.remove(id);
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

  static AppState of(BuildContext context) {
    return Provider.of<AppState>(context, listen: false);
  }
}
