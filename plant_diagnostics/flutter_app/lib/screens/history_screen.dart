import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:plant_diagnostics/services/database_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DatabaseService.instance.db.getAllDiagnoses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Failed to load history: ${snapshot.error}',
              textAlign: TextAlign.center,
            ),
          );
        }

        final diagnoses = snapshot.data ?? [];

        if (diagnoses.isEmpty) {
          return _EmptyHistory();
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: diagnoses.length,
          separatorBuilder: (_, __) => const Gap(8),
          itemBuilder: (context, i) {
            final d = diagnoses[i];
            return _DiagnosisCard(
              diseaseName: d.diseaseName ?? 'Pending...',
              confidence: d.confidence,
              status: d.status,
              createdAt: d.createdAt,
              isOod: d.isOod,
            );
          },
        );
      },
    );
  }
}

class _DiagnosisCard extends StatelessWidget {
  final String diseaseName;
  final double? confidence;
  final String status;
  final DateTime createdAt;
  final bool isOod;

  const _DiagnosisCard({
    required this.diseaseName,
    required this.confidence,
    required this.status,
    required this.createdAt,
    required this.isOod,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final statusColor = switch (status) {
      'synced' => Colors.green,
      'pending' => Colors.orange,
      'failed' => cs.error,
      _ => cs.outline,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isOod
                    ? cs.errorContainer
                    : cs.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isOod ? Icons.block : Icons.eco_rounded,
                color: isOod ? cs.error : cs.primary,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    diseaseName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Gap(4),
                  Text(
                    confidence != null
                        ? 'Confidence: ${(confidence! * 100).toStringAsFixed(0)}%'
                        : 'Confidence: —',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Gap(4),
                Text(
                  _formatDate(createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_rounded, size: 56,
              color: cs.onSurface.withOpacity(0.3)),
          const Gap(16),
          Text(
            'No diagnoses yet',
            style: TextStyle(color: cs.onSurface.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }
}
