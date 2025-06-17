import 'dart:io';
import '../di/locator.dart';
import '../models/baby_record.dart';
import '../widgets/app_button.dart';
import '../utils/error_handler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/loading_overlay.dart';
import 'package:children/models/appuser.dart';
import 'package:children/state/auth_state.dart';
import 'package:image_picker/image_picker.dart';
import '../viewmodel/add_record_viewmodel.dart';



class AddRecordPage extends StatefulWidget {
  final BabyRecord? record;
  
  const AddRecordPage({super.key, this.record});
  
  static const routeName = '/add_record';
  
  @override
  State<AddRecordPage> createState() => _AddRecordPageState();
}

class _AddRecordPageState extends State<AddRecordPage> {
  final _formKey = GlobalKey<FormState>();
  late final AddRecordViewModel _viewModel;
  
  final _noteController = TextEditingController();
  final _tagsController = TextEditingController();
  final _vaccController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _viewModel = locator<AddRecordViewModel>();
    
    if (widget.record != null) {
      _viewModel.setRecord(widget.record!);
      _initializeControllers();
    }
  }
  
  void _initializeControllers() {
    _noteController.text = _viewModel.note;
    _tagsController.text = _viewModel.tags.join(', ');
    _vaccController.text = _viewModel.vaccineStatus;
    _weightController.text = _viewModel.weight;
    _heightController.text = _viewModel.height;
  }
  
  @override
  void dispose() {
    _noteController.dispose();
    _tagsController.dispose();
    _vaccController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }
  
  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _viewModel.selectedDate ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
    );
    
    if (picked != null) {
      _viewModel.setSelectedDate(picked);
    }
  }
  
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      _viewModel.setImageFile(File(pickedFile.path));
    }
  }
  
  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate() || _viewModel.selectedDate == null) {
      ErrorHandler.show(
        context, 
        'Please fill in all required fields and select a date'
      );
      return;
    }
    
    // Update view model with latest values from controllers
    _viewModel.setNote(_noteController.text);
    _viewModel.setVaccineStatus(_vaccController.text);
    _viewModel.setHeight(_heightController.text);
    _viewModel.setWeight(_weightController.text);
    _viewModel.setTags(_tagsController.text);
    
    // Use AuthState to get user ID
    final authState = Provider.of<AuthState>(context, listen: false);
    final userId = authState.currentUser?.uid ?? '';
    
    final record = await _viewModel.saveRecord(userId);
    
    if (record != null) {
      Navigator.of(context).pop(record);
    } else if (_viewModel.error != null) {
      ErrorHandler.show(context, _viewModel.error!);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<AddRecordViewModel>(
        builder: (context, viewModel, _) {
          return LoadingOverlay(
            isLoading: viewModel.isLoading,
            child: Scaffold(
              appBar: AppBar(
                title: Text(widget.record != null ? 'Edit Record' : 'Add Record'),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDatePicker(viewModel),
                      const SizedBox(height: 16),
                      _buildImagePicker(viewModel),
                      const SizedBox(height: 16),
                      _buildFormFields(),
                      const SizedBox(height: 24),
                      _buildSharedUsersList(viewModel),
                      const SizedBox(height: 24),
                      Center(
                        child: AppButton(
                          text: 'Save',
                          onPressed: _saveRecord,
                          icon: Icons.save,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildDatePicker(AddRecordViewModel viewModel) {
    return Row(
      children: [
        Text(
          viewModel.selectedDate == null
              ? 'Select Date:'
              : 'Date: ${_formatDate(viewModel.selectedDate!)}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _pickDate,
          child: const Text('Select Date'),
        ),
      ],
    );
  }
  
  Widget _buildImagePicker(AddRecordViewModel viewModel) {
    return Row(
      children: [
        if (viewModel.imageFile != null)
          Image.file(
            viewModel.imageFile!,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          )
        else if (widget.record?.photoUrl != null && widget.record!.photoUrl.isNotEmpty)
          Image.network(
            widget.record!.photoUrl,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          )
        else
          const Text('No image selected'),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _pickImage,
          child: const Text('Select Photo'),
        ),
      ],
    );
  }
  
  Widget _buildFormFields() {
    return Column(
      children: [
        TextFormField(
          controller: _vaccController,
          decoration: const InputDecoration(
            labelText: 'Note',
            prefixIcon: Icon(Icons.note),
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _weightController,
          decoration: const InputDecoration(
            labelText: 'Weight (kg)',
            prefixIcon: Icon(Icons.monitor_weight),
          ),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _heightController,
          decoration: const InputDecoration(
            labelText: 'Height (cm)',
            prefixIcon: Icon(Icons.height),
          ),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _noteController,
          decoration: const InputDecoration(
            labelText: 'Diary',
            prefixIcon: Icon(Icons.book),
          ),
          maxLines: 4,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a diary entry';
            }
            return null;
          },
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _tagsController,
          decoration: const InputDecoration(
            labelText: 'Tags (separated by comma)',
            prefixIcon: Icon(Icons.tag),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSharedUsersList(AddRecordViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Share with other users:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // We would use a StreamBuilder here to get users from Firestore
        // This is simplified for example purposes
        FutureBuilder<List<AppUser>>(
          future: _fetchUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No users available to share with');
            }
            
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final user = snapshot.data![index];
                
                return SwitchListTile(
                  title: Text(user.displayName),
                  subtitle: Text(user.email),
                  value: viewModel.sharedIds.contains(user.uid),
                  onChanged: (value) {
                    viewModel.setTags(user.uid);
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }
  
  // This would typically be handled by a repository/service in a real app
  Future<List<AppUser>> _fetchUsers() async {
    // Placeholder implementation - this would pull from your UserRepository
    return [];
  }
}