import './add_record_page.dart';
import '../models/baby_record.dart';
import 'package:children/main.dart';
import '../widgets/record_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import 'package:children/models/appuser.dart';
import 'package:children/state/AppState.dart';
import 'package:children/generated/l10n.dart';
import 'package:children/pages/payment_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg_icons/flutter_svg_icons.dart';


// import 'package:timeline_tile/timeline_tile.dart';

class TimelinePage extends StatefulWidget {
  TimelinePage({super.key});
  static const routeName = '/timeline';
  // Keep track of selected records
  final Set<String> selectedRecordIds = {};

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> with RouteAware {
  // keep track of records
  late final List<BabyRecord> _records = [];
  /// Firestore pagination variables
  DocumentSnapshot ?_lastDocument;
  bool _hasMoreData = false;
  final ScrollController _scrollController = ScrollController();
  // 是否處於「搜尋模式」
  bool isSearching = false;
  // 搜尋關鍵字
  String searchKeyword = '';
  String userId = '';
  AppUser? currentUser;
  // 搜尋框的控制器
  final TextEditingController searchController = TextEditingController();
  /// Fetch the first (or next) batch of records
  Future<void> _fetchRecords() async {
    
    if (searchKeyword.isNotEmpty) {
      setState(() {
        _records.clear();
      });
    }

    // Base query: ordering by a field you want to sort by (e.g. timestamp)
    final firestoreService = Provider.of<FirestoreService?>(context, listen: false);
    if (firestoreService == null) {
      print("FirestoreService is null!");
      return;
    }

    final QuerySnapshot<Object?> recordsSnapshot;
    if (searchKeyword.isEmpty) {
      recordsSnapshot = await firestoreService.getBabyRecordsBatch(
        limit: 5, lastDocument: _lastDocument, uid: userId
      );
    } else {
      recordsSnapshot = await firestoreService.getBabyRecordsKeyWordBatch(
        limit: 5, lastDocument: _lastDocument, keyword: searchKeyword, uid: userId
      );
    }
    
    if (recordsSnapshot.docs.isNotEmpty) {
      // Update _lastDocument to the last doc from this batch
      _lastDocument = recordsSnapshot.docs.last;
      // Convert each doc to your model (BabyRecord)
      final fetchRecords = recordsSnapshot.docs
          .map((doc) => BabyRecord.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      setState(() {
        if (fetchRecords.length < 5) {
          _hasMoreData = false;
        } else {
          _hasMoreData = true;
        }
        _records.addAll(fetchRecords);
      });
    } else {
      // no more data
      setState(() {
        // _lastDocument = null;
        _hasMoreData = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _lastDocument = null;
    final appState = AppState.of(context);
    userId = appState.uid;
    currentUser = appState.currentUser;

    Future.microtask(() {
      _fetchRecords();
      _scrollController.addListener(_onScroll);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // User scrolled to the bottom => fetch more records
      _fetchRecords();
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Called when we come back to this route from another route
  @override
  void didPopNext() {
    super.didPopNext();
    final appState = AppState.of(context);
    setState(() {
      appState.selectedRecordIDs.clear();
      _records.clear();
      _lastDocument = null;
    });
    _fetchRecords();
  }

  // Called when this route has appeared and is ready
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    // Subscribe to RouteObserver
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }


  Future<Stream<List<BabyRecord>>> getFilterItems() async {
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    return searchKeyword.isEmpty
        ? firestoreService.getBabyRecords(userId)
        : await firestoreService.getTagsStartingWith(searchKeyword, userId);
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
                setState(() {
                  appState.selectedRecordIDs.clear();
                  _records.clear();
                  _lastDocument = null;
                });
                _fetchRecords();
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
    // var filteredItems = getFilterItems();
    final barTitle =
        '${S.of(context).activityRecord} ${S.of(context).timeline}';
    final appState = AppState.of(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(barTitle),
          automaticallyImplyLeading: false,          
          actions: [
            Row(
              children: [
                Text(currentUser?.displayName ?? '',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(currentUser!.profileImageUrl),
                  // child: const Icon(Icons.person, size: 18, color: Colors.white)
                  ),
              ],
            ),
            Consumer<AppState>(
              builder: (context, appState, child) {
                if (appState.selectedRecordIDs.isNotEmpty) {
                  return IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      confirmDeleteRecord(context);
                    },
                  );
                }
                return const SizedBox();
              },
            ),
            Consumer<AppState>(
              builder: (context, appState, child) {
                if (appState.selectedRecordIDs.isNotEmpty) {
                  return IconButton(
                    icon: const Icon(Icons.payment),
                    onPressed: () {
                      Navigator.of(context).pushNamed(PaymentScreen.routeName);
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed(AddRecordPage.routeName);
          },
          child: const SvgIcon(
                       icon: SvgIconData('assets/icons/add-photo-svgrepo-com.svg'),
                  )
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: 
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withAlpha(77),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: S.of(context).searchKeyword,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchKeyword.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              searchController.clear();
                              setState(() {
                                searchKeyword = '';
                                _fetchRecords();
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchKeyword = value.trim();
                      _fetchRecords();
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _records.length + 1,
                itemBuilder: (context, index) {
                  // final isFirst = index == 0 ? true : false;
                  // final isLast = index == _records.length -1 ? true : false;
                  
                  // If the user has scrolled to the bottom and we’re still loading, show a loader
                  if (index == _records.length) {
                     return _hasMoreData
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox.shrink();
                  }

                  // final record = _records[index];

                  // return TimelineTile(
                  //   // alignment: determines where the line is drawn.
                  //   // Use TimelineAlign.start for a left-aligned timeline, or
                  //   // TimelineAlign.center if you want the line in the center, etc.
                  //   alignment: TimelineAlign.start,
                  //   // Indicate if it's the first or last tile
                  //   isFirst: isFirst,
                  //   isLast: isLast,
                  //   // The main axis (vertical in this example).
                  //   // If you want a horizontal timeline, set 'axis: TimelineAxis.horizontal'
                  //   axis: TimelineAxis.vertical,
                  //   // The indicator (dot) style
                  //   indicatorStyle: const IndicatorStyle(
                  //     width: 20,
                  //     color: Colors.purple,
                  //     padding: EdgeInsets.all(16),
                  //     indicatorXY: 0.5, //0.5 is center vertically
                  //   ),
                  //   afterLineStyle: const LineStyle(
                  //     color: Colors.purple,
                  //     thickness: 2,
                  //   ),
                  //   beforeLineStyle: const LineStyle(
                  //     color: Colors.purple,
                  //     thickness: 2,
                  //   ),
                  //   // The 'startChild' widget is placed on the left side
                  //   // for a vertical timeline (because alignment is 'start').
                  //   // The 'endChild' is placed on the right side. 
                  //   // If using TimelineAlign.start, typically only one side is used.
                  //   endChild: RecordTile(key: ValueKey(record.id), record: record),
                  // );

                  final record = _records[index];
                  return RecordTile(key: ValueKey(record.id), record: record);
                },
              )
            )
            // StreamBuilder<List<BabyRecord>>(
            //   stream: filteredItems.asStream().asyncExpand((stream) => stream),
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return const Center(child: CircularProgressIndicator());
            //     } else if (snapshot.hasError) {
            //       return Center(child: Text(S.of(context).errorOccurred));
            //     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            //       return Center(child: Text(S.of(context).noRecordFound));
            //     }
            //     final records = snapshot.data!;
            //     return ListView.builder(
            //       shrinkWrap: true,
            //       // physics: const NeverScrollableScrollPhysics(),
            //       itemCount: records.length,
            //       addAutomaticKeepAlives: true ,
            //       cacheExtent: 1000,
            //       itemBuilder: (context, index) {
            //         return RecordTile(key: ValueKey(records[index].id),
            //                           record: records[index]);
            //       },
            //     );
            //   },
            // ),
          ]),
      );
  }
}
