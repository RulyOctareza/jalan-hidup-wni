import 'package:jalan_hidup_wni/domain/entities/life_save.dart';

abstract class LifeRepository {
  Future<LifeSave?> loadSave();
  Future<void> saveLife(LifeSave save);
  Future<void> clearSave();
  Future<bool> hasSave();
}
