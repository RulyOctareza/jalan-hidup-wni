import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jalan_hidup_wni/core/theme/app_colors.dart';
import 'package:jalan_hidup_wni/domain/entities/character.dart';
import 'package:jalan_hidup_wni/presentation/providers/audio_provider.dart';
import 'package:jalan_hidup_wni/presentation/providers/life_notifier.dart';

class CharacterCreationScreen extends ConsumerStatefulWidget {
  const CharacterCreationScreen({super.key});

  @override
  ConsumerState<CharacterCreationScreen> createState() =>
      _CharacterCreationScreenState();
}

class _CharacterCreationScreenState
    extends ConsumerState<CharacterCreationScreen> {
  final _nameController = TextEditingController();
  Gender _gender = Gender.male;
  int _birthYear = 1995;
  String _province = 'DKI Jakarta';
  String _background = 'menengah';

  static const _provinces = [
    'DKI Jakarta',
    'Jawa Barat',
    'Jawa Tengah',
    'Jawa Timur',
    'Bali',
    'Sumatera Utara',
    'Sulawesi Selatan',
    'Kalimantan Timur',
    'Papua',
    'Aceh',
  ];

  static const _backgrounds = ['miskin', 'menengah', 'kaya', 'elite'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Karakter')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Siapa kamu di Jalan Hidup ini?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nama'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          const Text('Jenis Kelamin'),
          Row(
            children: [
              Expanded(
                child: RadioListTile<Gender>(
                  title: const Text('Laki-laki'),
                  value: Gender.male,
                  groupValue: _gender,
                  onChanged: (v) => setState(() => _gender = v!),
                ),
              ),
              Expanded(
                child: RadioListTile<Gender>(
                  title: const Text('Perempuan'),
                  value: Gender.female,
                  groupValue: _gender,
                  onChanged: (v) => setState(() => _gender = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Tahun Lahir: $_birthYear'),
          Slider(
            min: 1960,
            max: 2010,
            divisions: 50,
            value: _birthYear.toDouble(),
            activeColor: AppColors.primary,
            label: '$_birthYear',
            onChanged: (v) => setState(() => _birthYear = v.round()),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _province,
            decoration: const InputDecoration(labelText: 'Provinsi'),
            items: _provinces
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: (v) => setState(() => _province = v!),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _background,
            decoration: const InputDecoration(
              labelText: 'Background Keluarga',
            ),
            items: _backgrounds
                .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                .toList(),
            onChanged: (v) => setState(() => _background = v!),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              final name = _nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Masukkan nama dulu')),
                );
                return;
              }
              final character = Character(
                name: name,
                gender: _gender,
                birthYear: _birthYear,
                province: _province,
                background: _background,
              );
              await ref
                  .read(lifeNotifierProvider.notifier)
                  .startNewLife(character);
              ref.read(audioServiceProvider).tap();
              if (context.mounted) context.go('/life');
            },
            child: const Text('Mulai Hidup'),
          ),
        ],
      ),
    );
  }
}
