import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jalan_hidup_wni/core/theme/app_theme.dart';
import 'package:jalan_hidup_wni/presentation/router/app_router.dart';

class JalanHidupApp extends ConsumerWidget {
  const JalanHidupApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Jalan Hidup WNI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
