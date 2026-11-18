import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/note_item.dart';
import '../theme/app_theme.dart';

class PanelColumn extends StatelessWidget {
  const PanelColumn({
    super.key,
    required this.kind,
    required this.items,
    required this.onAdd,
    required this.onDelete,
    required this.onEdit,
  });

  final NoteKind kind;
  final List<NoteItem> items;
  final VoidCallback onAdd;
  final ValueChanged<NoteItem> onDelete;
  final ValueChanged<NoteItem> onEdit;

  bool get _inspiration => kind == NoteKind.inspiration;

  @override
  Widget build(BuildContext context) {
    final deep = _inspiration ? SparkColors.blueDeep : SparkColors.pinkDeep;
    final mid = _inspiration ? SparkColors.blueMid : SparkColors.pinkMid;
    final soft = _inspiration ? SparkColors.blueSoft : SparkColors.pinkSoft;
    final title = _inspiration ? '灵感' : '记事';
    final subtitle = _inspiration ? '点子 · 火花 · 闪念' : '待办 · 日记 · 碎碎念';
    final emoji = _inspiration ? '💡' : '📒';

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            soft.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.72),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: mid.withValues(alpha: 0.55), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: deep.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: mid, width: 2),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.fredoka(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: deep,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: SparkColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: deep,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: onAdd,
                    borderRadius: BorderRadius.circular(16),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.add_rounded, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _inspiration
                            ? '还没有灵感哦\n点右上角 + 或按住麦克风'
                            : '记事本空空的\n写点什么吧～',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          color: deep.withValues(alpha: 0.75),
                          height: 1.5,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _NoteBubble(
                        item: item,
                        accent: deep,
                        onEdit: () => onEdit(item),
                        onDelete: () => onDelete(item),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onAdd,
                style: FilledButton.styleFrom(
                  backgroundColor: deep,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: const Icon(Icons.mic_none_rounded),
                label: Text(_inspiration ? '语音 / 文字记灵感' : '语音 / 文字记事'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteBubble extends StatelessWidget {
  const _NoteBubble({
    required this.item,
    required this.accent,
    required this.onEdit,
    required this.onDelete,
  });

  final NoteItem item;
  final Color accent;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('MM/dd HH:mm').format(item.createdAt);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.content,
                  style: GoogleFonts.nunito(
                    fontSize: 14.5,
                    height: 1.35,
                    color: SparkColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: SparkColors.muted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onEdit,
            icon: Icon(Icons.edit_rounded, size: 18, color: accent),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 18,
              color: accent.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
