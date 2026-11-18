import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/shortcut_service.dart';
import '../theme/app_theme.dart';
import '../widgets/cartoon_backdrop.dart';
import 'workspace_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.shortcutService,
    this.initialPanel,
  });

  final ShortcutService shortcutService;
  final String? initialPanel;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bob;
  bool _pinning = false;

  @override
  void initState() {
    super.initState();
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialPanel != null) {
        _openWorkspace(focus: widget.initialPanel);
      }
    });
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  Future<void> _openWorkspace({String? focus}) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => WorkspacePage(
          initialFocus: focus,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Future<void> _pinShortcut() async {
    setState(() => _pinning = true);
    final ok = await widget.shortcutService.pinHomeShortcut(type: 'home');
    if (!mounted) return;
    setState(() => _pinning = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? '已弹出系统确认，请点「添加」把快捷方式放到桌面'
              : '当前桌面不支持一键固定，可长按应用图标使用快捷方式',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CartoonBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                AnimatedBuilder(
                  animation: _bob,
                  builder: (context, child) {
                    final dy = (_bob.value - 0.5) * 10;
                    return Transform.translate(
                      offset: Offset(0, dy),
                      child: child,
                    );
                  },
                  child: Column(
                    children: [
                      Text(
                        '灵感火花',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          fontSize: 42,
                          fontWeight: FontWeight.w700,
                          color: SparkColors.ink,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '左边灵感蓝 · 右边记事粉',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: SparkColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _PreviewDoor(
                          label: '灵感',
                          emoji: '💡',
                          color: SparkColors.blueDeep,
                          soft: SparkColors.blueSoft,
                          onTap: () => _openWorkspace(focus: 'inspiration'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PreviewDoor(
                          label: '记事',
                          emoji: '📒',
                          color: SparkColors.pinkDeep,
                          soft: SparkColors.pinkSoft,
                          onTap: () => _openWorkspace(focus: 'notes'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () => _openWorkspace(),
                  style: FilledButton.styleFrom(
                    backgroundColor: SparkColors.ink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: Text(
                    '点进去开始记录',
                    style: GoogleFonts.fredoka(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _pinning ? null : _pinShortcut,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SparkColors.blueDeep,
                    side: const BorderSide(
                      color: SparkColors.blueMid,
                      width: 2,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  icon: _pinning
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_to_home_screen_rounded),
                  label: Text(
                    '一键设置桌面快捷键',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '也可长按桌面图标，快速打开「写灵感 / 写记事」',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: SparkColors.muted,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewDoor extends StatefulWidget {
  const _PreviewDoor({
    required this.label,
    required this.emoji,
    required this.color,
    required this.soft,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final Color color;
  final Color soft;
  final VoidCallback onTap;

  @override
  State<_PreviewDoor> createState() => _PreviewDoorState();
}

class _PreviewDoorState extends State<_PreviewDoor> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapCancel: () => setState(() => _scale = 1),
      onTapUp: (_) {
        setState(() => _scale = 1);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            color: widget.soft,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: widget.color, width: 3),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 10),
              Text(
                widget.label,
                style: GoogleFonts.fredoka(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
