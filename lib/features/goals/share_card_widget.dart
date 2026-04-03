import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// 分享卡数据模型
class ShareCardData {
  final String goalTitle;
  final int totalMinutes;
  final double focusRate;
  final String dateRange;
  final List<String> distractionApps;
  final String? aiOneLiner;

  const ShareCardData({
    required this.goalTitle,
    required this.totalMinutes,
    required this.focusRate,
    required this.dateRange,
    required this.distractionApps,
    this.aiOneLiner,
  });
}

/// RepaintBoundary 包裹 - 用于截图
class ShareCardCapture extends StatelessWidget {
  final ShareCardData data;
  final GlobalKey repaintKey;

  const ShareCardCapture({
    super.key,
    required this.data,
    required this.repaintKey,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintKey,
      child: _ShareCard(data: data),
    );
  }
}

/// 截图并触发系统分享
Future<void> captureAndShare(GlobalKey repaintKey, String goalTitle) async {
  try {
    final boundary =
        repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;
    final pngBytes = byteData.buffer.asUint8List();
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/timeanchor_report.png';
    await File(filePath).writeAsBytes(pngBytes);
    await Share.shareXFiles(
      [XFile(filePath, mimeType: 'image/png')],
      subject: '时光锚 - 专注报告 - $goalTitle',
    );
  } catch (e) {
    debugPrint('Share failed: $e');
  }
}

// ─────────────────────────────────────────────────────
// 分享卡主体 UI（深色，独立于系统主题，截图稳定）
// ─────────────────────────────────────────────────────
class _ShareCard extends StatelessWidget {
  final ShareCardData data;
  const _ShareCard({required this.data});

  @override
  Widget build(BuildContext context) {
    const cardWidth = 360.0;
    const bgStart = Color(0xFF1A1032);
    const bgEnd = Color(0xFF2D1B69);
    const primary = Color(0xFF9C72F8);
    const accent = Color(0xFF6CF0C2);

    final focusPct = (data.focusRate * 100).toStringAsFixed(1);
    final focusColor = data.focusRate >= 0.8
        ? accent
        : data.focusRate >= 0.6
            ? const Color(0xFFFFCC66)
            : const Color(0xFFFF6B6B);

    final h = data.totalMinutes ~/ 60;
    final m = data.totalMinutes % 60;
    final durationStr = h > 0 ? '${h}h ${m}min' : '${m}min';

    return Container(
      width: cardWidth,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [bgStart, bgEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: Stack(
        children: [
          // 装饰圆 - 右上
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withValues(alpha: 0.12),
              ),
            ),
          ),
          // 装饰圆 - 左下
          Positioned(
            left: -30,
            bottom: 40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo 行
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          const Icon(Icons.anchor, size: 16, color: primary),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '时光锚',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      data.dateRange,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 目标名
                Text(
                  data.goalTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),

                // 核心数据行
                Row(
                  children: [
                    _StatBlock(
                      label: '专注率',
                      value: '$focusPct%',
                      valueColor: focusColor,
                    ),
                    const SizedBox(width: 24),
                    _StatBlock(
                      label: '总时长',
                      value: durationStr,
                      valueColor: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 专注度进度条
                _FocusBar(rate: data.focusRate, color: focusColor),

                // 分心 App
                if (data.distractionApps.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    '分心应用',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...data.distractionApps.take(3).map(
                        (app) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFFF6B6B)
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                app,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ],

                // AI 一句话评语
                if (data.aiOneLiner != null &&
                    data.aiOneLiner!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 14,
                          color: primary.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            data.aiOneLiner!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 12,
                              height: 1.5,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 18),

                // 底部 slogan
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    '每一段专注，都值得被记住',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.25),
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// 子组件
// ─────────────────────────────────────────────────────

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _StatBlock({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _FocusBar extends StatelessWidget {
  final double rate;
  final Color color;

  const _FocusBar({required this.rate, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: rate.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.6)],
            ),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}

/// 弹出分享卡对话框（从报告页调用）
Future<void> showShareCardDialog(
  BuildContext context,
  ShareCardData data,
) async {
  final repaintKey = GlobalKey();

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShareCardCapture(data: data, repaintKey: repaintKey),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              captureAndShare(repaintKey, data.goalTitle);
            },
            icon: const Icon(Icons.share, size: 18),
            label: const Text('分享给朋友'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    ),
  );
}
