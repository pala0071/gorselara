import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/image_item.dart';
import '../providers.dart';

class SourceChips extends ConsumerWidget {
  const SourceChips({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchProvider), s = ref.watch(stringsProvider);
    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: SourceId.values.map((source) => Padding(
      padding: const EdgeInsets.only(right: 8), child: FilterChip(label: Text(source.label),
        avatar: source.requiresKey ? const Icon(Icons.key, size: 15) : null,
        selected: state.selected.contains(source), onSelected: (value) async {
          if (value && source == SourceId.unsplash) {
            final accepted = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
              title: const Text('Unsplash'), content: Text(s.t(
                'Unsplash, arama ve indirme odaklı uygulamalar için sağlayıcı onayı gerektirebilir. Bu bağlantıyı yalnızca API kullanımınıza izin veriliyorsa etkinleştirin.',
                'Unsplash may require provider approval for search-and-download applications. Enable only if your API use is permitted.')),
              actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: Text(s.t('Vazgeç', 'Cancel'))),
                FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(s.t('Etkinleştir', 'Enable')))]));
            if (accepted != true || !context.mounted) return;
          }
          final selected = {...ref.read(searchProvider).selected};
          value ? selected.add(source) : selected.remove(source);
          await ref.read(searchProvider.notifier).choose(selected);
        }))).toList()));
  }
}
