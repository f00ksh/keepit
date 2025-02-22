import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final double radius;
  final String? photoUrl;
  final Color? backgroundColor;

  const UserAvatar({
    super.key,
    this.radius = 32,
    this.photoUrl,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    debugPrint('Building UserAvatar with photoUrl: $photoUrl');

    if (photoUrl == null || photoUrl!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? colorScheme.secondaryContainer,
        child: Icon(
          Icons.person,
          size: radius * 1.2,
          color: colorScheme.onSecondaryContainer,
        ),
      );
    }

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: photoUrl!,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        placeholder: (context, url) => CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor ?? colorScheme.secondaryContainer,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colorScheme.onSecondaryContainer,
          ),
        ),
        errorWidget: (context, url, error) {
          debugPrint('Error loading avatar: $error');
          return CircleAvatar(
            radius: radius,
            backgroundColor: backgroundColor ?? colorScheme.errorContainer,
            child: Icon(
              Icons.error_outline,
              size: radius * 1.2,
              color: colorScheme.error,
            ),
          );
        },
      ),
    );
  }
}
