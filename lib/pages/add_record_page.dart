import 'dart:io';
import '../models/baby_record.dart';
import '../models/measurement.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../services/firestore_service.dart';
import 'package:children/state/AppState.dart';
import 'package:children/generated/l10n.dart';
import 'package:children/pages/home_page.dart';
import 'package:image_picker/image_picker.dart';


class AddRecordPage extends StatefulWidget {
  final BabyRecord? record;
  const AddRecordPage({super.key, this.record});
  static const routeName = '/add_record';

  @override
  State<AddRecordPage> createState() => _AddRecordPageState();
}

class _AddRecordPageState extends State<AddRecordPage> {
  
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDay;
  File? _selectedImage;
  String title = '';
  String updateId = '';
  String userId = '';
  final _noteController = TextEditingController();
  final _tagsController = TextEditingController();
  final _vaccController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final appState = AppState.of(context);
    userId = appState.uid;
  }

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
      final appState = AppState.of(context);
      final nav = Navigator.of(context);

      appState.setIsLoading(true);
      try {
        // 如果有照片，先上傳到 Firebase Storage
        final photoUrl = _selectedImage != null
            ? await storageService.uploadFile(_selectedImage!)
            : '';
        final List<String> tagsLst = _tagsController.text.isNotEmpty
            ? _tagsController.text.split(',').map((e) => e.trim()).toList()
            : [];

        final babyRecord = BabyRecord(
            id: '',
            uid: userId,
            date: _selectedDay!,
            photoUrl: photoUrl ?? '',
            vaccineStatus: _vaccController.text,
            height: _heightController.text,
            weight: _weightController.text,
            note: _noteController.text,
            tags: tagsLst);
        // 將紀錄存入 Firestore
        await firestoreService.addOrUpdateRecord(babyRecord);
        final heightWeightMes = Measurement(
            id: updateId,
            uid: userId,
            date: _selectedDay!,
            height: double.tryParse(_heightController.text) ?? 0.0,
            weight: double.tryParse(_weightController.text) ?? 0.0);
        // 將身高體重存入 Firestore
        await firestoreService.addOrUpdateHeightWeight(heightWeightMes);
        appState.setIsLoading(false);
        nav.pop();
      } catch (e) {
        appState.setIsLoading(false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).pleaseSelectDateAndInputRecord),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.record != null) {
      updateId = widget.record!.id;
      _selectedDay = widget.record?.date;
      _vaccController.text = widget.record?.vaccineStatus ?? '';
      _weightController.text = widget.record?.weight ?? '';
      _heightController.text = widget.record?.height ?? '';
      _noteController.text = widget.record?.note ?? '';
      _tagsController.text = widget.record?.tags.join(', ') ?? '';
      title = S.of(context).editBabyRecord;
    } else {
      title = S.of(context).addBabyRecord;
    } 
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.of(context).pushNamed(HomePage.routeName);
          },
        )
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
            key: _formKey,
            child: Consumer<AppState>(builder: (context, appState, child) {
              if (appState.isLoading) {
                return const Center(child: CircularProgressIndicator());
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(
                        _selectedDay == null
                            ? title
                            : '${S.of(context).date}: ${_selectedDay!.year}/${_selectedDay!.month}/${_selectedDay!.day}',
                      ),
                      const SizedBox(width: 16.0),
                      ElevatedButton(
                        onPressed: _pickDate,
                        child: Text(S.of(context).selectDate),
                      ),
                    ]),
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        _selectedImage == null
                            ? Text(S.of(context).pleaseSelectPhoto)
                            : Image.file(
                                _selectedImage!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                        SizedBox(width: 16.0),
                        ElevatedButton(
                          onPressed: _pickImage,
                          child: Text(S.of(context).selectPhoto),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    // Vaccine Status
                    TextFormField(
                      controller: _vaccController,
                      decoration: InputDecoration(
                        labelText: S.of(context).vaccineStatus,
                        errorMaxLines: 2,
                        prefixIcon: const Icon(Icons.location_city),
                      ),
                      autofillHints: const [AutofillHints.username],
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.multiline,
                    ),
                    // Weight
                    TextFormField(
                      controller: _weightController,
                      decoration: InputDecoration(
                        labelText: '${S.of(context).weight} (kg)',
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
                        labelText: '${S.of(context).height} (cm)',
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
                      decoration: InputDecoration(
                        labelText: S.of(context).diary,
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return S.of(context).pleaseInputRecord;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 25.0),
                    // Tag
                    TextFormField(
                      controller: _tagsController,
                      decoration: InputDecoration(
                        labelText: S.of(context).tagSeparator,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 儲存按鈕
                    Center(
                      child: ElevatedButton(
                        onPressed: _saveRecord,
                        child: Text(S.of(context).save),
                      ),
                    ),
                  ],
                );
              }
            })),
      ),
    );
  }
}
