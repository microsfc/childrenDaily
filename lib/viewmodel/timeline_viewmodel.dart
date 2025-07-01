import '../models/baby_record.dart';
import 'package:flutter/material.dart';
import 'package:children/utils/type.dart';
import '../repositories/baby_record_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TimelineViewModel extends ChangeNotifier {
  final BabyRecordRepository _repository;
  
  List<BabyRecord> _records = [];
  bool _isLoading = false;
  String? _error;
  DocumentSnapshot? _lastDocument;
  bool _hasMoreData = true;
  String _searchKeyword = '';
  final List<String> _selectedIds = [];
  
  TimelineViewModel(this._repository);
  
  // Getters
  List<BabyRecord> get records => _records;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreData => _hasMoreData;
  String get searchKeyword => _searchKeyword;
  List<String> get selectedIds => _selectedIds;
  bool get hasSelectedRecords => _selectedIds.isNotEmpty;
  
  void setSearchKeyword(String keyword) {
    _searchKeyword = keyword;
    notifyListeners();
  }
  
  void addSelectedId(String id) {
    if (!_selectedIds.contains(id)) {
      _selectedIds.add(id);
      notifyListeners();
    }
  }
  
  void removeSelectedId(String id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
      notifyListeners();
    }
  }
  
  void clearSelectedIds() {
    _selectedIds.clear();
    notifyListeners();
  }
  
  Future<void> loadRecords(String userId) async {
    Ref<DocumentSnapshot> ref;
  
    _isLoading = true;
    _error = null;
    _records = [];
    _lastDocument = null;
    _hasMoreData = true;
    notifyListeners();
    
    try {
      if (_searchKeyword.isEmpty) {
        final batch = await _repository.getRecordsBatch(uid: userId, limit: 10, lastDocument: _lastDocument);
        
        _records = batch.records;
        _lastDocument = batch.lastDocument;
        _hasMoreData = batch.lastDocument != null;
      } else {
        _records = await _repository.searchRecords(userId, _searchKeyword);
        _hasMoreData = false;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadMoreRecords(String userId) async {
    if (_isLoading || !_hasMoreData || _searchKeyword.isNotEmpty) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final batch = await _repository.getRecordsBatch(
        uid: userId, 
        limit: 10,
        lastDocument: _lastDocument
      );
      
      _records.addAll(batch.records);
      _lastDocument = batch.lastDocument;
      _hasMoreData = batch.lastDocument != null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> searchRecords(String userId) async {
    _isLoading = true;
    _error = null;
    _records = [];
    notifyListeners();
    
    try {
      if (_searchKeyword.isEmpty) {
        await loadRecords(userId);
      } else {
        _records = await _repository.searchRecords(userId, _searchKeyword);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> deleteSelectedRecords() async {
    if (_selectedIds.isEmpty) return false;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      await _repository.deleteMultipleRecords(_selectedIds);
      
      // Remove from local list
      _records.removeWhere((record) => _selectedIds.contains(record.id));
      _selectedIds.clear();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}