import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../models/note_item.dart';
import '../services/note_store.dart';
import '../services/speech_service.dart';
import '../theme/app_theme.dart';
import '../widgets/cartoon_backdrop.dart';
import '../widgets/compose_sheet.dart';
import '../widgets/panel_column.dart';

class WorkspacePage extends StatefulWidget {
  const WorkspacePage({super.key, this.initialFocus});

  final String? initialFocus;

  @override
  State<WorkspacePage> createState() => _WorkspacePageState();
}

class _WorkspacePageState extends State<WorkspacePage> {
  final _store = NoteStore.instance;
  final _speech = SpeechService();
  final _uuid = const Uuid();

  List<NoteItem> _items = [];
  bool _loading = true;
  late int _tabIndex;

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialFocus == 'notes' ? 1 : 0;
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialFocus == 'inspiration') {
        _compose(NoteKind.inspiration);
      } else if (widget.initialFocus == 'notes') {
        _compose(NoteKind.note);
      }
    });
  }

  Future<void> _load() async {
    final items = await _store.load();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  List<NoteItem> _of(NoteKind kind) =>
      _items.where((e) => e.kind == kind).toList();

  Future<void> _compose(NoteKind kind, {NoteItem? editing}) async {
    final text = await showComposeSheet(
      context: context,
      kind: kind,
      speech: _speech,
      initial: editing?.content,
    );
    if (text == null || text.trim().isEmpty) return;

    final item = editing == null
        ? NoteItem(
            id: _uuid.v4(),
            kind: kind,
            content: text.trim(),
            createdAt: DateTime.now(),
          )
        : editing.copyWith(content: text.trim(), updatedAt: DateTime.now());

    final items = await _store.upsert(item);
    if (!mounted) return;
    setState(() => _items = items);
  }

  Future<void> _delete(NoteItem item) async {
    final items = await _store.remove(item.id);
    if (!mounted) return;
    setState(() => _items = items);
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 700;

    return Scaffold(
      body: CartoonBackdrop(
        variant: _tabIndex == 0
            ? BackdropVariant.inspiration
            : BackdropVariant.notes,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 12, 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: SparkColors.ink,
                    ),
                    Expanded(
                      child: Text(
                        '灵感火花',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: SparkColors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              if (!wide)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SegmentTabs(
                    index: _tabIndex,
                    onChanged: (i) => setState(() => _tabIndex = i),
                  ),
                ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : wide
                        ? Row(
                            children: [
                              Expanded(
                                child: PanelColumn(
                                  kind: NoteKind.inspiration,
                                  items: _of(NoteKind.inspiration),
                                  onAdd: () =>
                                      _compose(NoteKind.inspiration),
                                  onEdit: (item) => _compose(
                                    NoteKind.inspiration,
                                    editing: item,
                                  ),
                                  onDelete: _delete,
                                ),
                              ),
                              Expanded(
                                child: PanelColumn(
                                  kind: NoteKind.note,
                                  items: _of(NoteKind.note),
                                  onAdd: () => _compose(NoteKind.note),
                                  onEdit: (item) =>
                                      _compose(NoteKind.note, editing: item),
                                  onDelete: _delete,
                                ),
                              ),
                            ],
                          )
                        : IndexedStack(
                            index: _tabIndex,
                            children: [
                              PanelColumn(
                                kind: NoteKind.inspiration,
                                items: _of(NoteKind.inspiration),
                                onAdd: () => _compose(NoteKind.inspiration),
                                onEdit: (item) => _compose(
                                  NoteKind.inspiration,
                                  editing: item,
                                ),
                                onDelete: _delete,
                              ),
                              PanelColumn(
                                kind: NoteKind.note,
                                items: _of(NoteKind.note),
                                onAdd: () => _compose(NoteKind.note),
                                onEdit: (item) =>
                                    _compose(NoteKind.note, editing: item),
                                onDelete: _delete,
                              ),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SegmentTabs extends StatelessWidget {
  const _SegmentTabs({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabChip(
              selected: index == 0,
              label: '灵感蓝区',
              color: SparkColors.blueDeep,
              onTap: () => onChanged(0),
            ),
          ),
          Expanded(
            child: _TabChip(
              selected: index == 1,
              label: '记事粉区',
              color: SparkColors.pinkDeep,
              onTap: () => onChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.selected,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
