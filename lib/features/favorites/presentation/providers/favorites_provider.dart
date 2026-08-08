import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../songs/presentation/providers/song_list_provider.dart';
import '../../../songs/domain/entities/song.dart';

// Provider des favoris — dérivé du songListProvider
final favoriteSongsProvider = Provider<List<Song>>((ref) {
  return ref.watch(songListProvider).where((s) => s.isFavorite).toList();
});

// Provider des listes de culte (données mockées)
final worshipListsProvider = Provider<List<WorshipList>>((ref) {
  return [
    const WorshipList(
      id: 'wl1',
      name: 'Culte de Pâques',
      date: 'Il y a 2 jours',
      songCount: 5,
    ),
    const WorshipList(
      id: 'wl2',
      name: 'Soirée Louange',
      date: 'Hier',
      songCount: 3,
    ),
    const WorshipList(
      id: 'wl3',
      name: 'Dimanche Prochain',
      date: '24 Mars 2024 • 10:30',
      songCount: 2,
      isActive: true,
    ),
  ];
});

class WorshipList {
  const WorshipList({
    required this.id,
    required this.name,
    required this.date,
    required this.songCount,
    this.isActive = false,
  });

  final String id;
  final String name;
  final String date;
  final int songCount;
  final bool isActive;
}
