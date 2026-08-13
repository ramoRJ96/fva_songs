import 'package:flutter_test/flutter_test.dart';
import 'package:fva_songs/features/songs/presentation/providers/songs_providers.dart';

void main() {
  test('exécute l\'action après le délai', () async {
    final debouncer = SearchDebouncer(delay: const Duration(milliseconds: 20));
    var callCount = 0;

    debouncer.run(() => callCount++);
    expect(callCount, 0);

    await Future.delayed(const Duration(milliseconds: 50));
    expect(callCount, 1);

    debouncer.dispose();
  });

  test('annule l\'appel précédent si run est rappelé avant le délai', () async {
    final debouncer = SearchDebouncer(delay: const Duration(milliseconds: 30));
    var callCount = 0;

    debouncer.run(() => callCount++);
    await Future.delayed(const Duration(milliseconds: 10));
    debouncer.run(() => callCount++);

    await Future.delayed(const Duration(milliseconds: 60));
    expect(callCount, 1);

    debouncer.dispose();
  });

  test('dispose annule un timer en attente', () async {
    final debouncer = SearchDebouncer(delay: const Duration(milliseconds: 20));
    var callCount = 0;

    debouncer.run(() => callCount++);
    debouncer.dispose();

    await Future.delayed(const Duration(milliseconds: 50));
    expect(callCount, 0);
  });
}
