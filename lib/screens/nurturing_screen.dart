import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/pet_instance.dart';
import '../models/activity_log.dart';
import '../services/storage_db.dart';
import 'diary_screen.dart';
import 'mini_game_screen.dart';

class NurturingScreen extends StatefulWidget {
  final String userId;
  final PetInstance pet;
  final bool isNew;

  const NurturingScreen({
    super.key,
    required this.userId,
    required this.pet,
    required this.isNew,
  });

  @override
  State<NurturingScreen> createState() => _NurturingScreenState();
}

class _NurturingScreenState extends State<NurturingScreen>
    with TickerProviderStateMixin {
  late PetInstance _pet;
  final _nameController = TextEditingController();
  String _selectedSpecies = '강아지';
  final List<String> _speciesList = ['강아지', '토끼', '고양이', '햄스터'];
  String _message = '';
  final AudioPlayer _audioPlayer = AudioPlayer();

  int _feedCount = 0;
  int _walkCount = 0;
  int _washCount = 0;
  int _petCount = 0;

  // 동물 위치
  double _petX = 100;
  double _petY = 100;
  double _petDX = 2;
  double _petDY = 1.5;
  bool _petLookingRight = true;
  bool _showSmile = false;

  // 똥 시스템
  List<Offset> _poops = [];
  int _poopTimer = 0;

  late AnimationController _moveController;

  @override
  void initState() {
    super.initState();
    _pet = widget.pet;
    _loadCounts();
    _loadPoops();

    // 동물 움직임
    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..addListener(_movePet);
    _moveController.repeat();

    // 스탯 감소 시작
    Future.delayed(const Duration(minutes: 1), _decayStats);
  }

  void _decayStats() {
    if (!mounted) return;
    setState(() {
      _pet.updateStat('hunger', -3);
      _pet.updateStat('cleanliness', -2);
      _pet.updateStat('affection', -1);
    });
    StorageDB.savePet(widget.userId, _pet);
    Future.delayed(const Duration(minutes: 1), _decayStats);
  }

  void _movePet() {
    if (!mounted) return;
    setState(() {
      _petX += _petDX;
      _petY += _petDY;

      if (_petX < 0 || _petX > 300) {
        _petDX = -_petDX;
        _petLookingRight = _petDX > 0;
      }
      if (_petY < 0 || _petY > 150) {
        _petDY = -_petDY;
      }

      // 똥 타이머 (약 30초마다)
      _poopTimer++;
      if (_poopTimer >= 600 && _poops.length < 5) {
        _poops.add(Offset(_petX, _petY));
        _poopTimer = 0;
        StorageDB.savePoops(widget.userId, _poops);
      }
    });
  }

  Future<void> _loadPoops() async {
    final poops = await StorageDB.loadPoops(widget.userId);
    setState(() => _poops = poops);
  }

  Future<void> _loadCounts() async {
    final logs = await StorageDB.loadLogs(widget.userId);
    final today = DateTime.now();
    final todayLogs = logs.where((l) =>
        l.timestamp.year == today.year &&
        l.timestamp.month == today.month &&
        l.timestamp.day == today.day);

    setState(() {
      _feedCount = todayLogs.where((l) => l.action == 'feed').length;
      _walkCount = todayLogs.where((l) => l.action == 'walk').length;
      _washCount = todayLogs.where((l) => l.action == 'wash').length;
      _petCount = todayLogs.where((l) => l.action == 'pet').length;
    });
  }

  Future<void> _playSound(String sound, {int? stopAfterMs}) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/$sound.mp3'));
      if (stopAfterMs != null) {
        Future.delayed(Duration(milliseconds: stopAfterMs), () {
          _audioPlayer.stop();
        });
      }
    } catch (e) {}
  }

  void _onTapPet() async {
    await _playSound('happy');
    setState(() {
      _showSmile = true;
      _message = '${_pet.name}이(가) 나를 봐요! 😊';
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showSmile = false);
    });
  }

  void _onTapPoop(int index) async {
    await _playSound('happy');
    setState(() {
      _poops.removeAt(index);
      _showSmile = true;
      _message = '${_pet.name}이(가) 고마워해요! 😊';
    });
    StorageDB.savePoops(widget.userId, _poops);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showSmile = false);
    });
  }

  Future<void> _registerPet() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _message = '반려동물의 이름을 입력해주세요');
      return;
    }

    final newPet = PetInstance(
      name: _nameController.text.trim(),
      species: _selectedSpecies,
    );

    await StorageDB.savePet(widget.userId, newPet);
    await StorageDB.saveTimestamp(widget.userId);

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _doAction(String action) async {
    if (action == 'feed' && _feedCount >= 2) {
      setState(() => _message = '밥은 하루에 2번까지만 줄 수 있어요! 🍖');
      return;
    }
    if (action == 'walk' && _walkCount >= 2) {
      setState(() => _message = '산책은 하루에 2번까지만 할 수 있어요! 🦮');
      return;
    }
    if (action == 'wash' && _washCount >= 1) {
      setState(() => _message = '씻기기는 하루에 1번만 할 수 있어요! 🛁');
      return;
    }
    if (action == 'pet' && _petCount >= 2) {
      setState(() => _message = '쓰다듬기는 하루에 2번까지만 할 수 있어요! 🤚');
      return;
    }

    String stat = '';
    int delta = 0;

    switch (action) {
      case 'feed':
        stat = 'hunger';
        delta = 40;
        _feedCount++;
        await _playSound('feed');
        break;
      case 'wash':
        stat = 'cleanliness';
        delta = 50;
        _washCount++;
        await _playSound('wash', stopAfterMs: 3000);
        break;
      case 'walk':
        stat = 'affection';
        delta = 20;
        _walkCount++;
        await _playSound('happy');
        break;
      case 'pet':
        stat = 'affection';
        delta = 15;
        _petCount++;
        await _playSound('happy');
        break;
    }

    if ((stat == 'hunger' && _pet.hunger >= 100) ||
        (stat == 'cleanliness' && _pet.cleanliness >= 100) ||
        (stat == 'affection' && _pet.affection >= 100)) {
      setState(() => _message = '이미 충분해요! 😊');
      return;
    }

    _pet.updateStat(stat, delta);
    _pet.updateStat('exp', 5);

    final log = ActivityLog(action: action, content: '$action 수행');
    await StorageDB.saveLog(widget.userId, log);
    await StorageDB.savePet(widget.userId, _pet);

    if (_pet.checkGrowthReady()) {
      _pet.evolve();
      await StorageDB.savePet(widget.userId, _pet);
      await _playSound('grow');
      setState(() => _message = '${_pet.name}이(가) 성장했어요! 🎉');
    } else {
      setState(() => _message = '${_pet.name}이(가) 기뻐해요! 🐾');
    }
  }

  String _getPetEmoji() {
    if (_showSmile) return '😊';
    switch (_pet.species) {
      case '강아지': return '🐶';
      case '토끼': return '🐰';
      case '고양이': return '🐱';
      case '햄스터': return '🐹';
      default: return '🐾';
    }
  }

  List<Map<String, dynamic>> _getActions() {
    if (_pet.species == '강아지' || _pet.species == '토끼') {
      return [
        {'emoji': '🍖', 'label': '먹이\n($_feedCount/2)', 'action': 'feed'},
        {'emoji': '🛁', 'label': '씻기\n($_washCount/1)', 'action': 'wash'},
        {'emoji': '🦮', 'label': '산책\n($_walkCount/2)', 'action': 'walk'},
      ];
    } else {
      return [
        {'emoji': '🍖', 'label': '먹이\n($_feedCount/2)', 'action': 'feed'},
        {'emoji': '🛁', 'label': '씻기\n($_washCount/1)', 'action': 'wash'},
        {'emoji': '🤚', 'label': '쓰다듬\n($_petCount/2)', 'action': 'pet'},
      ];
    }
  }

  @override
  void dispose() {
    _moveController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isNew) {
      return Scaffold(
        appBar: AppBar(title: const Text('새 친구 만들기')),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '어떤 친구를 키울까요?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  DropdownButton<String>(
                    value: _selectedSpecies,
                    items: _speciesList
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedSpecies = v!),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '이름',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (_message.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(_message,
                          style: const TextStyle(color: Colors.red)),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _registerPet,
                      child: const Text('등록 완료'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_pet.name),
        actions: [
          IconButton(
            icon: const Text('🎮', style: TextStyle(fontSize: 20)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MiniGameScreen(
                    userId: widget.userId,
                    species: _pet.species,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 스탯 바 (작게)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              children: [
                _buildStatRow('🍖', _pet.hunger),
                _buildStatRow('🛁', _pet.cleanliness),
                _buildStatRow('💕', _pet.affection),
                _buildStatRow('⭐', _pet.exp.clamp(0, 100)),
              ],
            ),
          ),
          // 메시지
          if (_message.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.purple, fontSize: 13),
              ),
            ),
          // 동물 움직임 영역
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                  ),
                ),
                // 똥들
                ..._poops.asMap().entries.map((entry) {
                  return Positioned(
                    left: entry.value.dx.clamp(0, 300),
                    top: entry.value.dy.clamp(0, 150),
                    child: GestureDetector(
                      onTap: () => _onTapPoop(entry.key),
                      child: const Text('💩',
                          style: TextStyle(fontSize: 24)),
                    ),
                  );
                }),
                // 동물
                Positioned(
                  left: _petX,
                  top: _petY,
                  child: GestureDetector(
                    onTap: _onTapPet,
                    child: Transform.flip(
                      flipX: !_petLookingRight,
                      child: Text(
                        _getPetEmoji(),
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 액션 버튼
          Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _getActions()
                      .map((a) => _actionButton(
                            a['emoji'],
                            a['label'],
                            () => _doAction(a['action']),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _playSound('happy');
                      if (!mounted) return;
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DiaryScreen(
                            userId: widget.userId,
                            pet: _pet,
                          ),
                        ),
                      );
                      setState(() {});
                    },
                    child: const Text('📔 오늘의 일기 쓰기'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String emoji, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Expanded(
            child: LinearProgressIndicator(
              value: value / 100,
              color: value < 30 ? Colors.red : Colors.green,
              backgroundColor: Colors.grey[300],
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 28,
            child: Text('$value',
                style: const TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String emoji, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 30)),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}