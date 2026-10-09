import 'package:flutter/material.dart';

import '../../../../core/widgets/app_loading.dart';
import '../../data/ai_assistant_repository.dart';

/// AI tools guru: ringkas materi, buat soal, nilai essay.
/// Backend: `/ai/study-assistant`, `/ai/lesson-plan`, `/ai/essay-grade`
/// (`messages:[{role,content}]`).
class AiToolsPage extends StatefulWidget {
  const AiToolsPage({super.key});

  @override
  State<AiToolsPage> createState() => _AiToolsPageState();
}

class _AiToolsPageState extends State<AiToolsPage> {
  final AiAssistantRepository _repo = AiAssistantRepository();
  final TextEditingController _input = TextEditingController();
  String _mode = 'ringkas';
  String? _output;
  bool _busy = false;

  static const Map<String, String> _modes = <String, String>{
    'ringkas': 'Ringkas materi',
    'soal': 'Buat soal latihan',
    'essay': 'Nilai essay',
    'rpp': 'Draf RPP',
  };

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final String text = _input.text.trim();
    if (text.isEmpty || _busy) return;
    setState(() {
      _busy = true;
      _output = null;
    });
    try {
      late final Map<String, dynamic> res;
      if (_mode == 'essay') {
        res = await _repo.gradeEssay(
            'Nilai essay berikut dengan rubrik 0-100 dan beri feedback:\n$text');
      } else if (_mode == 'rpp') {
        res = await _repo
            .generateLessonPlan('Buatkan draf RPP dari materi berikut:\n$text');
      } else if (_mode == 'soal') {
        res = await _repo.generateLessonPlan(
            'Buatkan 5 soal pilihan ganda + 2 essay dari materi berikut:\n$text');
      } else {
        res = await _repo.ask(
            prompt: 'Ringkas materi berikut untuk siswa:\n$text');
      }
      if (mounted) {
        setState(() {
          _output = (res['answer'] ??
                  res['content'] ??
                  res['message'] ??
                  res.toString())
              .toString();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _output = 'Gagal: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Assistant')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Wrap(
            spacing: 8,
            children: <Widget>[
              for (final MapEntry<String, String> e in _modes.entries)
                ChoiceChip(
                  label: Text(e.value),
                  selected: _mode == e.key,
                  onSelected: (_) => setState(() => _mode = e.key),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _input,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Tempel materi / instruksi',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _busy ? null : _run,
            icon: const Icon(Icons.auto_awesome_outlined),
            label: const Text('Proses'),
          ),
          const SizedBox(height: 12),
          if (_busy) const AppLoading(),
          if (_output != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SelectableText(_output!),
              ),
            ),
        ],
      ),
    );
  }
}
