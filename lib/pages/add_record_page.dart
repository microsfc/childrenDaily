import 'dart:io';
import '../models/baby_record.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../services/firestore_service.dart';
import 'package:image_picker/image_picker.dart';

class AddRecordPage extends StatefulWidget {
  const AddRecordPage({super.key});
  static const routeName = '/add_record';

  @override
  State<AddRecordPage> createState() => _AddRecordPageState();
}

class _AddRecordPageState extends State<AddRecordPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDay;
  File? _selectedImage;
  final _noteController = TextEditingController();
  final _tagsController = TextEditingController();
  final _vaccController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  Future<void> _pickDate() async {
    DateTime now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() {
        _selectedDay = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveRecord() async {
    if (_formKey.currentState!.validate() && _selectedDay != null) {
      final storageService =
          Provider.of<StorageService>(context, listen: false);
      final firestoreService =
          Provider.of<FirestoreService>(context, listen: false);
      // 如果有照片，先上傳到 Firebase Storage
      final photoUrl = _selectedImage != null
          ? await storageService.uploadFile(_selectedImage!)
          : '';
      final List<String> tagsLst = _tagsController.text.isNotEmpty
          ? _tagsController.text.split(',').map((e) => e.trim()).toList()
          : [];

      final babyRecord = BabyRecord(
          id: '',
          date: _selectedDay!,
          photoUrl: photoUrl ?? '',
          vaccineStatus: _vaccController.text,
          height: _heightController.text,
          weight: _weightController.text,
          note: _noteController.text,
          tags: tagsLst);
      // 將紀錄存入 Firestore
      await firestoreService.addOrUpdateRecord(babyRecord);
      // 回到上一頁或是跳轉到其他頁面
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('請選擇日期並輸入紀錄'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新增寶寶紀錄'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(
                    _selectedDay == null
                        ? '請選擇日期'
                        : '日期: ${_selectedDay!.year}/${_selectedDay!.month}/${_selectedDay!.day}',
                  ),
                  const SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: _pickDate,
                    child: const Text('選擇日期'),
                  ),
                ]),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    _selectedImage == null
                        ? const Text('請選擇照片')
                        : Image.file(
                            _selectedImage!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                    SizedBox(width: 16.0),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('選擇照片'),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                // Vaccine Status
                TextFormField(
                  controller: _vaccController,
                  decoration: InputDecoration(
                    labelText: '疫苗狀態',
                    errorMaxLines: 2,
                    prefixIcon: const Icon(Icons.medical_services),
                  ),
                  autofillHints: const [AutofillHints.username],
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.multiline,
                ),
                // Weight
                TextFormField(
                  controller: _weightController,
                  decoration: InputDecoration(
                    labelText: '體重 (kg)',
                    errorMaxLines: 2,
                    prefixIcon: const Icon(Icons.medical_services),
                  ),
                  autofillHints: const [AutofillHints.username],
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                ),
                // Height
                TextFormField(
                  controller: _heightController,
                  decoration: InputDecoration(
                    labelText: '身高 (cm)',
                    errorMaxLines: 2,
                    prefixIcon: const Icon(Icons.medical_services),
                  ),
                  autofillHints: const [AutofillHints.username],
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16.0),
                // Note
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: '備註',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '請輸入紀錄';
                    }
                    return null;
                  },
                ),
                // Tag
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: '標籤 (以逗號分隔)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // 儲存按鈕
                Center(
                  child: ElevatedButton(
                    onPressed: _saveRecord,
                    child: const Text('儲存'),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
