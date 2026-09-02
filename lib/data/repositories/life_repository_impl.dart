import 'package:jalan_hidup_wni/data/sources/local/life_local_source.dart';
import 'package:jalan_hidup_wni/domain/entities/life_save.dart';
import 'package:jalan_hidup_wni/domain/repositories/life_repository.dart';

class LifeRepositoryImpl implements LifeRepository {
  LifeRepositoryImpl(this._local);

  final LifeLocalSource _local;

  @override
  Future<void> clearSave() => _local.clearSave();

  @override
  Future<bool> hasSave() async => _local.hasSave();

  @override
  Future<LifeSave?> loadSave() => _local.loadSave();

  @override
  Future<void> saveLife(LifeSave save) => _local.saveLife(save);
}
