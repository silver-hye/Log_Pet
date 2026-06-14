import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MiniGameScreen extends StatefulWidget {
  final String userId;
  const MiniGameScreen({super.key, required this.userId});

  @override
  State<MiniGameScreen> createState() => _MiniGameScreenState();
}

class _MiniGameScreenState extends State<MiniGameScreen>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // 게임 상태
  bool _isPlaying = false;
  bool _isGameOver = false;
  int _score = 0;
  int _highScore = 0;

  // 강아지 위치
  double _dogY = 0;
  double _dogVelocity = 0;
  bool _isJumping = false;
  final double _gravity = 0.8;
  final double _jumpForce = -15;
  final double _groundY = 0;

  // 장애물
  double _obstacleX = 400;
  double _obstacleHeight = 40;
  double _speed = 5;

  late AnimationController _gameController;

  @override
  void initState() {
    super.initState();
    _gameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_gameLoop);
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _isGameOver = false;
      _score = 0;
      _dogY = _groundY;
      _dogVelocity = 0;
      _obstacleX = 400;
      _speed = 5;
    });
    _gameController.repeat();
  }

  void _jump() {
    if (!_isPlaying) return;
    if (_dogY >= _groundY) {
      setState(() {
        _dogVelocity = _jumpForce;
        _isJumping = true;
      });
      _audioPlayer.play(AssetSource('sounds/happy.mp3'));
    }
  }

  void _gameLoop() {
    if (!_isPlaying || _isGameOver) return;

    setState(() {
      // 중력 적용
      _dogVelocity += _gravity;
      _dogY += _dogVelocity;

      // 바닥 충돌
      if (_dogY >= _groundY) {
        _dogY = _groundY;
        _dogVelocity = 0;
        _isJumping = false;
      }

      // 장애물 이동
      _obstacleX -= _speed;

      // 장애물 재생성
      if (_obstacleX < -30) {
        _obstacleX = 400;
        _score++;
        // 점수마다 속도 증가
        _speed = 5 + (_score * 0.3);
      }

      // 충돌 감지
      if (_obstacleX < 80 && _obstacleX > 20 && _dogY > -_obstacleHeight + 20) {
        _gameOver();
      }
    });
  }

  void _gameOver() {
    _isGameOver = true;
    _isPlaying = false;
    _gameController.stop();
    if (_score > _highScore) {
      _highScore = _score;
    }
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
                  Text('점수: $_score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('최고: $_highScore', style: const TextStyle(fontSize: 20, color: Colors.purple)),
                ],
              ),
              const SizedBox(height: 16),
              // 게임 화면
              GestureDetector(
                onTap: _isPlaying ? _jump : _startGame,
                child: Container(
                  width: 400,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.lightBlue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Stack(
                    children: [
                      // 하늘
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
                        bottom: 40,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          color: Colors.green[700],
                        ),
                      ),
                      // 강아지
                      Positioned(
                        left: 40,
                        bottom: 40 - _dogY,
                        child: Text(
                          _isJumping ? '🐶' : '🐕',
                          style: const TextStyle(fontSize: 36),
                        ),
                      ),
                      // 장애물
                      Positioned(
                        left: _obstacleX,
                        bottom: 40,
                        child: Container(
                          width: 20,
                          height: _obstacleHeight,
                          decoration: BoxDecoration(
                            color: Colors.green[700],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('🌵', style: TextStyle(fontSize: 20)),
                        ),
                      ),
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
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('🐶 점프 게임!',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                Text('탭해서 시작 / 점프',
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '탭하면 점프해요!\n갈수록 빨라져요 🏃',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
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