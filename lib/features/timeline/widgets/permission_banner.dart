import 'package:flutter/material.dart';
import '../../../core/services/usage_stats_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PermissionBanner extends ConsumerWidget {
  const PermissionBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.read(usageStatsServiceProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded, color: Colors.orange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '需要使用记录权限',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Colors.orange,
                  ),
                ),
                Text(
                  '授权后才能自动记录 App 使用时间',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.orange.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => service.requestPermission(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: const Text('去授权', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
