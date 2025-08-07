import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:children/ui/theme.dart';
import 'package:provider/provider.dart';
import 'package:children/di/locator.dart';
import 'package:children/state/auth_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:children/models/baby_record.dart';
import 'package:children/utils/error_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:children/widgets/loading_overlay.dart';
import 'package:children/viewmodel/share_viewmodel.dart';
import 'package:children/pages/zoomable_photo_page.dart';
import 'package:children/repositories/user_repository.dart';
import 'package:children/viewmodel/add_record_viewmodel.dart';
import 'package:cached_network_image/cached_network_image.dart';

  
class RecordDetailScreen extends StatefulWidget {
  final BabyRecord record;
  static const routeName = '/record_detail';

  const RecordDetailScreen({super.key, required this.record});

  @override
  _RecordDetailScreenState createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends State<RecordDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _saveButtonController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _floatAnimation;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _diaryController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  List<String> _tags = [];
  late String photoUrl;
  late String heroTag;
  late final AddRecordViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = locator<AddRecordViewModel>();
    // 初始化動畫控制器
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _saveButtonController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _saveButtonController,
      curve: Curves.easeInOut,
    ));
    
    // 初始化數據
    _initializeData();
    
    // 啟動動畫
    _animationController.forward();
    _saveButtonController.repeat(reverse: true);
  }

  void _initializeData() {
    _viewModel.setRecord(widget.record);
    _titleController.text = widget.record.vaccineStatus;
    _diaryController.text = widget.record.note;
    _heightController.text = widget.record.height.toString();
    _weightController.text = widget.record.weight.toString();
    _selectedDate = widget.record.date;
    photoUrl = widget.record.photoUrl;
    heroTag = 'recordPhoto_${widget.record.id}';
    _tags = List.from(widget.record.tags);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _saveButtonController.dispose();
    _titleController.dispose();
    _diaryController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.lightTheme.colorScheme.secondary,
              AppTheme.lightTheme.primaryColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildStatusBar(),
              _buildHeader(),
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingSaveButton(),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      height: 44,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "2:28",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              Icon(Icons.signal_cellular_4_bar, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Icon(Icons.wifi, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Icon(Icons.battery_full, color: Colors.white, size: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -50 * (1 - _fadeAnimation.value)),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFff9a9e), Color(0xFFfecfef)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFff9a9e).withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ).createShader(bounds),
                    child: Text(
                      "成長記錄詳情",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<AddRecordViewModel>(
        builder: (context, viewModel, _) {
          return LoadingOverlay(
            isLoading: viewModel.isLoading,
            child:
            AnimatedBuilder(
                  animation: _slideAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPhotoSection(),
                              SizedBox(height: 30),
                              _buildFormCard(),
                              SizedBox(height: 30),
                              _buildSharedUsersList(viewModel),
                              SizedBox(height: 30),
                              _buildActionButtons(),
                              SizedBox(height: 100), // 為浮動按鈕留出空間
                            ],
                          ),
                        ),
                      ),
                    );
                  },
            )
          );
        },
      ),
    );
  }

Widget _buildPhotoSection() {
  return Container(
    width: double.infinity,
    height: 350,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 15,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          // 背景漸變層
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFff9a9e).withOpacity(0.3),
                  Color(0xFFfecfef).withOpacity(0.3),
                ],
              ),
            ),
          ),
          
          // 圖片顯示區域
          if (photoUrl.isNotEmpty)
            Positioned.fill(
              child: Hero(
                tag: heroTag,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ZoomablePhotoPage(
                          imageUrl: photoUrl,
                          heroTag: heroTag,
                          isLocalFile: _isLocalFile(photoUrl),
                        ),
                      ),
                    );
                  },
                  child: _buildImageWidget(),
                ),
              ),
            ),
          
          // 如果沒有圖片，顯示佔位符
          if (photoUrl.isEmpty)
            Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 60,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "點擊添加照片",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // 相機按鈕 - 浮動在右下角
          Positioned(
            bottom: 15,
            right: 15,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.photo_camera,
                  size: 24,
                  color: Colors.white,
                ),
                onPressed: _pickImage,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// 圖片顯示 Widget
Widget _buildImageWidget() {
  if (_isLocalFile(photoUrl)) {
    // 本地文件使用 Image.file
    return Image.file(
      File(photoUrl),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 50, color: Colors.grey[600]),
                SizedBox(height: 8),
                Text(
                  "圖片載入失敗",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      },
    );
  } else {
    // 網路圖片使用 CachedNetworkImage
    return CachedNetworkImage(
      imageUrl: photoUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => Container(
        color: Colors.grey[100],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
              ),
              SizedBox(height: 16),
              Text(
                "載入中...",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 50, color: Colors.grey[600]),
              SizedBox(height: 8),
              Text(
                "圖片載入失敗",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 判斷是否為本地文件
bool _isLocalFile(String path) {
  if (path.isEmpty) return false;
  
  // 檢查是否為本地路徑
  return path.startsWith('/') || 
         path.startsWith('file://') || 
         (path.contains('/data/') && File(path).existsSync());
}

// 更新的 _pickImage 方法
Future<void> _pickImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 1920,
    maxHeight: 1920,
    imageQuality: 85,
  );
  
  if (pickedFile != null) {
    _viewModel.setImageFile(File(pickedFile.path));
    
    // 立即更新UI顯示本地圖片
    setState(() {
      photoUrl = pickedFile.path; // 使用本地路徑
    });
    
    // 添加觸覺反饋
    HapticFeedback.selectionClick();
  }
 }

// 修復後的 _buildSharedUsersList 方法
Widget _buildSharedUsersList(AddRecordViewModel viewModel) {
  return ChangeNotifierProvider<ShareViewModel>(
    create: (_) => ShareViewModel(userRepository: FirestoreUserRepository(FirebaseFirestore.instance)),
    builder: (context, child) {
      final vm = context.watch<ShareViewModel>();
      vm.sharedUserIds = viewModel.sharedIds.toSet();

      return Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🤝 分享給其他使用者:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2c3e50),
              ),
            ),
            SizedBox(height: 15),
            // 使用 Container 代替 Expanded，設定固定高度
            Container(
              height: vm.users.isEmpty ? 100 : (vm.users.length * 70.0).clamp(100.0, 250.0),
              decoration: BoxDecoration(
                color: Color(0xFFf8f9fa),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Color(0xFFe9ecef), width: 1),
              ),
              child: vm.users.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "載入中...",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(8),
                      itemCount: vm.users.length,
                      itemBuilder: (context, index) {
                        final user = vm.users[index];
                        final isShared = vm.sharedUserIds.contains(user.uid);
                        return Container(
                          margin: EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: isShared 
                                ? Color(0xFF667eea).withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SwitchListTile(
                            title: Text(
                              user.displayName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isShared ? FontWeight.w600 : FontWeight.normal,
                                color: isShared ? Color(0xFF667eea) : Color(0xFF2c3e50),
                              ),
                            ),
                            value: isShared,
                            activeColor: Color(0xFF667eea),
                            onChanged: (newValue) {
                              HapticFeedback.selectionClick();
                              vm.toggleShared(user.uid, newValue);
                              viewModel.toggleShareUser(user.uid);
                            },
                            dense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    },
  );
}

 Widget _buildFormCard() {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.95),
      borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormField(
            label: "📅 記錄日期",
            child: GestureDetector(
              onTap: () => _selectDate(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 7, 49, 90),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Color.fromARGB(255, 1, 8, 15), width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}",
                      style: TextStyle(fontSize: 16),
                    ),
                    Icon(Icons.calendar_today, color: Color(0xFF667eea)),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          _buildFormField(
            label: "📝 記錄標題",
            child: _buildTextField(_titleController, "輸入今天的活動..."),
          ),
          SizedBox(height: 20),
          _buildFormField(
            label: "📖 成長日記",
            child: _buildTextArea(_diaryController, "記錄今天的美好時光..."),
          ),
          SizedBox(height: 20),
          _buildMeasurementSection(),
          SizedBox(height: 20),
          _buildTagsSection(),
        ],
      ),
    );
  }

  Widget _buildFormField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 7, 49, 90)
          ),
        ),
        SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: Color.fromARGB(255, 7, 49, 90),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color.fromARGB(255, 1, 8, 15), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(0xFF667eea), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(0xFFe9ecef), width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }

  Widget _buildTextArea(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: Color.fromARGB(255, 2, 23, 43),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(0xFFe9ecef), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(0xFF667eea), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(0xFFe9ecef), width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }

  Widget _buildMeasurementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "📏 身高體重",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2c3e50),
          ),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildMeasurementCard("📏", _heightController.text, "公分 (cm)", () => _editMeasurement("身高", _heightController))),
            SizedBox(width: 15),
            Expanded(child: _buildMeasurementCard("⚖️", _weightController.text, "公斤 (kg)", () => _editMeasurement("體重", _weightController))),
          ],
        ),
      ],
    );
  }

  Widget _buildMeasurementCard(String icon, String value, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFf8f9fa), Color(0xFFe9ecef)],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border(
            top: BorderSide(color: Color(0xFFff9a9e), width: 3),
          ),
        ),
        child: Column(
          children: [
            Text(icon, style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2c3e50),
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6c757d),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "🏷️ 標籤",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2c3e50),
          ),
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ..._tags.map((tag) => _buildTag(tag)).toList(),
            _buildAddTagButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _tags.remove(tag);
              });
            },
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                Icons.close,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTagButton() {
    return GestureDetector(
      onTap: _addTag,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Color(0xFF667eea).withOpacity(0.1),
          border: Border.all(color: Color(0xFF667eea), width: 2),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          "+ 新增標籤",
          style: TextStyle(
            color: Color(0xFF667eea),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              _editRecord();
            },
            icon: Icon(Icons.edit, color: Colors.white),
            label: Text("編輯", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 8,
            ).copyWith(
              backgroundColor: MaterialStateProperty.all(Color(0xFF667eea)),
            ),
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.heavyImpact();
              _deleteRecord();
            },
            icon: Icon(Icons.delete, color: Colors.white),
            label: Text("刪除", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 8,
            ).copyWith(
              backgroundColor: MaterialStateProperty.all(Color(0xFFff6b6b)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingSaveButton() {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_floatAnimation.value),
          child: FloatingActionButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              _saveRecord();
            },
            backgroundColor: Color(0xFFff9a9e),
            elevation: 8,
            child: Icon(Icons.save, color: Colors.white),
          ),
        );
      },
    );
  }

  // 事件處理方法
  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text("拍照"),
              onTap: () {
                Navigator.pop(context);
                // 實現拍照功能
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text("從相簿選擇"),
              onTap: () {
                Navigator.pop(context);
                // 實現選擇照片功能
              },
            ),
          ],
        ),
      ),
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _viewModel.setSelectedDate(_selectedDate);
      });
    }
  }

  void _editMeasurement(String type, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("編輯$type"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: type,
            suffixText: type == "身高" ? "cm" : "kg",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("取消"),
          ),
          TextButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: Text("確定"),
          ),
        ],
      ),
    );
  }

  void _addTag() {
    showDialog(
      context: context,
      builder: (context) {
        String newTag = "";
        return AlertDialog(
          title: Text("新增標籤"),
          content: TextField(
            onChanged: (value) => newTag = value,
            decoration: InputDecoration(
              hintText: "輸入標籤名稱",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("取消"),
            ),
            TextButton(
              onPressed: () {
                if (newTag.isNotEmpty && !_tags.contains(newTag)) {
                  setState(() {
                    _tags.add(newTag);
                  });
                }
                Navigator.pop(context);
              },
              child: Text("確定"),
            ),
          ],
        );
      },
    );
  }

  void _editRecord() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("進入編輯模式")),
    );
  }

  void _deleteRecord() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("確認刪除"),
        content: Text("確定要刪除這條成長記錄嗎？"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("取消"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // 返回上一頁
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("記錄已刪除")),
              );
            },
            child: Text("刪除", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveRecord() async {
    // Update view model with latest values from controllers
    _viewModel.setNote(_diaryController.text);
    _viewModel.setVaccineStatus(_titleController.text);
    _viewModel.setHeight(_heightController.text);
    _viewModel.setWeight(_weightController.text);
    _viewModel.setTags(_tags);
    // Use AuthState to get user ID
    final authState = Provider.of<AuthState>(context, listen: false);
    final userId = authState.currentUser?.uid ?? '';
    
    final record = await _viewModel.saveRecord(userId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("記錄已保存！"),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );

    if (!mounted) return;
    Navigator.of(context).pop(record);
  }
}