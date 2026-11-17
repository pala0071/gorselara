import 'package:flutter/material.dart';

class StatusPanel extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  const StatusPanel({super.key, required this.icon, required this.message, this.actionLabel, this.onAction});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(28), child: Column(children: [
    Icon(icon, size: 52, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 16),
    Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
    if (onAction != null) Padding(padding: const EdgeInsets.only(top: 16),
      child: FilledButton.tonal(onPressed: onAction, child: Text(actionLabel ?? ''))),
  ]));
}
