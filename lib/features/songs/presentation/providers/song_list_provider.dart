import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/song.dart';

// ---------------------------------------------------------------------------
// Données mockées — remplacer par un vrai repository plus tard
// ---------------------------------------------------------------------------
final List<Song> _mockSongs = [
  const Song(
    id: '1',
    title: 'À Toi la gloire',
    number: '84',
    author: 'Edmond Budry',
    theme: 'PÂQUES',
    key: 'G MAJ',
    firstLine: '«\u00a0À Toi la gloire, Ô Ressuscité\u00a0! À Toi la victoire pour l\'éternité...»',
    sections: [
      LyricSection(
        type: SectionType.couplet,
        lines: [
          'À Toi la gloire, ô Ressuscité\u00a0!',
          'À Toi la victoire pour l\'éternité\u00a0!',
          'Brillant de lumière, l\'ange est descendu,',
          'Il roule la pierre du tombeau vaincu.',
        ],
      ),
      LyricSection(
        type: SectionType.refrain,
        lines: [
          'C\'est la gloire et la victoire,',
          'C\'est Jésus, notre Sauveur\u00a0!',
          'Il est vivant, il règne en maître,',
          'Louons le Seigneur\u00a0!',
        ],
      ),
      LyricSection(
        type: SectionType.couplet,
        lines: [
          'Vois-le paraître\u00a0: c\'est lui, c\'est Jésus\u00a0!',
          'Ton cœur va-t-il taire ses transports émus\u00a0?',
          'Il est ta vie et ta délivrance,',
          'Déjà sa grâce assure ta défense.',
        ],
      ),
    ],
  ),
  const Song(
    id: '2',
    title: 'Grâce Infinie',
    number: '402',
    author: 'John Newton / Chris Tomlin',
    theme: 'GRÂCE',
    key: 'D MAJ',
    firstLine: '«\u00a0Grâce infinie, quel doux son, qui sauva un misérable comme moi\u00a0!»',
    isFavorite: true,
    sections: [
      LyricSection(
        type: SectionType.couplet,
        lines: [
          'Grâce infinie, quel doux son',
          'Qui sauva un misérable comme moi\u00a0!',
          'J\'étais perdu, mais maintenant je suis retrouvé',
          'J\'étais aveugle, mais maintenant je vois.',
        ],
      ),
      LyricSection(
        type: SectionType.refrain,
        lines: [
          'Ma chaîne est tombée, je suis libéré',
          'Mon Dieu, mon Sauveur m\'a racheté',
          'Et comme un fleuve, sa grâce coule',
          'Amour sans fin, grâce étonnante.',
        ],
      ),
      LyricSection(
        type: SectionType.couplet,
        lines: [
          'C\'est la grâce qui a appris à mon cœur à craindre',
          'Et la grâce mes craintes a soulagées',
          'Combien précieuse cette grâce est apparue',
          'L\'heure où j\'ai cru pour la première fois.',
        ],
      ),
      LyricSection(
        type: SectionType.couplet,
        lines: [
          'À travers de nombreux dangers, peines et pièges',
          'Je suis déjà venu',
          'C\'est la grâce qui m\'a conduit en sécurité jusqu\'ici',
          'Et la grâce me ramènera à la maison.',
        ],
      ),
      LyricSection(
        type: SectionType.refrain,
        isBis: true,
        lines: ['Ma chaîne est tombée, je suis libéré...'],
      ),
    ],
  ),
  const Song(
    id: '3',
    title: 'Béni soit le lien',
    number: '245',
    author: 'John Fawcett',
    theme: 'COMMUNION',
    key: 'F MAJ',
    firstLine: '«\u00a0Béni soit le lien qui nous unit en Christ, l\'amour fraternel qui nous lie...»',
    sections: [
      LyricSection(
        type: SectionType.couplet,
        lines: [
          'Béni soit le lien qui nous unit en Christ,',
          'L\'amour fraternel qui nous lie\u00a0!',
          'La communion de l\'âme à l\'âme,',
          'Est comme là-haut dans le ciel.',
        ],
      ),
      LyricSection(
        type: SectionType.couplet,
        lines: [
          'Nous partageons nos peines mutuelles,',
          'Nos peines et nos fardeaux,',
          'Et souvent pour les autres nous versons des larmes,',
          'La sympathie divine.',
        ],
      ),
    ],
  ),
  const Song(
    id: '4',
    title: 'C\'est un rempart que notre Dieu',
    number: '156',
    author: 'Martin Luther',
    theme: 'CONFIANCE',
    key: 'D MAJ',
    firstLine: '«\u00a0C\'est un rempart que notre Dieu, une invincible armure...»',
    sections: [
      LyricSection(
        type: SectionType.couplet,
        lines: [
          'C\'est un rempart que notre Dieu,',
          'Une invincible armure\u00a0;',
          'Il nous défend en tous les lieux,',
          'Sa force est toujours sûre.',
        ],
      ),
    ],
  ),
  const Song(
    id: '5',
    title: 'Grand Dieu, nous te bénissons',
    number: '12',
    author: 'Ignaz Franz',
    theme: 'LOUANGE',
    key: '4/4',
    firstLine: '«\u00a0Grand Dieu, nous te bénissons, nous célébrons tes louanges...»',
    sections: [
      LyricSection(
        type: SectionType.couplet,
        lines: [
          'Grand Dieu, nous te bénissons,',
          'Nous célébrons tes louanges\u00a0!',
          'Toute la terre t\'acclame,',
          'Et te chante avec les anges.',
        ],
      ),
    ],
  ),
  const Song(
    id: '6',
    title: 'Océans',
    number: '318',
    author: 'Hillsong United',
    theme: 'CONFIANCE',
    key: 'B MAJ',
    firstLine: '«\u00a0Où mes pieds peuvent marcher sur l\'eau avec toi...»',
    isFavorite: true,
    sections: [
      LyricSection(
        type: SectionType.couplet,
        lines: [
          'Tu m\'appelles sur les eaux,',
          'La grande inconnue où ma foi sera renouvelée\u00a0;',
          'Alors je marcherai sur les eaux,',
          'Et chaque vague de ta grâce sera mon chemin.',
        ],
      ),
      LyricSection(
        type: SectionType.refrain,
        lines: [
          'Mon âme se repose dans ta grâce,',
          'Je ferai confiance à celui qui ne vacille pas.',
          'Ma foi sera ta parole pour moi\u00a0:',
          'Où tu es, ô Dieu, je veux être aussi.',
        ],
      ),
    ],
  ),
  const Song(
    id: '7',
    title: 'Béni soit Ton Nom',
    number: '275',
    author: 'Matt Redman',
    theme: 'ADORATION',
    key: 'A MAJ',
    firstLine: '«\u00a0Béni soit ton nom dans la contrée où coule l\'abondance...»',
    isFavorite: true,
    sections: [
      LyricSection(
        type: SectionType.couplet,
        lines: [
          'Béni soit ton nom dans la contrée,',
          'Où coule l\'abondance\u00a0;',
          'Béni soit ton nom quand je suis dans le désert,',
          'Même là, je choisis de te bénir.',
        ],
      ),
      LyricSection(
        type: SectionType.refrain,
        lines: [
          'Béni soit ton nom, Seigneur Dieu\u00a0!',
          'Béni soit ton glorieux nom\u00a0!',
        ],
      ),
    ],
  ),
];

// ---------------------------------------------------------------------------
// Provider principal — liste de tous les chants
// ---------------------------------------------------------------------------
final songListProvider = StateNotifierProvider<SongListNotifier, List<Song>>(
  (ref) => SongListNotifier(_mockSongs),
);

class SongListNotifier extends StateNotifier<List<Song>> {
  SongListNotifier(super.initialList);

  void toggleFavorite(String songId) {
    state = state.map((song) {
      if (song.id == songId) {
        return song.copyWith(isFavorite: !song.isFavorite);
      }
      return song;
    }).toList();
  }
}

// ---------------------------------------------------------------------------
// Provider de recherche
// ---------------------------------------------------------------------------
final searchQueryProvider = StateProvider<String>((ref) => '');

final activeFilterProvider = StateProvider<String>((ref) => 'Titre');

final filteredSongListProvider = Provider<List<Song>>((ref) {
  final songs = ref.watch(songListProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  final filter = ref.watch(activeFilterProvider);

  if (query.isEmpty) return songs;

  return songs.where((song) {
    switch (filter) {
      case 'Auteur':
        return song.author.toLowerCase().contains(query);
      case 'Numéro':
        return song.number.contains(query);
      case 'Thème':
        return song.theme.toLowerCase().contains(query);
      case 'Titre':
      default:
        return song.title.toLowerCase().contains(query);
    }
  }).toList();
});

// ---------------------------------------------------------------------------
// Provider d'un seul chant par ID
// ---------------------------------------------------------------------------
final songByIdProvider = Provider.family<Song?, String>((ref, id) {
  final songs = ref.watch(songListProvider);
  try {
    return songs.firstWhere((s) => s.id == id);
  } catch (_) {
    return null;
  }
});
