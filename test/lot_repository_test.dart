import 'package:flutter_test/flutter_test.dart';
import 'package:mindlot/data/repositories/lot_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LotRepository', () {
    late LotRepository repo;

    setUp(() => repo = LotRepository());

    test('loads lot-set registry', () async {
      final sets = await repo.loadSets();
      expect(sets, isNotEmpty);
      expect(sets.map((s) => s.id), contains('guanyin_100'));
    });

    test('bundles the full set of 100 Guanyin lots', () async {
      final lots = await repo.loadLots('guanyin_100');
      expect(lots.length, 100);
      // Numbers are contiguous 1..100 and in order.
      for (var i = 0; i < lots.length; i++) {
        expect(lots[i].number, i + 1);
      }
    });

    test('every lot has a complete schema', () async {
      final lots = await repo.loadLots('guanyin_100');
      for (final lot in lots) {
        expect(lot.poem.length, 4, reason: '第${lot.number}籤 poem');
        expect(lot.level, isNotEmpty, reason: '第${lot.number}籤 level');
        expect(lot.title, isNotEmpty, reason: '第${lot.number}籤 title');
        expect(lot.poemTranslation, isNotEmpty, reason: '第${lot.number}籤');
        expect(lot.aspects.keys,
            containsAll(['career', 'love', 'wealth', 'health', 'study', 'travel']));
      }
    });

    test('finds lot by number', () async {
      final lot = await repo.findLot('guanyin_100', 8);
      expect(lot, isNotNull);
      expect(lot!.title, '裴度還帶');
    });

    test('random draw returns a lot from the set', () async {
      final lot = await repo.randomLot('guanyin_100');
      expect(lot, isNotNull);
      expect(lot!.setId, 'guanyin_100');
    });

    test('fuzzy-matches OCR poem text back to the right lot', () async {
      // Simulated noisy OCR of lot #1 (extra spaces, dropped punctuation).
      const ocr = '開天闢地作良緣 吉日良時萬物全 若得此籤非小可 人行忠正帝王宣';
      final lot = await repo.matchByPoem(ocr);
      expect(lot, isNotNull);
      expect(lot!.number, 1);
    });

    test('rejects unrelated text', () async {
      final lot = await repo.matchByPoem('今天天氣很好我們去公園散步吃冰淇淋');
      expect(lot, isNull);
    });
  });
}
