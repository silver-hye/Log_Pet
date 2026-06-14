import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/user.dart';
import '../services/storage_db.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _checkPasswordController = TextEditingController();
  final _nicknameController = TextEditingController();
  String _errorMessage = '';
  final AudioPlayer _sfxPlayer = AudioPlayer();

  Future<void> _playButton() async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('sounds/button.mp3'));
    } catch (e) {}
  }

  Future<void> _onRegister() async {
    await _playButton();
    final userId = _userIdController.text.trim();
    final password = _passwordController.text.trim();
    final checkPassword = _checkPasswordController.text.trim();
    final nickname = _nicknameController.text.trim();

    if (userId.isEmpty || password.isEmpty || nickname.isEmpty) {
      setState(() => _errorMessage = '모든 정보를 입력해야 합니다');
      return;
    }

    if (password != checkPassword) {
      setState(() => _errorMessage = '비밀번호가 일치하지 않습니다');
      return;
    }

    final isDuplicate = await StorageDB.checkDuplicate(userId);
    if (isDuplicate) {
      setState(() => _errorMessage = '이미 존재하는 아이디입니다');
      return;
    }

    final user = User(
      userId: userId,
      password: password,
      nickname: nickname,
    );

    final success = await StorageDB.saveUser(user);
    if (!success) {
      setState(() => _errorMessage = '저장 오류가 발생했습니다. 다시 시도해주세요');
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('회원가입이 완료됐습니다!')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _sfxPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '🐾 새 계정 만들기',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _userIdController,
                  decoration: const InputDecoration(
                    labelText: '아이디',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(
                    labelText: '닉네임',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '비밀번호',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _checkPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '비밀번호 확인',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onRegister,
                    child: const Text('등록'),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await _playButton();
                    if (!mounted) return;
                    Navigator.pop(context);
                  },
                  child: const Text('로그인으로 돌아가기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}