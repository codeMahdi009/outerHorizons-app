import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';

class NasaResultTile extends StatelessWidget {
  final String title;
  final String description;
  final String thumbUrl;
  final String mediaType;
  final VoidCallback onTap;

  const NasaResultTile({
    super.key,
    required this.title,
    required this.description,
    required this.thumbUrl,
    required this.mediaType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final cardBg = isDark ? AppTheme.cardDark : AppTheme.lightCard;
    final textMain = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSub = isDark ? Colors.white38 : AppTheme.greyText;
    final chevron = isDark ? Colors.white38 : AppTheme.greyText;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: thumbUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: thumbUrl,
                      width: 90,
                      height: 80,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _placeholder(cardBg),
                    )
                  : _placeholder(cardBg),
            ),
            const SizedBox(width: 12),
            // Text
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      if (mediaType == 'video') ...[
                        Icon(Icons.play_circle, color: primary, size: 16),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: textMain,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    Text(description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: textSub, fontSize: 11)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(Icons.chevron_right, color: chevron),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(Color bg) {
    return Container(
      width: 90,
      height: 80,
      color: bg,
      child: Icon(
          mediaType == 'video'
              ? Icons.play_circle_outline
              : Icons.image_rounded,
          color: Colors.white38),
    );
  }
}
