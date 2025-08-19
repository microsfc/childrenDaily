import 'payment_screen.dart';
import 'add_record_page.dart';
import '../../di/locator.dart';
import 'record_detail_page.dart';
import '../../state/auth_state.dart';
import '../widgets/record_tile.dart';
import '../widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import '../../models/baby_record.dart';
import 'package:provider/provider.dart';
import '../widgets/loading_overlay.dart';
import '../viewmodel/timeline_viewmodel.dart';
import 'package:children/pages/login_page.dart';
import 'package:children/pages/RecordDetailScreen.dart';
import 'package:children/widgets/record_card_component.dart';
import 'package:children/widgets/user_profile_edit_dialog.dart';
import '../mixins/animation_mixin.dart';

// ==================== Strategy Pattern for Animation ====================
abstract class AnimationStrategy {
  void startAnimation(AnimationController controller);
}

class SlideInAnimationStrategy implements AnimationStrategy {
  @override
  void startAnimation(AnimationController controller) {
    controller.forward();
  }
}

class StaggeredAnimationStrategy implements AnimationStrategy {
  final int itemCount;
  final List<AnimationController> controllers;

  StaggeredAnimationStrategy(this.itemCount, this.controllers);

  @override
  void startAnimation(AnimationController controller) {
    for (int i = 0; i < controllers.length; i++) {
      Future.delayed(Duration(milliseconds: 200 * (i + 1)), () {
        controllers[i].forward();
      });
    }
  }
}

class TimelinePage extends StatefulWidget {
  static const routeName = '/timeline';

  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage>
    with TickerProviderStateMixin, AnimationMixin {
  final _scrollController = ScrollController();
  late final TimelineViewModel _viewModel;
  late List<AnimationController> _itemAnimationControllers;

  @override
  void initState() {
    super.initState();
    _viewModel = locator<TimelineViewModel>();

    // 使用 AnimationMixin 初始化主要動畫
    initializeAnimations(
      duration: Duration(milliseconds: 1200),
    );

    final authState = Provider.of<AuthState>(context, listen: false);
    _viewModel.loadRecords(authState.uid);
    _itemAnimationControllers = List.generate(
      _viewModel.records.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 800),
        vsync: this,
      ),
    );
    _startAnimations();
    _scrollController.addListener(_onScroll);
    _scrollController.addListener(() => setState(() {}));
  }

  void _startAnimations() {
    final strategy = StaggeredAnimationStrategy(
        _viewModel.records.length, _itemAnimationControllers);
    strategy.startAnimation(animationController);
    // 主動畫由 AnimationMixin 自動啟動，這裡不需要手動 forward
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.removeListener(() => setState(() {}));
    _scrollController.dispose();
    disposeAnimations(); // 使用 AnimationMixin 的 dispose 方法
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final authState = Provider.of<AuthState>(context, listen: false);
      _viewModel.loadMoreRecords(authState.uid);
    }
  }

  void _handleSearch(String keyword) {
    final authState = Provider.of<AuthState>(context, listen: false);
    _viewModel.setSearchKeyword(keyword);
    _viewModel.searchRecords(authState.uid);
  }

  void _clearSearch() {
    final authState = Provider.of<AuthState>(context, listen: false);
    _viewModel.setSearchKeyword('');
    _viewModel.loadRecords(authState.uid);
  }

  void _onRecordTap(BabyRecord record) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => RecordDetailPage(record: record),
      ),
    );
  }

  void _onRecordLongPress(BabyRecord record) {
    if (_viewModel.selectedIds.contains(record.id)) {
      _viewModel.removeSelectedId(record.id);
    } else {
      _viewModel.addSelectedId(record.id);
    }
  }

  Future<void> _confirmDeleteSelectedRecords() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content:
            const Text('Are you sure you want to delete the selected records?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      final success = await _viewModel.deleteSelectedRecords();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Records deleted successfully')),
        );
      }
    }
  }

  // 新增：顯示編輯個人資料對話框
  void _showEditProfileDialog(AuthState authState) {
    if (authState.currentUser == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UserProfileEditDialog(
        user: authState.currentUser!,
        onUserUpdated: (updatedUser) {
          // 更新 AuthState 中的用戶資料
          authState.updateUser(updatedUser);
        },
      ),
    );
  }

  // 新增：顯示用戶設置選單
  void _showUserMenu(BuildContext context) {
    final authState = Provider.of<AuthState>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 拖拽指示器
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 用戶資訊
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    UserAvatar(
                      user: authState.currentUser,
                      radius: 30,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authState.currentUser?.displayName ?? '未設定名稱',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            authState.currentUser?.email ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // 選單選項
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Color(0xFF4A90E2),
                    size: 20,
                  ),
                ),
                title: const Text('編輯個人資料'),
                subtitle: const Text('更新您的資料和大頭貼'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _showEditProfileDialog(authState);
                },
              ),

              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BFA6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.payment,
                    color: Color(0xFF00BFA6),
                    size: 20,
                  ),
                ),
                title: const Text('付款設定'),
                subtitle: const Text('管理您的付款方式'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed(PaymentScreen.routeName);
                },
              ),

              const Divider(height: 1),

              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                title: const Text('登出'),
                subtitle: const Text('退出您的帳戶'),
                onTap: () async {
                  await authState.signOut();
                  Navigator.of(context)
                      .pushReplacementNamed(LoginPage.routeName);
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context);
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<TimelineViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Timeline'),
              actions: [
                if (viewModel.hasSelectedRecords) ...[
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _confirmDeleteSelectedRecords,
                  ),
                  IconButton(
                    icon: const Icon(Icons.payment),
                    onPressed: () {
                      Navigator.of(context).pushNamed(PaymentScreen.routeName);
                    },
                  ),
                ],
                // 更新的用戶頭像區域 - 現在可以點擊打開選單
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => _showUserMenu(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.transparent,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          UserAvatar(
                            user: authState.currentUser,
                            radius: 16,
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                // await Navigator.of(context).pushNamed(AddRecordPage.routeName);
                final authState =
                    Provider.of<AuthState>(context, listen: false);
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RecordDetailScreen(
                        record: BabyRecord(
                      id: '',
                      note: '',
                      height: '',
                      weight: '',
                      vaccineStatus: '',
                      photoUrl: '',
                      date: DateTime.now(),
                      uid: authState.uid,
                      tags: [],
                      sharedIds: [],
                    )),
                  ),
                );
                setState(() {
                  viewModel.records.clear();
                  viewModel.selectedIds.clear();
                  viewModel.loadRecords(authState.uid);
                });
              },
              child: const Icon(Icons.add_a_photo),
            ),
            body: LoadingOverlay(
              isLoading: viewModel.isLoading,
              child: Column(
                children: [
                  _buildSearchBar(viewModel),
                  SizedBox(width: 20),
                  Expanded(
                    child: viewModel.records.isEmpty
                        ? _buildEmptyState(viewModel)
                        : _buildRecordsList(viewModel),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(TimelineViewModel viewModel) {
    return buildAnimatedWidget(
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search by tags or notes',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: viewModel.searchKeyword.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSearch,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: _handleSearch,
        ),
      ),
    );
  }

  Widget _buildEmptyState(TimelineViewModel viewModel) {
    if (viewModel.searchKeyword.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No records found for "${viewModel.searchKeyword}"',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _clearSearch,
              child: const Text('Clear Search'),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.photo_album,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No records yet',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              final authState = Provider.of<AuthState>(context, listen: false);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RecordDetailScreen(
                      record: BabyRecord(
                    id: '',
                    note: '',
                    height: '',
                    weight: '',
                    vaccineStatus: '',
                    photoUrl: '',
                    date: DateTime.now(),
                    uid: authState.uid,
                    tags: [],
                    sharedIds: [],
                  )),
                ),
              );
            },
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Add Your First Record'),
          ),
        ],
      ),
    );
  }

  void _onRecordUpdated(int index, BabyRecord updatedRecord) {
    setState(() {
      _viewModel.records[index] = updatedRecord; // 更新列表中的記錄
    });
  }

  Widget _buildRecordsList(TimelineViewModel viewModel) {
    return buildAnimatedWidget(
      ListView.builder(
        controller: _scrollController,
        itemCount: viewModel.records.length + (viewModel.hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == viewModel.records.length) {
            return viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : const SizedBox.shrink();
          }

          final record = viewModel.records[index];
          final isSelected = viewModel.selectedIds.contains(record.id);

          return RecordCardComponent(
              record: record,
              index: index,
              recordLength: viewModel.records.length,
              scrollController: _scrollController,
              onRecordUpdated: _onRecordUpdated);
          // return RecordTile(
          //   key: ValueKey(record.id),
          //   record: record,
          //   isSelected: isSelected,
          //   onTap: (BabyRecord record) => _onRecordTap(record),
          //   onLongPress: (BabyRecord record) => _onRecordLongPress(record),
          // );
        },
      ),
    );
  }
}
