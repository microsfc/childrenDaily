import '../models/baby_record.dart';
import 'package:flutter/material.dart';
import '../repositories/baby_record_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecordsState extends ChangeNotifier {
  final BabyRecordRepository _repository;
  
  List<BabyRecord> _records = [];
  List<String> _selectedRecordIDs = [];
  bool _isLoading = false;
  String? _error;
  DocumentSnapshot? _lastDocument;
  bool _hasMoreData = true;
  
  RecordsState(this._repository);
  
  // Getters
  List<BabyRecord> get records => _records;
  List<String> get selectedRecordIDs => _selectedRecordIDs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreData => _hasMoreData;
  
  // Selection methods
  void selectRecord(String id) {
    if (!_selectedRecordIDs.contains(id)) {
      _selectedRecordIDs.add(id);
      notifyListeners();
    }
  }
  
  void unselectRecord(String id) {
    if (_selectedRecordIDs.contains(id)) {
      _selectedRecordIDs.remove(id);
      notifyListeners();
    }
  }
  
  void clearSelection() {
    if (_selectedRecordIDs.isNotEmpty) {
      _selectedRecordIDs.clear();
      notifyListeners();
    }
  }
  
  // Data loading
  Future<void> loadInitialRecords(String userId) async {
    _isLoading = true;
    _error = null;
    _records = [];
    _lastDocument = null;
    _hasMoreData = true;
    notifyListeners();
    try {
      final batch = await _repository.getRecordsBatch(uid: userId, limit: 10);
 
      _records = batch.records;
      _hasMoreData = batch.lastDocument != null;
      _lastDocument = batch.lastDocument;
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadMoreRecords(String userId) async {
    if (_isLoading || !_hasMoreData) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final batch = await _repository.getRecordsBatch(
        uid: userId, 
        limit: 10,
        lastDocument: _lastDocument
      );
      
      _records.addAll(batch.records);
      _hasMoreData = batch.lastDocument != null;
      _lastDocument = batch.lastDocument;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getRecordsForDate(String userId, DateTime date) async {
    _isLoading = true;
    _error = null;
    _records = [];
    _lastDocument = null;
    _hasMoreData = true;
    notifyListeners();
    
    try {
      final batch = await _repository.getRecordsByDate(userId, date);
      _records = batch;
      _hasMoreData = batch.length >= 10; // Assuming 10 is the limit for pagination
      
      if (batch.isNotEmpty) {
        // This is a simplification - in reality, you would need to get the actual document reference
        _lastDocument = null; // You'd need to set this from your repository
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  
  Future<void> searchRecords(String userId, String keyword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      if (keyword.isEmpty) {
        await loadInitialRecords(userId);
      } else {
        _records = await _repository.searchRecords(userId, keyword);
        _hasMoreData = false; // No pagination for search results
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> deleteSelectedRecords() async {
    if (_selectedRecordIDs.isEmpty) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      await _repository.deleteMultipleRecords(_selectedRecordIDs);
      
      // Remove deleted records from the list
      _records.removeWhere((record) => _selectedRecordIDs.contains(record.id));
      _selectedRecordIDs.clear();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}