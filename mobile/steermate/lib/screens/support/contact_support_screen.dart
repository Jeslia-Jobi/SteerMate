import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});
  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _category = 'General';

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message sent! We\'ll get back to you soon.'), backgroundColor: AppTheme.successColor));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Support'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
                const Icon(Icons.email_rounded, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Email us at', style: TextStyle(color: Colors.grey)), const Text('support@steermate.app', style: TextStyle(fontWeight: FontWeight.bold))]),
              ]))),
              const SizedBox(height: 24),
              Text('Or send us a message:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ['General', 'Bug Report', 'Feature Request', 'Account Issue'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(controller: _subjectController, decoration: const InputDecoration(labelText: 'Subject'), validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _messageController, decoration: const InputDecoration(labelText: 'Message', alignLabelWithHint: true), maxLines: 5, validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _submit, child: const Text('Send Message')),
            ],
          ),
        ),
      ),
    );
  }
}
