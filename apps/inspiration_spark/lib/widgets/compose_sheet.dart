import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/note_item.dart';
import '../services/speech_service.dart';
import '../theme/app_theme.dart';

Future<String?> showComposeSheet({
  required BuildContext context,
  required NoteKind kind,
  required SpeechService speech,
  String? initial,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return _ComposeSheet(
        kind: kind,
        speech: speech,
        initial: initial ?? '',
      );
    },
  );
}

class _ComposeSheet extends StatefulWidget {
  const _ComposeSheet({
    required this.kind,
    required this.speech,
    required this.initial,
  });

  final NoteKind kind;
  final SpeechService speech;
  final String initial;

  @override
  State<_ComposeSheet> createState() => _ComposeSheetState();
}

class _ComposeSheetState extends State<_ComposeSheet> {
  late final TextEditingController _controller;
  bool _listening = false;
  String _voiceSeed = '';

  bool get _isInspiration => widget.kind == NoteKind.inspiration;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    widget.speech.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleVoice() async {
    if (_listening) {
      await widget.speech.stop();
      setState(() => _listening = false);
      return;
    }

    final ok = await widget.speech.init();
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请允许麦克风权限，并确认系统语音识别可用')),
      );
      return;
    }

    _voiceSeed = _controller.text.trim();
    setState(() => _listening = true);
    await widget.speech.start(
      onResult: (text) {
        if (!mounted) return;
        final merged = _voiceSeed.isEmpty
            ? text
            : '$_voiceSeed${_voiceSeed.endsWith(' ') || text.isEmpty ? '' : ' '}$text';
        setState(() {
          _controller.text = merged;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = _isInspiration ? SparkColors.blueDeep : SparkColors.pinkDeep;
    final soft = _isInspiration ? SparkColors.blueSky : SparkColors.pinkSky;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        decoration: BoxDecoration(
          color: soft,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: accent.withValues(alpha: 0.25), width: 2),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  _isInspiration ? '✨ 捕捉灵感' : '📝 随手记事',
                  style: GoogleFonts.fredoka(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: accent,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: accent),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLines: 6,
              autofocus: true,
              style: GoogleFonts.nunito(fontSize: 16, height: 1.4),
              decoration: InputDecoration(
                hintText: _isInspiration
                    ? '说说突然冒出来的点子…'
                    : '记一件小事、待办或心情…',
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.85),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: _toggleVoice,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: accent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: Icon(
                      _listening ? Icons.stop_circle_rounded : Icons.mic_rounded,
                    ),
                    label: Text(_listening ? '停止语音' : '语音输入'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      final text = _controller.text.trim();
                      if (text.isEmpty) return;
                      Navigator.pop(context, text);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('保存'),
                  ),
                ),
              ],
            ),
            if (_listening)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  '正在听你说… 说完点「停止语音」再保存',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
