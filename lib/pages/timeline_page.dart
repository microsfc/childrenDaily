import 'package:children/state/AppState.dart';

import './add_record_page.dart';
import '../models/baby_record.dart';
import '../widgets/record_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import 'package:flutter_svg_icons/flutter_svg_icons.dart';
import 'package:children/generated/l10n.dart';

class TimelinePage extends StatefulWidget {
  TimelinePage({super.key});
  static const routeName = '/timeline';
  // Keep track of selected records
  final Set<String> selectedRecordIds = {};

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  // 是否處於「搜尋模式」
  bool isSearching = false;
  // 搜尋關鍵字
  String searchKeyword = '';
  // 搜尋框的控制器
  final TextEditingController searchController = TextEditingController();

  Future<Stream<List<BabyRecord>>> getFilterItems() async {
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    return searchKeyword.isEmpty
        ? await firestoreService.getBabyRecords()
        : await firestoreService.getTagsStartingWith(searchKeyword);
  }

  Future<void> confirmDeleteRecord(BuildContext context) async {
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    final appState = AppState.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).areYouSureToDelete),
        actions: [
          TextButton(
              onPressed: () => nav.pop(), child: Text(S.of(context).cancel)),
          TextButton(
              onPressed: () async {
                await firestoreService
                    .deleteMultipleRecords(appState.selectedRecordIDs);
                appState.selectedRecordIDs.clear();
                nav.pop();
                messenger.showSnackBar(
                  SnackBar(content: Text(S.of(context).deleteSuccess)),
                );
              },
              child: Text(S.of(context).confirm)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 過濾清單
    var filteredItems = getFilterItems();
    final barTitle =
        '${S.of(context).activityRecord} ${S.of(context).timeline}';
    return Scaffold(
        appBar: AppBar(
          title: Text(barTitle),
          actions: [
            IconButton(
              icon: const SvgIcon(
                icon: SvgIconData('assets/icons/add-photo-svgrepo-com.svg'),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(AddRecordPage.routeName);
              },
            ),
            IconButton(
              icon: const SvgIcon(
                icon: SvgIconData('assets/icons/delete-svgrepo-com.svg'),
              ),
              onPressed: () {
                confirmDeleteRecord(context);
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[300]!,
                      blurRadius: 10,
                      offset: Offset(0, 20),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: S.of(context).searchKeyword,
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchKeyword = value.trim();
                      filteredItems = getFilterItems();
                    });
                  },
                ),
              ),
            ),
            StreamBuilder<List<BabyRecord>>(
              stream: filteredItems.asStream().asyncExpand((stream) => stream),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text(S.of(context).errorOccurred));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text(S.of(context).noRecordFound));
                }
                final records = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    return RecordTile(record: records[index]);
                  },
                );
              },
            ),
          ]),
        ));
  }
}
