import 'package:flutter/foundation.dart';

@immutable
class AvatarOption {
  final String id;
  final String label;
  final String kind; // 'human' veya 'animal'
  final String assetPath;

  const AvatarOption({
    required this.id,
    required this.label,
    required this.kind,
    required this.assetPath,
  });

  static const List<AvatarOption> all = [
    AvatarOption(
      id: 'fox',
      label: 'Akıllı Tilki',
      kind: 'animal',
      assetPath: 'assets/avatars/fox.png',
    ),
    AvatarOption(
      id: 'cat',
      label: 'Sevimli Kedi',
      kind: 'animal',
      assetPath: 'assets/avatars/cat.png',
    ),
    AvatarOption(
      id: 'dog',
      label: 'Sadık Köpek',
      kind: 'animal',
      assetPath: 'assets/avatars/dog.png',
    ),
    AvatarOption(
      id: 'panda',
      label: 'Huzurlu Panda',
      kind: 'animal',
      assetPath: 'assets/avatars/panda.png',
    ),
    AvatarOption(
      id: 'human_01',
      label: 'Ali (Gezgin)',
      kind: 'human',
      assetPath: 'assets/avatars/human_01.png',
    ),
    AvatarOption(
      id: 'human_02',
      label: 'Ayşe (Okur)',
      kind: 'human',
      assetPath: 'assets/avatars/human_02.png',
    ),
    AvatarOption(
      id: 'human_03',
      label: 'Can (Koşucu)',
      kind: 'human',
      assetPath: 'assets/avatars/human_03.png',
    ),
    AvatarOption(
      id: 'human_04',
      label: 'Zeynep (Sanatçı)',
      kind: 'human',
      assetPath: 'assets/avatars/human_04.png',
    ),
  ];

  static AvatarOption byId(String id) {
    return all.firstWhere((a) => a.id == id, orElse: () => all.first);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'kind': kind,
    'assetPath': assetPath,
  };

  factory AvatarOption.fromJson(Map<String, dynamic> json) {
    return AvatarOption(
      id: json['id'] as String,
      label: json['label'] as String,
      kind: (json['kind'] as String?) ?? 'animal',
      assetPath: (json['assetPath'] as String?) ?? '',
    );
  }
}
