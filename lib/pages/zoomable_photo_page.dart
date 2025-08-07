import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:children/generated/l10n.dart';
import 'package:cached_network_image/cached_network_image.dart';


class ZoomablePhotoPage extends StatelessWidget {
  final String imageUrl;
  final String heroTag;
  final bool isLocalFile;

  const ZoomablePhotoPage({
    super.key,
    required this.imageUrl,
    required this.heroTag,
    this.isLocalFile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).viewPhoto),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Hero(
        tag: heroTag,
        child: isLocalFile 
            ? Image.file(File(imageUrl))
            : PhotoView(imageProvider: CachedNetworkImageProvider(imageUrl)),
      ),
    );
  }
}
