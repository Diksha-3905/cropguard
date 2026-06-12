import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ConfidenceBar extends StatelessWidget {
  final String label;
  final double value; // 0.0 – 1.0

  const ConfidenceBar({super.key, required this.label, required this.value});

  Color _barColor(BuildContext context) {
    if (value >= 0.75) return Colors.green;
    if (value >= 0.5) return Colors.orange;
    return Theme.of(context).colorScheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pct = (value * 100).toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(
              '$pct%',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: _barColor(context),
              ),
            ),
          ],
        ),
        const Gap(6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: cs.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(_barColor(context)),
          ),
        ),
        const Gap(4),
        Text(
          value >= 0.75
              ? 'High confidence — result is reliable'
              : value >= 0.5
                  ? 'Moderate confidence — consider a second opinion'
                  : 'Low confidence — result may be inaccurate',
          style: TextStyle(
            fontSize: 11,
            color: cs.onSurface.withOpacity(0.55),
          ),
        ),
      ],
    );
  }
}
