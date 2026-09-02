import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jalan_hidup_wni/app.dart';
import 'package:jalan_hidup_wni/data/sources/local/life_local_source.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LifeLocalSource.init();
  runApp(const ProviderScope(child: JalanHidupApp()));
}
