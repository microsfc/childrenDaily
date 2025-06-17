import '../../models/appuser.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserAvatar extends StatelessWidget {
  final AppUser? user;
  final double radius;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  
  const UserAvatar({
    Key? key,
    required this.user,
    this.radius = 20,
    this.backgroundColor,
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return _buildPlaceholder();
    }
    
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.grey[200],
        backgroundImage: user!.hasProfileImage
            ? CachedNetworkImageProvider(user!.profileImageUrl)
            : null,
        child: user!.hasProfileImage
            ? null
            : Text(
                user!.initials,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                  fontSize: radius * 0.7,
                ),
              ),
      ),
    );
  }
  
  Widget _buildPlaceholder() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey[200],
      child: Icon(
        Icons.person,
        color: Colors.grey[800],
        size: radius * 0.7,
      ),
    );
  }
}