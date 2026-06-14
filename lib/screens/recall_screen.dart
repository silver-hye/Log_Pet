import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/activity_log.dart';
import '../services/storage_db.dart';

class RecallScreen extends StatefulWidget {
  final String userId;

  const RecallScreen({super.key, required this.userId});

  @override
  State<RecallScreen> createState() => _RecallScreenState();
}

class _RecallScreenState extends State<RecallScreen> {
  List<ActivityLog> _logs = [];
  ActivityLog? _selectedLog;
  bool _isLoading = true;
  final AudioPlayer _sfxPlayer = AudioPlayer();

  Future<void> _playButton() async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('sounds/button.mp3'));
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final logs = await StorageDB.loadLogs(widget.userId);
    setState(() {
      _logs = logs;
      _isLoading = false;
      if (logs.isNotEmpty) {
        _selectRandomLog();
      }
    });
  }

  void _selectRandomLog() {
    final diaryLogs = _logs.where((l) => l.action == 'diary').toList();
    if (diaryLogs.isEmpty) {
      _selectedLog = _logs.isNotEmpty ? _logs.last : null;
    } else {
      diaryLogs.shuffle();
      _selectedLog = diaryLogs.first;
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}년 ${dt.month}월 ${dt.day}일 ${_getWeekday(dt.weekday)}';
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1: return '월요일';
      case 2: return '화요일';
      case 3: return '수요일';
      case 4: return '목요일';
      case 5: return '금요일';
      case 6: return '토요일';
      case 7: return '일요일';
      default: return '';
    }
  }

  String _getRecallMessage() {
    if (_selectedLog == null) return '아직 추억이 없어요 🐾';
    if (_selectedLog!.action == 'diary') {
      return '"${_selectedLog!.content.length > 50 ? '${_selectedLog!.content.substring(0, 50)}...' : _selectedLog!.content}"';
    }
    return '그날 함께 ${_selectedLog!.content}을 했던 게 기억나요!';
  }

  @override
  void dispose() {
    _sfxPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('추억 보기')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: _isLoading
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 오늘 날짜
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _formatDate(DateTime.now()),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.purple,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        '🐾',
                        style: TextStyle(fontSize: 64),
                      ),
                      const SizedBox(height: 16),
                      // 추억 날짜
                      if (_selectedLog != null)
                        Text(
                          _formatDate(_selectedLog!.timestamp),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      const SizedBox(height: 8),
                      // 추억 내용
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.purple[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.purple),
                        ),
                        child: Text(
                          _getRecallMessage(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 전체 일기 목록
                      if (_logs.where((l) => l.action == 'diary').isNotEmpty)
                        ExpansionTile(
                          title: const Text('📔 전체 일기 보기'),
                          children: _logs
                              .where((l) => l.action == 'diary')
                              .map((log) => ListTile(
                                    title: Text(
                                      log.content.length > 30
                                          ? '${log.content.substring(0, 30)}...'
                                          : log.content,
                                    ),
                                    subtitle: Text(_formatDate(log.timestamp)),
                                    onTap: () {
                                      setState(() => _selectedLog = log);
                                    },
                                  ))
                              .toList(),
                        ),
                      const SizedBox(height: 12),
                      if (_logs.length > 1)
                        ElevatedButton(
                          onPressed: () async {
                            await _playButton();
                            setState(() => _selectRandomLog());
                          },
                          child: const Text('다른 추억 보기'),
                        ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () async {
                          await _playButton();
                          if (!mounted) return;
                          Navigator.pop(context);
                        },
                        child: const Text('돌아가기'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}