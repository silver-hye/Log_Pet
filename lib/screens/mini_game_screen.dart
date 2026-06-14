import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MiniGameScreen extends StatefulWidget {
  final String userId;
  final String species;

  const MiniGameScreen({
    super.key,
    required this.userId,
    required this.species,
  });

  @override
  State<MiniGameScreen> createState() => _MiniGameScreenState();
}

class _MiniGameScreenState extends State<MiniGameScreen>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isPlaying = false;
  bool _isGameOver = false;
  int _score = 0;
  int _highScore = 0;

  // 동물 상태
  double _petY = 0;
  double _petVelocity = 0;
  bool _isDucking = false;
  bool _isJumping = false;
  final double _gravity = 0.8;
  final double _jumpForce = -15;
  final double _groundY = 0;

  // 장애물 목록
  List<Map<String, dynamic>> _obstacles = [];
  double _speed = 5;
  int _frameCount = 0;
  int _nextObstacleIn = 60;

  late AnimationController _gameController;

  @override
  void initState() {
    super.initState();
    _gameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_gameLoop);
  }

  String _getPetEmoji() {
    if (_isDucking) {
      switch (widget.species) {
        case '강아지': return '🐕';
        case '토끼': return '🐇';
        case '고양이': return '🙀';
        case '햄스터': return '🐹';
        default: return '🐾';
      }
    }
    switch (widget.species) {
      case '강아지': return '🐶';
      case '토끼': return '🐰';
      case '고양이': return '🐱';
      case '햄스터': return '🐹';
      default: return '🐾';
    }
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _isGameOver = false;
      _score = 0;
      _petY = _groundY;
      _petVelocity = 0;
      _isDucking = false;
      _isJumping = false;
      _obstacles = [];
      _speed = 5;
      _frameCount = 0;
      _nextObstacleIn = 60;
    });
    _gameController.repeat();
  }

  void _jump() {
    if (!_isPlaying || _isDucking) return;
    if (_petY >= _groundY) {
      setState(() {
        _petVelocity = _jumpForce;
        _isJumping = true;
      });
      _audioPlayer.play(AssetSource('sounds/happy.mp3'));
    }
  }

  void _duck() {
    if (!_isPlaying) return;
    if (_petY >= _groundY) {
      setState(() => _isDucking = true);
    }
  }

  void _standUp() {
    setState(() => _isDucking = false);
  }

  void _gameLoop() {
    if (!_isPlaying || _isGameOver) return;

    setState(() {
      _frameCount++;

      // 중력
      if (!_isDucking) {
        _petVelocity += _gravity;
        _petY += _petVelocity;
      }

      if (_petY >= _groundY) {
        _petY = _groundY;
        _petVelocity = 0;
        _isJumping = false;
      }

      // 장애물 생성
      if (_frameCount >= _nextObstacleIn) {
        _frameCount = 0;
        // 랜덤 장애물 (점프/숙이기)
        final isHigh = _score % 3 == 2; // 3번째마다 높은 장애물
        _obstacles.add({
          'x': 420.0,
          'type': isHigh ? 'high' : 'low', // high=숙이기, low=점프
        });
        // 다음 장애물 간격 (점수 오를수록 짧아짐)
        _nextObstacleIn = (80 - _score * 2).clamp(30, 80);
      }

      // 장애물 이동
      for (var obs in _obstacles) {
        obs['x'] = (obs['x'] as double) - _speed;
      }
      _obstacles.removeWhere((obs) => (obs['x'] as double) < -30);

      // 점수
      if (_frameCount == 0) {
        _score++;
        _speed = 5 + (_score * 0.2);
      }

      // 충돌 감지
      for (var obs in _obstacles) {
        final ox = obs['x'] as double;
        final isHigh = obs['type'] == 'high';

        if (ox < 80 && ox > 20) {
          if (isHigh) {
            // 높은 장애물 — 숙여야 통과
            if (!_isDucking) {
              _gameOver();
              return;
            }
          } else {
            // 낮은 장애물 — 점프해야 통과
            if (_petY >= _groundY) {
              _gameOver();
              return;
            }
          }
        }
      }
    });
  }

  void _gameOver() {
    _isGameOver = true;
    _isPlaying = false;
    _gameController.stop();
    if (_score > _highScore) _highScore = _score;
    _audioPlayer.play(AssetSource('sounds/wash.mp3'));
  }

  @override
  void dispose() {
    _gameController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎮 미니게임')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 점수
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('점수: $_score',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('최고: $_highScore',
                      style: const TextStyle(
                          fontSize: 20, color: Colors.purple)),
                ],
              ),
              const SizedBox(height: 8),
              // 조작 안내
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('⬆️ 탭 = 점프', style: TextStyle(fontSize: 13)),
                  Text('⬇️ 길게 누르기 = 숙이기',
                      style: TextStyle(fontSize: 13)),
                ],
              ),
              const SizedBox(height: 8),
              // 게임 화면
              GestureDetector(
                onTap: _isPlaying ? _jump : _startGame,
                onLongPressStart: (_) => _duck(),
                onLongPressEnd: (_) => _standUp(),
                child: Container(
                  width: 400,
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.lightBlue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Stack(
                    children: [
                      // 구름
                      const Positioned(
                        top: 20,
                        left: 50,
                        child: Text('☁️', style: TextStyle(fontSize: 24)),
                      ),
                      const Positioned(
                        top: 10,
                        left: 200,
                        child: Text('☁️', style: TextStyle(fontSize: 20)),
                      ),
                      // 바닥선
                      Positioned(
                        bottom: 45,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          color: Colors.green[700],
                        ),
                      ),
                      // 동물
                      Positioned(
                        left: 40,
                        bottom: _isDucking ? 45 : 45 - _petY,
                        child: Text(
                          _getPetEmoji(),
                          style: TextStyle(
                            fontSize: _isDucking ? 24 : 36,
                          ),
                        ),
                      ),
                      // 장애물들
                      ..._obstacles.map((obs) {
                        final isHigh = obs['type'] == 'high';
                        return Positioned(
                          left: obs['x'] as double,
                          bottom: isHigh ? 75 : 45,
                          child: Text(
                            isHigh ? '🦅' : '🌵',
                            style: const TextStyle(fontSize: 28),
                          ),
                        );
                      }),
                      // 장애물 힌트
                      ..._obstacles.map((obs) {
                        final isHigh = obs['type'] == 'high';
                        final ox = obs['x'] as double;
                        if (ox > 50 && ox < 200) {
                          return Positioned(
                            left: ox,
                            bottom: 20,
                            child: Text(
                              isHigh ? '숙여!' : '점프!',
                              style: TextStyle(
                                fontSize: 10,
                                color: isHigh ? Colors.blue : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      // 게임 오버
                      if (_isGameOver)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('💥 게임 오버!',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                                Text('점수: $_score'),
                                if (_score == _highScore && _score > 0)
                                  const Text('🏆 최고 기록!',
                                      style: TextStyle(color: Colors.orange)),
                                const SizedBox(height: 8),
                                const Text('탭해서 다시 시작',
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      // 시작 전
                      if (!_isPlaying && !_isGameOver)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${_getPetEmoji()} 점프 게임!',
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                const Text('탭 = 점프\n길게 누르기 = 숙이기',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey)),
                                const SizedBox(height: 4),
                                const Text('탭해서 시작!',
                                    style: TextStyle(color: Colors.purple)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('돌아가기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}