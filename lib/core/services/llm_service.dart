import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// 阿里云百炼（灵积）LLM 服务
/// 兼容 OpenAI Chat Completions 格式，支持流式输出
class LlmService {
  static const String _apiKeyPrefKey = 'bailian_api_key';
  static const String _baseUrl =
      'https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions';
  static const String _defaultModel = 'qwen-turbo';

  // ─── API Key 管理 ───

  /// 读取保存的 API Key
  static Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyPrefKey);
  }

  /// 保存 API Key
  static Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPrefKey, key.trim());
  }

  /// 删除 API Key
  static Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiKeyPrefKey);
  }

  // ─── 目标复盘 ───

  /// 生成目标 AI 复盘（流式），返回 Stream<String>（每次 emit 增量文本）
  ///
  /// [goalName]      目标名称
  /// [totalMinutes]  目标总时长（分钟）
  /// [effectiveMinutes] 有效时间（分钟）
  /// [screenOffMinutes] 息屏时间估算 = total - recordsTotal（分钟）
  /// [topDistractionApps] 分心 App 列表，格式："微博(12分钟)"
  /// [topEffectiveApps]   有效 App 列表，格式："微信(30分钟)"
  static Stream<String> streamGoalReview({
    required String goalName,
    required int totalMinutes,
    required int effectiveMinutes,
    required int screenOffMinutes,
    required List<String> topDistractionApps,
    required List<String> topEffectiveApps,
    String model = _defaultModel,
  }) async* {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      yield '[请先在设置页配置阿里云百炼 API Key]';
      return;
    }

    final prompt = _buildPrompt(
      goalName: goalName,
      totalMinutes: totalMinutes,
      effectiveMinutes: effectiveMinutes,
      screenOffMinutes: screenOffMinutes,
      topDistractionApps: topDistractionApps,
      topEffectiveApps: topEffectiveApps,
    );

    final request = http.Request('POST', Uri.parse(_baseUrl));
    request.headers['Authorization'] = 'Bearer $apiKey';
    request.headers['Content-Type'] = 'application/json';
    request.headers['Accept'] = 'text/event-stream';

    request.body = jsonEncode({
      'model': model,
      'stream': true,
      'messages': [
        {
          'role': 'system',
          'content': '你是一个专注于学习效率分析的 AI 助手。用简洁、有温度的语言给出复盘。'
              '格式：先给一个评分（0-100分），再给一段 2-3 句话的分析，最后给一条具体可执行的建议。'
              '总字数不超过 150 字。',
        },
        {
          'role': 'user',
          'content': prompt,
        },
      ],
    });

    try {
      final client = http.Client();
      final streamedResponse = await client.send(request);

      if (streamedResponse.statusCode != 200) {
        final body = await streamedResponse.stream.bytesToString();
        yield '[请求失败 (${streamedResponse.statusCode}): $body]';
        client.close();
        return;
      }

      final buffer = StringBuffer();
      await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
        // SSE 格式：多行 "data: {...}\n\n"
        final lines = chunk.split('\n');
        for (final line in lines) {
          if (!line.startsWith('data: ')) continue;
          final data = line.substring(6).trim();
          if (data == '[DONE]') break;
          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            final choices = json['choices'] as List<dynamic>?;
            if (choices == null || choices.isEmpty) continue;
            final delta = choices[0]['delta'] as Map<String, dynamic>?;
            final content = delta?['content'] as String?;
            if (content != null && content.isNotEmpty) {
              buffer.write(content);
              yield content; // 每次 emit 增量片段，实现打字机效果
            }
          } catch (_) {
            // 跳过解析失败的行
          }
        }
      }
      client.close();
    } catch (e) {
      yield '[网络错误: $e]';
    }
  }

  /// 构建复盘 Prompt
  static String _buildPrompt({
    required String goalName,
    required int totalMinutes,
    required int effectiveMinutes,
    required int screenOffMinutes,
    required List<String> topDistractionApps,
    required List<String> topEffectiveApps,
  }) {
    final phoneMinutes = totalMinutes - screenOffMinutes;
    final distractionText = topDistractionApps.isEmpty ? '无' : topDistractionApps.join('、');
    final effectiveText = topEffectiveApps.isEmpty ? '无' : topEffectiveApps.join('、');

    return '''
目标名称：$goalName
总时长：$totalMinutes 分钟
其中息屏时间：$screenOffMinutes 分钟（未使用手机）
手机使用时间：$phoneMinutes 分钟
有效时间：$effectiveMinutes 分钟
分心 App：$distractionText
有效 App：$effectiveText
请对这次目标完成情况进行简短复盘。
''';
  }
}
