import 'package:flutter/material.dart';
import 'package:jalan_hidup_wni/core/theme/app_colors.dart';
import 'package:jalan_hidup_wni/domain/entities/game_models.dart';

class EventDialog extends StatelessWidget {
  const EventDialog({
    super.key,
    required this.event,
    required this.onChoice,
  });

  final GameEvent event;
  final void Function(GameEventChoice choice) onChoice;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(event.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (event.imageAsset != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  event.imageAsset!,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(event.description),
          ],
        ),
      ),
      actions: event.choices
          .map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onChoice(c);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text(c.text),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
