import '../models/pet_instance.dart';
import 'storage_db.dart';

class TimeSynchronizer {
  static Future<void> sync(String userId, PetInstance pet) async {
    try {
      final lastAccess = await StorageDB.loadTimestamp(userId);
      final now = DateTime.now();

      if (lastAccess == null) {
        await StorageDB.saveTimestamp(userId);
        return;
      }

      if (now.isBefore(lastAccess)) {
        return;
      }

      // 경과 시간 (분 단위)
      final elapsed = now.difference(lastAccess).inMinutes;

      if (elapsed > 0) {
        // 10분당 -5 차감
        final decay = (elapsed / 10 * 5).floor();
        pet.updateStat('hunger', -decay);
        pet.updateStat('cleanliness', -decay);
        pet.updateStat('affection', -(decay ~/ 2));
      }

      await StorageDB.saveTimestamp(userId);
      await StorageDB.savePet(userId, pet);
    } catch (e) {}
  }
}