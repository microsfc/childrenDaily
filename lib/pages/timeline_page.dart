import './add_record_page.dart';
import '../models/baby_record.dart';
import '../widgets/record_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import 'package:flutter_svg_icons/flutter_svg_icons.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});
  static const routeName = '/timeline';

  @override
  Widget build(BuildContext context) {
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('活動記錄 Timeline'),
        actions: [
          IconButton(
            icon: const SvgIcon(
              icon: SvgIconData('assets/icons/add-photo-svgrepo-com.svg'),
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(AddRecordPage.routeName);
            },
          )
        ],
      ),
      body: StreamBuilder<List<BabyRecord>>(
        stream: firestoreService.getBabyRecords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('發生錯誤'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('目前沒有任何記錄'));
          }
          final records = snapshot.data!;
          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              return RecordTile(record: records[index]);
            },
          );
        },
      ),
    );
  }
}
