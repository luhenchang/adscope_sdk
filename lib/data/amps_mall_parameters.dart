import 'dart:convert';

import 'amps_ad.dart';

/// 合并搜索词/自定义商城JSON与统一奖励配置，双端传递相同的标准数组。
String? mallUserData(AdOptions config) {
  final gm = config.customExtraMap?['GM'];
  final raw = gm is Map ? gm['userData'] : null;
  final input = raw ?? config.extraDataMap?['adn_gm_shop_extra_data'];
  final entries = <Map<String, dynamic>>[];
  if (input != null && input is! String) {
    throw ArgumentError('GM.userData must be a query string or JSON array');
  }
  final text = (input as String?)?.trim() ?? '';
  if (text.startsWith('[')) {
    final decoded = jsonDecode(text);
    if (decoded is! List ||
        decoded.any((entry) =>
            entry is! Map ||
            entry['name'] is! String ||
            !entry.containsKey('value'))) {
      throw const FormatException(
          'Mall userData must contain name/value entries');
    }
    entries.addAll(
        decoded.map((entry) => Map<String, dynamic>.from(entry as Map)));
  } else if (text.isNotEmpty) {
    entries.add({'name': 'query', 'value': text});
  }
  final query = config.mallQuery?.trim();
  if (query != null && query.isNotEmpty) {
    entries.removeWhere((entry) => entry['name'] == 'query');
    entries.add({'name': 'query', 'value': query});
  }
  final reward = config.mallReward?.toUserData();
  if (reward != null) {
    for (final entry in jsonDecode(reward) as List) {
      entries.removeWhere((old) => old['name'] == entry['name']);
      entries.add(Map<String, dynamic>.from(entry as Map));
    }
  }
  return entries.isEmpty ? null : jsonEncode(entries);
}
