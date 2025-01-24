import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppState extends ChangeNotifier {
  List<String> selectedRecordIDs = [];
  bool isLoading = false;

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

  static AppState of(BuildContext context) {
    return Provider.of<AppState>(context, listen: false);
  }
}
