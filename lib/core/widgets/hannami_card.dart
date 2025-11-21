import 'package:flutter/material.dart';
import 'dart:io';
import '../../core/colors.dart';
import '../../core/styles.dart';
import '../../core/utils/date_utils.dart';

class HannamiCard extends StatelessWidget {
  final String title;
  final String snippet;
  final DateTime date;
  final String? imagePath; // local file path
  final String? weatherSummary;
  final double? latitude;
  final double? longitude;
  final VoidCallback? onTap;

  const HannamiCard({
    super.key,
    required this.title,
    required this.snippet,
    required this.date,
    this.imagePath,
    this.weatherSummary,
    this.latitude,
    this.longitude,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final image = (imagePath != null && imagePath!.isNotEmpty)
        ? ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(
              // Using File without importing dart:io directly keeps widget simple; Image.file handles it.
              // ignore: unnecessary_non_null_assertion
              File(imagePath!),
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: HannamiColors.cardBackground.withOpacity(.6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.broken_image, size: 28, color: Colors.white24),
              ),
            ),
          )
        : null;

    return InkWell(
      borderRadius: BorderRadius.circular(HannamiSpacing.cardRadius),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: HannamiColors.cardBackground,
          borderRadius: BorderRadius.circular(HannamiSpacing.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: HannamiSpacing.cardPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: HannamiTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    snippet,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: HannamiTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: HannamiColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        DateUtilsExt.friendly(date),
                        style: HannamiTextStyles.bodyMedium.copyWith(fontSize: 12),
                      ),
                      if (weatherSummary != null && weatherSummary!.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.wb_cloudy, size: 14, color: HannamiColors.textSecondary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            weatherSummary!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: HannamiTextStyles.bodyMedium.copyWith(fontSize: 12),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (latitude != null && longitude != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_pin, size: 14, color: HannamiColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${latitude!.toStringAsFixed(3)}, ${longitude!.toStringAsFixed(3)}',
                          style: HannamiTextStyles.bodyMedium.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (image != null) ...[
              const SizedBox(width: 16),
              image,
            ],
          ],
        ),
      ),
    );
  }
}
