import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/pet_instance.dart';
import '../models/activity_log.dart';

class StorageDB {
  // ── 사용자 관련 ──
  static Future<bool> saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> users = prefs.getStringList('users') ?? [];
      users.add(jsonEncode(user.toMap()));
      await prefs.setStringList('users', users);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> checkDuplicate(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> users = prefs.getStringList('users') ?? [];
      return users.any((u) => jsonDecode(u)['userId'] == userId);
    } catch (e) {
      return false;
    }
  }

  static Future<User?> loadUser(String userId, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> users = prefs.getStringList('users') ?? [];
      final found = users.firstWhere(
        (u) {
          final map = jsonDecode(u);
          return map['userId'] == userId && map['password'] == password;
        },
        orElse: () => '',
      );
      if (found.isEmpty) return null;
      return User.fromMap(jsonDecode(found));
    } catch (e) {
      return null;
    }
  }

  // ── 반려동물 관련 ──
  static Future<bool> savePet(String userId, PetInstance pet) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pet_$userId', jsonEncode(pet.toMap()));
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<PetInstance?> loadPet(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('pet_$userId');
      if (data == null) return null;
      return PetInstance.fromMap(jsonDecode(data));
    } catch (e) {
      return null;
    }
  }

  static Future<void> deletePet(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('pet_$userId');
    } catch (e) {}
  }

  // ── 로그 관련 ──
  static Future<bool> saveLog(String userId, ActivityLog log) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> logs = prefs.getStringList('logs_$userId') ?? [];
      logs.add(jsonEncode(log.toMap()));
      await prefs.setStringList('logs_$userId', logs);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<ActivityLog>> loadLogs(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> logs = prefs.getStringList('logs_$userId') ?? [];
      return logs.map((l) => ActivityLog.fromMap(jsonDecode(l))).toList();
    } catch (e) {
      return [];
    }
  }

  // ── 타임스탬프 ──
  static Future<void> saveTimestamp(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'timestamp_$userId',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {}
  }

  static Future<DateTime?> loadTimestamp(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('timestamp_$userId');
      if (data == null) return null;
      return DateTime.parse(data);
    } catch (e) {
      return null;
    }
  }
}