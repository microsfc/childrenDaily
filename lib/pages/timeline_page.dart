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


class TimelinePage extends StatefulWidget {
  static const routeName = '/timeline';
  
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  final _scrollController = ScrollController();
  late final TimelineViewModel _viewModel;
  
  @override
  void initState() {
    super.initState();
    _viewModel = locator<TimelineViewModel>();
    
    final authState = Provider.of<AuthState>(context, listen: false);
    _viewModel.loadRecords(authState.uid);
    
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
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
        content: const Text('Are you sure you want to delete the selected records?'),
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
                Row(
                  children: [
                    UserAvatar(
                      user: authState.currentUser,
                      radius: 16,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () async {
                        await authState.signOut();
                      },
                    ),
                  ],
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AddRecordPage.routeName);
              },
              child: const Icon(Icons.add_a_photo),
            ),
            body: LoadingOverlay(
              isLoading: viewModel.isLoading,
              child: Column(
                children: [
                  _buildSearchBar(viewModel),
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
    return Padding(
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
              Navigator.of(context).pushNamed(AddRecordPage.routeName);
            },
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Add Your First Record'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecordsList(TimelineViewModel viewModel) {
    return ListView.builder(
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
        
        return RecordTile(
          key: ValueKey(record.id),
          record: record,
          isSelected: isSelected,
          onTap: (BabyRecord record) => _onRecordTap(record),
          onLongPress: (BabyRecord record) => _onRecordLongPress(record),
        );
      },
    );
  }
}