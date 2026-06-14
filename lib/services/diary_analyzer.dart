import '../models/pet_instance.dart';
import '../models/activity_log.dart';
import 'storage_db.dart';

class DiaryAnalyzer {
  static const int minLength = 20;

  static int calcExpWeight(String text) {
    return (text.length / 10).floor().clamp(1, 50);
  }

  static int calcAffectionWeight(String text) {
    return (text.length / 20).floor().clamp(1, 20);
  }

  static String detectEmotion(String text) {
    final happyKeywords = ['행복', '기쁘', '좋았', '신났', '즐거', '웃었', '재밌'];
    final sadKeywords = ['슬프', '힘들', '우울', '속상', '눈물', '외로', '싫었'];

    for (final word in happyKeywords) {
      if (text.contains(word)) return 'happy';
    }
    for (final word in sadKeywords) {
      if (text.contains(word)) return 'sad';
    }
    return 'neutral';
  }

  static Future<Map<String, dynamic>> analyze(
    String userId,
    String text,
    PetInstance pet,
  ) async {
    if (text.length < minLength) {
      return {
        'success': false,
        'message': '조금 더 자세히 들려주세요!',
        'emotion': 'neutral',
      };
    }

    final expWeight = calcExpWeight(text);
    final affectionWeight = calcAffectionWeight(text);
    final emotion = detectEmotion(text);

    pet.updateStat('exp', expWeight);
    pet.updateStat('affection', affectionWeight);

    final log = ActivityLog(
      action: 'diary',
      content: text,
    );

    await StorageDB.saveLog(userId, log);
    await StorageDB.savePet(userId, pet);

    return {
      'success': true,
      'emotion': emotion,
      'expGained': expWeight,
      'affectionGained': affectionWeight,
    };
  }
}