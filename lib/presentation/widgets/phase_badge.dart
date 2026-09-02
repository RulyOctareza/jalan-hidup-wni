import 'package:flutter/material.dart';
import 'package:jalan_hidup_wni/core/constants/asset_paths.dart';

class PhaseBadge extends StatelessWidget {
  const PhaseBadge({
    super.key,
    required this.phaseId,
    required this.phaseName,
  });

  final String phaseId;
  final String phaseName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AssetPaths.phase(phaseId),
            width: 24,
            height: 24,
            errorBuilder: (_, __, ___) => const Icon(Icons.flag, size: 20),
          ),
          const SizedBox(width: 6),
          Text(
            phaseName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
