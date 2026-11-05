import 'package:flutter/material.dart';

class GMMallTestPage extends StatelessWidget {
  const GMMallTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    const entries = [
      ('商城激励测试', 'GMMallRewardPage'),
      ('金刚位插屏测试', 'GMMallEntryPage'),
      ('商城频道测试', 'GMMallPage'),
      ('高商词多商品测试', 'GMMallSearchPage'),
      ('高商词单商品测试', 'GMMallProductPage'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('商城测试')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final entry in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, entry.$2),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(entry.$1),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
