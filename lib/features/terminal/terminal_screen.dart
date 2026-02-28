import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/theme/app_colors.dart';

// ─────────────────────────── Models ─────────────────────────────────────────

enum _LineType { prompt, stdout, stderr, info }

class _Line {
  final String text;
  final _LineType type;
  _Line(this.text, this.type);
}

class _Session {
  final String name;
  String cwd;
  final List<_Line> lines = [];
  final TextEditingController input = TextEditingController();
  final ScrollController scroll = ScrollController();
  final FocusNode focus = FocusNode();
  final List<String> history = [];
  int histIdx = -1;
  bool busy = false;
  Process? runningProcess;

  _Session({required this.name, required this.cwd});

  void dispose() {
    runningProcess?.kill();
    input.dispose();
    scroll.dispose();
    focus.dispose();
  }
}

// ─────────────────────────── Screen ──────────────────────────────────────────

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key});
  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen>
    with TickerProviderStateMixin {
  final List<_Session> _sessions = [];
  late TabController _tabCtrl;
  int _activeIdx = 0;

  // Terminal theme
  static const _bg = Color(0xFF0C0C0C);
  static const _promptColor = Color(0xFF4EC9B0); // cyan-green
  static const _pathColor = Color(0xFF569CD6);    // blue
  static const _stdoutColor = Color(0xFFD4D4D4);  // light grey
  static const _stderrColor = Color(0xFFF44747);  // red
  static const _infoColor = Color(0xFF608B4E);    // dark green
  static const _cursorColor = AppColors.primary;
  static const _fontFamily = 'monospace';

  @override
  void initState() {
    super.initState();
    _newSession();
  }

  Future<void> _newSession() async {
    String startDir = '/data/local/tmp';
    try {
      final appDir = await getApplicationDocumentsDirectory();
      startDir = appDir.path;
    } catch (_) {}

    final s = _Session(name: 'Shell ${_sessions.length + 1}', cwd: startDir);
    s.lines.add(_Line(
      'DevPocket Terminal  —  Android Linux Shell\n'
      'Type commands just like a Linux terminal.\n'
      'Tip: many /system/bin commands are available.\n',
      _LineType.info,
    ));
    _sessions.add(s);
    _rebuildTabs(_sessions.length - 1);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => s.focus.requestFocus());
  }

  void _rebuildTabs(int index) {
    _tabCtrl = TabController(length: _sessions.length, vsync: this);
    setState(() {
      _tabCtrl.index = index;
      _activeIdx = index;
    });
  }

  void _closeSession(int i) {
    if (_sessions.length == 1) {
      context.pop();
      return;
    }
    _sessions[i].dispose();
    _sessions.removeAt(i);
    final newIdx = (i >= _sessions.length) ? _sessions.length - 1 : i;
    _rebuildTabs(newIdx);
  }

  // ─────────── Command Execution ───────────

  Future<void> _run(String rawInput, _Session s) async {
    if (rawInput.trim().isEmpty) return;
    final cmd = rawInput.trim();

    // History
    if (s.history.isEmpty || s.history.last != cmd) {
      s.history.add(cmd);
    }
    s.histIdx = -1;

    // Echo the prompt + command
    s.lines.add(_Line('${_prompt(s)} $cmd', _LineType.prompt));

    // === Built-in: exit ===
    if (cmd == 'exit' || cmd == 'quit') {
      _closeSession(_activeIdx);
      return;
    }

    // === Built-in: clear ===
    if (cmd == 'clear' || cmd == 'reset') {
      setState(() => s.lines.clear());
      return;
    }

    // === Built-in: cd ===
    if (cmd.startsWith('cd')) {
      _handleCd(cmd, s);
      return;
    }

    // === Execute real shell command ===
    setState(() => s.busy = true);
    _scrollToBottom(s);

    try {
      final process = await Process.start(
        'sh',
        ['-c', cmd],
        workingDirectory: _resolveDir(s.cwd),
        runInShell: false,
      );
      s.runningProcess = process;

      // Stream stdout
      final stdoutSub = process.stdout
          .transform(const SystemEncoding().decoder)
          .listen((chunk) {
        if (!mounted) return;
        final lines = chunk.split('\n');
        setState(() {
          for (int i = 0; i < lines.length; i++) {
            final l = lines[i];
            if (i < lines.length - 1 || l.isNotEmpty) {
              s.lines.add(_Line(l, _LineType.stdout));
            }
          }
        });
        _scrollToBottom(s);
      });

      // Stream stderr
      final stderrSub = process.stderr
          .transform(const SystemEncoding().decoder)
          .listen((chunk) {
        if (!mounted) return;
        setState(() {
          for (final l in chunk.split('\n')) {
            if (l.isNotEmpty) s.lines.add(_Line(l, _LineType.stderr));
          }
        });
        _scrollToBottom(s);
      });

      final exitCode = await process.exitCode;
      await Future.wait([stdoutSub.cancel(), stderrSub.cancel()]);
      s.runningProcess = null;

      if (mounted) {
        setState(() => s.busy = false);
      }

      // Show exit code if non-zero
      if (exitCode != 0 && mounted) {
        setState(() => s.lines.add(
            _Line('[Process exited with code $exitCode]', _LineType.stderr)));
      }
    } on ProcessException catch (e) {
      if (mounted) {
        setState(() {
          s.lines.add(_Line('sh: ${e.message}', _LineType.stderr));
          s.busy = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          s.lines.add(_Line('Error: $e', _LineType.stderr));
          s.busy = false;
        });
      }
    }

    _scrollToBottom(s);
  }

  void _handleCd(String cmd, _Session s) {
    final parts = cmd.trim().split(RegExp(r'\s+'));
    String target;

    if (parts.length < 2 || parts[1].isEmpty || parts[1] == '~') {
      // cd with no args → go to home
      target = s.cwd; // stay where we are on Android (no real HOME)
      s.lines.add(_Line(s.cwd, _LineType.stdout));
      setState(() {});
      return;
    }

    target = parts[1];

    // Resolve relative vs absolute
    final resolved = target.startsWith('/')
        ? Directory(target)
        : Directory('${s.cwd}/$target');

    final normalized = Directory(resolved.path).absolute;

    if (normalized.existsSync()) {
      setState(() => s.cwd = normalized.path);
    } else {
      setState(() => s.lines
          .add(_Line('cd: $target: No such file or directory', _LineType.stderr)));
    }
    _scrollToBottom(s);
  }

  String _resolveDir(String cwd) {
    try {
      if (Directory(cwd).existsSync()) return cwd;
    } catch (_) {}
    return '/data/local/tmp';
  }

  String _prompt(_Session s) {
    final shortened = _shortenPath(s.cwd);
    return 'shell@android:$shortened\$';
  }

  String _shortenPath(String path) {
    if (path.length <= 30) return path;
    final parts = path.split('/');
    if (parts.length <= 3) return path;
    return '…/${parts.sublist(parts.length - 2).join('/')}';
  }

  void _scrollToBottom(_Session s) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (s.scroll.hasClients) {
        s.scroll.animateTo(
          s.scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _killRunning(_Session s) {
    s.runningProcess?.kill(ProcessSignal.sigint);
    if (mounted) {
      setState(() {
        s.lines.add(_Line('^C', _LineType.stderr));
        s.busy = false;
        s.runningProcess = null;
      });
    }
  }

  // ─────────── History Navigation ───────────

  void _historyUp(_Session s) {
    if (s.history.isEmpty) return;
    if (s.histIdx < s.history.length - 1) s.histIdx++;
    s.input.text = s.history[s.history.length - 1 - s.histIdx];
    s.input.selection =
        TextSelection.collapsed(offset: s.input.text.length);
  }

  void _historyDown(_Session s) {
    if (s.histIdx <= 0) {
      s.histIdx = -1;
      s.input.clear();
      return;
    }
    s.histIdx--;
    s.input.text = s.history[s.history.length - 1 - s.histIdx];
    s.input.selection =
        TextSelection.collapsed(offset: s.input.text.length);
  }

  // ─────────── Color helpers ───────────

  Color _color(_LineType t) => switch (t) {
        _LineType.prompt => _promptColor,
        _LineType.stdout => _stdoutColor,
        _LineType.stderr => _stderrColor,
        _LineType.info => _infoColor,
      };

  // ─────────── Build ───────────

  @override
  void dispose() {
    for (final s in _sessions) {
      s.dispose();
    }
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_sessions.isEmpty) return const SizedBox();
    final s = _sessions[_activeIdx];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _bg,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _bg,
        appBar: _buildAppBar(s),
        body: Column(
          children: [
            // ─── Output area ────────────────────────────────
            Expanded(
              child: ListView.builder(
                controller: s.scroll,
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
                itemCount: s.lines.length,
                itemBuilder: (_, i) {
                  final line = s.lines[i];
                  return _buildLine(line, s);
                },
              ),
            ),

            // ─── Divider ───────────────────────────────────
            Container(height: 1, color: Colors.white12),

            // ─── Prompt + input ────────────────────────────
            _buildInputRow(s),

            // ─── Quick-command bar ─────────────────────────
            _buildQuickBar(s),

            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(_Session s) {
    return AppBar(
      backgroundColor: const Color(0xFF111111),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.grey, size: 20),
        onPressed: () => context.pop(),
      ),
      titleSpacing: 0,
      title: _sessions.length == 1
          ? Row(children: [
              const Icon(Icons.terminal_rounded, size: 14, color: _promptColor),
              const SizedBox(width: 6),
              Text(
                _shortenPath(s.cwd),
                style: const TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 12,
                    color: _pathColor),
                overflow: TextOverflow.ellipsis,
              ),
            ])
          : TabBar(
              controller: _tabCtrl,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: _promptColor,
              labelColor: _promptColor,
              unselectedLabelColor: Colors.grey,
              dividerColor: Colors.transparent,
              onTap: (i) => setState(() => _activeIdx = i),
              tabs: List.generate(_sessions.length, (i) {
                return Tab(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.terminal_rounded, size: 13),
                    const SizedBox(width: 5),
                    Text(_sessions[i].name,
                        style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () => _closeSession(i),
                      child: const Icon(Icons.close, size: 13),
                    ),
                  ]),
                );
              }),
            ),
      actions: [
        // Ctrl+C button
        if (s.busy)
          TextButton(
            onPressed: () => _killRunning(s),
            child: const Text('[Ctrl+C]',
                style: TextStyle(
                    color: _stderrColor,
                    fontFamily: _fontFamily,
                    fontSize: 12)),
          ),
        IconButton(
          icon: const Icon(Icons.add_rounded, color: Colors.grey, size: 20),
          tooltip: 'New session',
          onPressed: _newSession,
        ),
        IconButton(
          icon: const Icon(Icons.copy_rounded, color: Colors.grey, size: 18),
          tooltip: 'Copy output',
          onPressed: () {
            final text = s.lines.map((l) => l.text).join('\n');
            Clipboard.setData(ClipboardData(text: text));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Output copied'),
                duration: Duration(seconds: 1)));
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded,
              color: Colors.grey, size: 18),
          tooltip: 'Clear',
          onPressed: () => setState(() => s.lines.clear()),
        ),
      ],
    );
  }

  Widget _buildLine(_Line line, _Session s) {
    // Render the prompt line with color-coded parts
    if (line.type == _LineType.prompt) {
      final text = line.text;
      final dollarIdx = text.indexOf('\$');
      if (dollarIdx != -1) {
        final promptPart = text.substring(0, dollarIdx + 1);
        final cmdPart = text.substring(dollarIdx + 2);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 13,
                  height: 1.5),
              children: [
                TextSpan(
                  text: promptPart,
                  style: const TextStyle(
                      color: _promptColor, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: ' $cmdPart',
                  style: const TextStyle(color: _stdoutColor),
                ),
              ],
            ),
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.5),
      child: SelectableText(
        line.text,
        style: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 13,
          height: 1.55,
          color: _color(line.type),
        ),
      ),
    );
  }

  Widget _buildInputRow(_Session s) {
    return Container(
      color: const Color(0xFF111111),
      padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Prompt label
          RichText(
            text: TextSpan(
              style: const TextStyle(fontFamily: _fontFamily, fontSize: 13),
              children: [
                TextSpan(
                  text: _shortenPath(s.cwd),
                  style: const TextStyle(color: _pathColor),
                ),
                const TextSpan(
                    text: ' \$ ',
                    style: TextStyle(
                        color: _promptColor, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Input field
          Expanded(
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (evt) {
                if (evt is KeyDownEvent) {
                  if (evt.logicalKey == LogicalKeyboardKey.arrowUp) {
                    _historyUp(s);
                  } else if (evt.logicalKey == LogicalKeyboardKey.arrowDown) {
                    _historyDown(s);
                  }
                }
              },
              child: TextField(
                controller: s.input,
                focusNode: s.focus,
                enabled: !s.busy,
                style: const TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 13,
                    color: _stdoutColor),
                cursorColor: _cursorColor,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: 'command...',
                  hintStyle:
                      TextStyle(color: Colors.grey, fontFamily: _fontFamily),
                  contentPadding: EdgeInsets.symmetric(vertical: 4),
                ),
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                onSubmitted: (v) {
                  s.input.clear();
                  _run(v, s);
                },
              ),
            ),
          ),

          // History arrows
          GestureDetector(
            onTap: () => _historyUp(s),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.keyboard_arrow_up_rounded,
                  color: Colors.grey, size: 20),
            ),
          ),
          GestureDetector(
            onTap: () => _historyDown(s),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey, size: 20),
            ),
          ),

          // Run button
          GestureDetector(
            onTap: s.busy
                ? null
                : () {
                    final v = s.input.text;
                    s.input.clear();
                    _run(v, s);
                  },
            child: Container(
              margin: const EdgeInsets.only(left: 4),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: s.busy
                    ? Colors.grey.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: s.busy
                        ? Colors.grey.withOpacity(0.3)
                        : AppColors.primary.withOpacity(0.5)),
              ),
              child: Text(
                s.busy ? '…' : 'RUN',
                style: TextStyle(
                  color: s.busy ? Colors.grey : AppColors.primary,
                  fontSize: 11,
                  fontFamily: _fontFamily,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickBar(_Session s) {
    const cmds = [
      'ls -la',
      'pwd',
      'whoami',
      'uname -a',
      'env',
      'ps',
      'df -h',
      'free',
      'cat /proc/cpuinfo',
      'ip addr',
      'netstat -tuln',
      'ping -c 4 8.8.8.8',
      'curl -s https://httpbin.org/get',
    ];

    return Container(
      color: const Color(0xFF0A0A0A),
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        itemCount: cmds.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cmd = cmds[i];
          return GestureDetector(
            onTap: () {
              s.input.text = cmd;
              s.input.selection =
                  TextSelection.collapsed(offset: cmd.length);
              s.focus.requestFocus();
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                cmd,
                style: const TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
