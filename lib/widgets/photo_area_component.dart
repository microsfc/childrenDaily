import 'package:flutter/material.dart';
import 'package:children/models/baby_record.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PhotoAreaComponent extends StatelessWidget {
  final BabyRecord record;

  const PhotoAreaComponent({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    if (!record.hasPhoto) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.photo, color: Colors.grey),
      );
    }
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: record.photoUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        ),
      ),
    );
  }
}