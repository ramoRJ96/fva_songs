import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fva_songs/features/songs/data/datasources/song_remote_datasource.dart';
import 'package:fva_songs/features/songs/data/repositories/song_repository_impl.dart';
import 'package:fva_songs/features/songs/domain/entities/song.dart';

class MockSongRemoteDataSource extends Mock implements SongRemoteDataSource {}

Song _song({String id = '1'}) {
  return Song(
    id: id,
    title: 'Titre',
    number: '1',
    author: '',
    theme: '',
    key: '',
    language: SongLanguage.fr,
    firstLine: '',
    sections: const [],
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_song());
  });

  late MockSongRemoteDataSource remote;
  late SongRepositoryImpl repository;

  setUp(() {
    remote = MockSongRemoteDataSource();
    repository = SongRepositoryImpl(remote);
  });

  test('watchSongs délègue à la datasource', () {
    final stream = Stream<List<Song>>.value([_song()]);
    when(() => remote.watchSongs()).thenAnswer((_) => stream);

    expect(repository.watchSongs(), stream);
    verify(() => remote.watchSongs()).called(1);
  });

  test('getById délègue à la datasource', () async {
    final song = _song();
    when(() => remote.getById('1')).thenAnswer((_) async => song);

    final result = await repository.getById('1');

    expect(result, song);
    verify(() => remote.getById('1')).called(1);
  });

  test('addApprovedSong délègue à la datasource', () async {
    final song = _song();
    when(() => remote.addApprovedSong(song)).thenAnswer((_) async => song);

    final result = await repository.addApprovedSong(song);

    expect(result, song);
    verify(() => remote.addApprovedSong(song)).called(1);
  });

  test('updateSong délègue à la datasource', () async {
    final song = _song();
    when(() => remote.updateSong(song)).thenAnswer((_) async {});

    await repository.updateSong(song);

    verify(() => remote.updateSong(song)).called(1);
  });

  test('deleteSong délègue à la datasource', () async {
    when(() => remote.deleteSong('1')).thenAnswer((_) async {});

    await repository.deleteSong('1');

    verify(() => remote.deleteSong('1')).called(1);
  });
}
