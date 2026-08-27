import 'package:shared_preferences/shared_preferences.dart';

class LandLocalStorage {
  static const _landIdKey = 'land_id';
  static const _setupCompleteKey = 'land_setup_complete';
  static const _lastLatKey = 'land_last_known_latitude';
  static const _lastLngKey = 'land_last_known_longitude';
  static const _lastSyncedAtKey = 'land_last_synced_at';

  Future<String?> readLandId() async => (await SharedPreferences.getInstance()).getString(_landIdKey);

  Future<void> saveLandSnapshot({required String landId, double? latitude, double? longitude, DateTime? syncedAt}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_landIdKey, landId);
    await prefs.setBool(_setupCompleteKey, true);
    if (latitude != null) await prefs.setDouble(_lastLatKey, latitude);
    if (longitude != null) await prefs.setDouble(_lastLngKey, longitude);
    if (syncedAt != null) await prefs.setString(_lastSyncedAtKey, syncedAt.toIso8601String());
  }

  Future<void> clearLandState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_landIdKey);
    await prefs.remove(_setupCompleteKey);
    await prefs.remove(_lastLatKey);
    await prefs.remove(_lastLngKey);
    await prefs.remove(_lastSyncedAtKey);
  }
}
