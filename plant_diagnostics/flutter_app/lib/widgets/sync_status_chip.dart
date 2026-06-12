import 'package:flutter/material.dart';
import 'package:plant_diagnostics/services/sync_service.dart';

class SyncStatusChip extends StatelessWidget {
  const SyncStatusChip({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncState>(
      stream: SyncService.instance.syncStream,
      initialData: const SyncState.idle(),
      builder: (context, snapshot) {
        final state = snapshot.data!;
        final cs = Theme.of(context).colorScheme;

        return switch (state) {
          _Idle() => const SizedBox.shrink(),
          _Syncing() => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: 6),
                const Text('Syncing', style: TextStyle(fontSize: 12)),
              ],
            ),
          _Done(:final synced) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_done_rounded, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  'Synced $synced',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          _Error() => Icon(
              Icons.cloud_off_rounded,
              size: 18,
              color: cs.error,
            ),
        };
      },
    );
  }
}
