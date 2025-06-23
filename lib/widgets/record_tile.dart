import 'package:flutter/material.dart';
import '../../models/baby_record.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RecordTile extends StatelessWidget {
  final BabyRecord record;
  final Function(BabyRecord)? onTap;
  final Function(BabyRecord)? onLongPress;
  final bool isSelected;
  
  const RecordTile({
    super.key,
    required this.record,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected 
        ? Theme.of(context).primaryColor.withOpacity(0.1)
        : null;
    
    return Card(
      color: backgroundColor,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      elevation: isSelected ? 8.0 : 2.0,
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            onTap!(record);
          } else {
            Navigator.of(context).pushNamed(
              '/record_detail',
              arguments: record,
            );
          }
        },
        onLongPress: () {
          if (onLongPress != null) {
            onLongPress!(record);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  _buildImage(),
                  if (isSelected)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.formattedDate,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (record.hasVaccineStatus) ...[
                      Text(
                        record.vaccineStatus,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (record.hasNote) ...[
                      Text(
                        record.note,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                    ],
                    _buildMeasurements(),
                    if (record.hasTags) ...[
                      const SizedBox(height: 4),
                      _buildTags(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildImage() {
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
  
  Widget _buildMeasurements() {
    final hasHeight = record.hasHeight;
    final hasWeight = record.hasWeight;
    
    if (!hasHeight && !hasWeight) {
      return const SizedBox.shrink();
    }
    
    return Row(
      children: [
        if (hasHeight)
          _buildMeasurementItem(Icons.height, '${record.height} cm'),
        if (hasHeight && hasWeight)
          const SizedBox(width: 16),
        if (hasWeight)
          _buildMeasurementItem(Icons.monitor_weight, '${record.weight} kg'),
      ],
    );
  }
  
  Widget _buildMeasurementItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTags() {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: record.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Text(
            tag,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.blue,
            ),
          ),
        );
      }).toList(),
    );
  }
}