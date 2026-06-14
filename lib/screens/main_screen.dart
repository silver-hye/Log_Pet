import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/pet_instance.dart';
import '../services/storage_db.dart';
import '../services/time_synchronizer.dart';
import 'nurturing_screen.dart';
import 'login_screen.dart';
import 'recall_screen.dart';

class MainScreen extends StatefulWidget {
  final String userId;
  const MainScreen({super.key, required this.userId});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  PetInstance? _pet;
  bool _isLoading = true;
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  double _bgmVolume = 0.5;

  @override
  void initState() {
    super.initState();
    _loadPet();
    _playBgm();
  }

  Future<void> _playBgm() async {
    try {
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.setVolume(_bgmVolume);
      await _bgmPlayer.play(AssetSource('sounds/bgm.mp3'));
    } catch (e) {}
  }

  Future<void> _playButton() async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('sounds/button.mp3'));
    } catch (e) {}
  }

  Future<void> _loadPet() async {
    final pet = await StorageDB.loadPet(widget.userId);
    if (pet != null) {
      await TimeSynchronizer.sync(widget.userId, pet);
    }
    setState(() {
      _pet = pet;
      _isLoading = false;
    });
  }

  void _onLogout() async {
    await _playButton();
    await _bgmPlayer.stop();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
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

  @override
  void dispose() {
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('LOG-PET'),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('배경음악 볼륨'),
                  content: StatefulBuilder(
                    builder: (context, setDialogState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${(_bgmVolume * 100).toInt()}%'),
                          Slider(
                            value: _bgmVolume,
                            min: 0.0,
                            max: 1.0,
                            divisions: 10,
                            onChanged: (value) {
                              setDialogState(() => _bgmVolume = value);
                              setState(() => _bgmVolume = value);
                              _bgmPlayer.setVolume(value);
                            },
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('🔇'),
                              Text('🔊'),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('확인'),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _onLogout,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 오늘 날짜
                Container(
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
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.purple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_pet == null) ...[
                  const Text(
                    '반려동물이 없어요!\n새 친구를 만들어보세요 🐣',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      await _playButton();
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NurturingScreen(
                            userId: widget.userId,
                            pet: PetInstance(name: '', species: ''),
                            isNew: true,
                          ),
                        ),
                      );
                      _loadPet();
                    },
                    child: const Text('새 친구 만들기'),
                  ),
                ] else ...[
                  Text(
                    _pet!.species == '강아지' ? '🐶' : '🐰',
                    style: const TextStyle(fontSize: 80),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_pet!.name} (${_pet!.species})',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('성장 단계: ${_pet!.growthStage}'),
                  const SizedBox(height: 24),
                  _buildStatBar('배고픔', _pet!.hunger),
                  _buildStatBar('청결도', _pet!.cleanliness),
                  _buildStatBar('친밀도', _pet!.affection),
                  _buildStatBar('경험치', _pet!.exp.clamp(0, 100)),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _playButton();
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NurturingScreen(
                              userId: widget.userId,
                              pet: _pet!,
                              isNew: false,
                            ),
                          ),
                        );
                        _loadPet();
                      },
                      child: const Text('반려동물 돌보기'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        await _playButton();
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecallScreen(userId: widget.userId),
                          ),
                        );
                      },
                      child: const Text('추억 보기'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatBar(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: $value'),
          LinearProgressIndicator(
            value: value / 100,
            color: value < 30 ? Colors.red : Colors.green,
            backgroundColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }
}