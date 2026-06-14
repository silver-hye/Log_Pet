import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/pet_instance.dart';
import '../services/diary_analyzer.dart';

class DiaryScreen extends StatefulWidget {
  final String userId;
  final PetInstance pet;

  const DiaryScreen({
    super.key,
    required this.userId,
    required this.pet,
  });

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final _diaryController = TextEditingController();
  String _message = '';
  String _emotion = '';
  bool _isLoading = false;
  final AudioPlayer _sfxPlayer = AudioPlayer();

  Future<void> _playButton() async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('sounds/button.mp3'));
    } catch (e) {}
  }

  String _getToday() {
    final now = DateTime.now();
    return '${now.year}년 ${now.month}월 ${now.day}일 ${_getWeekday(now.weekday)}';
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

  Future<void> _onSubmit() async {
    await _playButton();
    final text = _diaryController.text.trim();

    if (text.isEmpty) {
      setState(() => _message = '일기를 입력해주세요');
      return;
    }

    setState(() => _isLoading = true);

    final result = await DiaryAnalyzer.analyze(
      widget.userId,
      text,
      widget.pet,
    );

    setState(() {
      _isLoading = false;
      if (!result['success']) {
        _message = result['message'];
      } else {
        _emotion = result['emotion'];
        _message = _getEmotionMessage(_emotion, result);
      }
    });
  }

  String _getEmotionMessage(String emotion, Map<String, dynamic> result) {
    String petReaction = '';
    switch (emotion) {
      case 'happy':
        petReaction = '${widget.pet.name}이(가) 함께 기뻐해요! 🎉';
        break;
      case 'sad':
        petReaction = '${widget.pet.name}이(가) 위로해줘요 🤗';
        break;
      default:
        petReaction = '${widget.pet.name}이(가) 고마워해요 🐾';
    }
    return '$petReaction\n경험치 +${result['expGained']} 친밀도 +${result['affectionGained']}';
  }

  @override
  void dispose() {
    _sfxPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('오늘의 일기')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                // 날짜
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
                    _getToday(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.purple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${widget.pet.name}에게 오늘 하루를 들려주세요 📔',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _diaryController,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    hintText: '오늘 있었던 일을 자유롭게 써보세요...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                if (_message.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: _emotion == 'sad'
                            ? Colors.blue
                            : _emotion == 'happy'
                                ? Colors.orange
                                : Colors.purple,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onSubmit,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('작성 완료'),
                  ),
                ),
                if (_message.isNotEmpty && _emotion.isNotEmpty)
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