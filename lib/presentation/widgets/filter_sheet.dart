import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/search_filter.dart';
import '../providers.dart';

class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({super.key});
  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}
class _FilterSheetState extends ConsumerState<FilterSheet> {
  late Resolution resolution;
  late DateDirection direction;
  DateTime? date;
  @override
  void initState() {
    super.initState(); final filter = ref.read(searchProvider).filter;
    resolution = filter.resolution; direction = filter.direction; date = filter.date;
  }
  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    return SafeArea(child: SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(24), child: Column(
      mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(s.t('Arama filtreleri', 'Search filters'), style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 20),
      Wrap(spacing: 8, children: Resolution.values.map((r) => ChoiceChip(
        label: Text([s.t('Hepsi', 'All'), 'HD', 'Full HD', '4K+'][r.index]),
        selected: resolution == r, onSelected: (_) => setState(() => resolution = r))).toList()),
      const SizedBox(height: 16),
      ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.calendar_month),
        title: Text(date == null ? s.t('Tarih seç', 'Choose date') : '${date!.day}.${date!.month}.${date!.year}'),
        trailing: date == null ? null : IconButton(onPressed: () => setState(() => date = null), icon: const Icon(Icons.close)),
        onTap: () async {
          final value = await showDatePicker(context: context, initialDate: date ?? DateTime.now(),
            firstDate: DateTime(1800), lastDate: DateTime.now());
          if (mounted && value != null) setState(() => date = value);
        }),
      Wrap(spacing: 8, children: DateDirection.values.map((d) => ChoiceChip(
        label: Text(d == DateDirection.after ? s.t('Bu tarihten sonra', 'After this date') : s.t('Bu tarihten önce', 'Before this date')),
        selected: direction == d, onSelected: (_) => setState(() => direction = d))).toList()),
      const SizedBox(height: 14),
      Text(s.t('Tarih filtresi cihazda uygulanır. Bilinmeyen tarihler çıkarılır. Kaynak tarihi yükleme, yayımlama veya indeksleme tarihidir; çekim tarihi değildir. Seçilen gün dahil edilmez.',
        'Dates are filtered on-device. Unknown dates are excluded. Source dates refer to upload, publication or indexing, not capture. The selected day is excluded.')),
      const SizedBox(height: 10), Text(s.t('Çözünürlük kaynak metadatasına göredir; indirilebilir dosya daha küçük olabilir.', 'Resolution uses source metadata; the available download may be smaller.')),
      const SizedBox(height: 20),
      Row(children: [TextButton(onPressed: () => setState(() { resolution = Resolution.all; date = null; direction = DateDirection.after; }),
        child: Text(s.t('Sıfırla', 'Reset'))), const Spacer(), FilledButton(onPressed: () {
          ref.read(searchProvider.notifier).setFilter(SearchFilter(resolution: resolution, date: date, direction: direction));
          Navigator.pop(context);
        }, child: Text(s.t('Uygula', 'Apply')))]),
    ]))));
  }
}
