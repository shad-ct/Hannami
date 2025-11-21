import 'package:flutter/material.dart';
import '../colors.dart';

class ImageTile extends StatelessWidget {
  final String id;
  final VoidCallback? onTap;
  const ImageTile({super.key, required this.id, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: HannamiColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.image, color: Colors.white24),
      ),
    );
  }
}
