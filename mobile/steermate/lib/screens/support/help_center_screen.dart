import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help Center'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _FAQSection(title: 'Getting Started', items: [
            _FAQItem(q: 'How do I start a trip?', a: 'Tap the "Start Trip" button on the home screen. The app will check your sensors and then begin tracking.'),
            _FAQItem(q: 'What permissions are needed?', a: 'SteerMate needs GPS location and motion sensors. Camera is optional for sign detection.'),
          ]),
          _FAQSection(title: 'During a Trip', items: [
            _FAQItem(q: 'What do the alerts mean?', a: 'Red alerts indicate dangerous behavior like hard braking or overspeeding. Yellow alerts are cautions.'),
            _FAQItem(q: 'How accurate is speed detection?', a: 'Speed is measured via GPS, which is typically accurate within 1-2 km/h.'),
          ]),
          _FAQSection(title: 'Safety Score', items: [
            _FAQItem(q: 'How is my score calculated?', a: 'Your score starts at 100 and decreases based on unsafe events detected during your trip.'),
            _FAQItem(q: 'Can I improve my score?', a: 'Yes! Drive smoothly, avoid hard braking, and stay within speed limits.'),
          ]),
          _FAQSection(title: 'Privacy', items: [
            _FAQItem(q: 'Is my location data shared?', a: 'No. All processing happens on your device. Data is only uploaded to your account.'),
            _FAQItem(q: 'Can I delete my data?', a: 'Yes, go to Settings > Privacy & Data > Delete Account.'),
          ]),
        ],
      ),
    );
  }
}

class _FAQSection extends StatelessWidget {
  final String title;
  final List<_FAQItem> items;
  const _FAQSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
        ...items.map((item) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(title: Text(item.q), children: [Padding(padding: const EdgeInsets.all(16), child: Text(item.a))]),
        )),
      ],
    );
  }
}

class _FAQItem {
  final String q;
  final String a;
  _FAQItem({required this.q, required this.a});
}
