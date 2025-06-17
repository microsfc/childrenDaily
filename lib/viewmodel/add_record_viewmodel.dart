import 'dart:io';
import '../models/baby_record.dart';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'package:children/models/measurement.dart';
import '../repositories/baby_record_repository.dart';
import '../repositories/measurement_repository.dart';


class AddRecordViewModel with ChangeNotifier {
  final BabyRecordRepository _babyRecordRepository;
  final MeasurementRepository _measurementRepository;
  final StorageService _storageService;

  bool _isLoading = false;
  String? _error;
  BabyRecord? _record;
  DateTime? _selectedDate;
  File? _imageFile;
  String _note = '';
  String _vaccineStatus = '';
  String _height = '';
  String _weight = '';
  List<String> _tags = [];
  List<String> _sharedIds = [];

  AddRecordViewModel(this._babyRecordRepository, this._measurementRepository, this._storageService);

  bool get isLoading => _isLoading;
  String? get error => _error;
  BabyRecord? get record => _record;
  DateTime? get selectedDate => _selectedDate;
  File? get imageFile => _imageFile;
  String get note => _note;
  String get vaccineStatus => _vaccineStatus;
  String get height => _height;
  String get weight => _weight;
  List<String> get tags => _tags;
  List<String> get sharedIds => _sharedIds;

  // Setters
  void setRecord(BabyRecord record) {
    _record = record;
    _selectedDate = record.date;
    // ignore: unnecessary_null_comparison
    //_imageFile = record.photoUrl != null ? File(record.photoUrl) : null;
    _note = record.note;
    _vaccineStatus = record.vaccineStatus;
    _height = record.height;
    _weight = record.weight;
    _tags = List.from(record.tags);
    _sharedIds = List.from(record.sharedIds);
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }
  void setImageFile(File? file) {
    _imageFile = file;
    notifyListeners();
  }
  void setNote(String note) {
    _note = note;
    notifyListeners();
  }
  void setVaccineStatus(String status) {
    _vaccineStatus = status;
    notifyListeners();
  }
  void setHeight(String height) {
    _height = height;
    notifyListeners();
  }
  void setWeight(String weight) {
    _weight = weight;
    notifyListeners();
  }
  void setTags(String tags) {
    if (tags.isEmpty) {
      _tags = [];
    } else {
      _tags = tags.split(',').map((tag) => tag.trim()).toList();
    }
    notifyListeners();
    
  }
  void toggleShareUser(String userId) {
    if (_sharedIds.contains(userId)) {
      _sharedIds.remove(userId);
    } else {
      _sharedIds.add(userId);
    }
    notifyListeners();
  }
  

  Future<BabyRecord> saveRecord(String uid) async {
    if (_selectedDate == null) {
      _error = 'Please select a date.';
      notifyListeners();
      throw Exception(_error);
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Step 1 Upload the image if it exists
      String? photoUrl;
      if (_imageFile != null) {
        photoUrl = await _storageService.uploadFile(_imageFile!);
      } else {
        photoUrl = _record?.photoUrl; // Use existing photo URL if available
      }
      // Step 2 Create or update the record
      final record = BabyRecord(
        id: _record?.id ?? '',
        uid: uid,
        date: _selectedDate ?? DateTime.now(),
        photoUrl: photoUrl ?? '',
        note: _note,
        tags: _tags,
        vaccineStatus: _vaccineStatus,
        height: _height,
        weight: _weight,
        sharedIds: _sharedIds,
      );

      final savedRecord = await _babyRecordRepository.addOrUpdateRecord(record);
      // Step 3 Update or Create new measurement
      if (_height.isNotEmpty || _weight.isNotEmpty) {
        double heightValue = double.tryParse(_height) ?? 0.0;
        double weightValue = double.tryParse(_weight) ?? 0.0;

        if (heightValue > 0 || weightValue > 0) {
          final measurement = Measurement(
            id: '', // Will be set by repository
            uid: uid,
            date: _selectedDate ?? DateTime.now(),
            height: heightValue,
            weight: weightValue,
          );
          await _measurementRepository.addOrUpdateMeasurement(measurement);
        }
      }
      _record = savedRecord;
      _isLoading = false;
      notifyListeners();
      return savedRecord;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}