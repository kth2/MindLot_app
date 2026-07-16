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

    test('loads Guanyin lots with full schema', () async {
      final lots = await repo.loadLots('guanyin_100');
      expect(lots.length, greaterThanOrEqualTo(10));
      final first = lots.first;
      expect(first.number, 1);
      expect(first.poem.length, 4);
      expect(first.level, isNotEmpty);
      expect(first.aspects.keys,
          containsAll(['career', 'love', 'wealth', 'health']));
    });

    test('finds lot by number', () async {
      final lot = await repo.findLot('guanyin_100', 8);
      expect(lot, isNotNull);
      expect(lot!.title, '袁安守困');
    });

    test('random draw returns a lot from the set', () async {
      final lot = await repo.randomLot('guanyin_100');
      expect(lot, isNotNull);
      expect(lot!.setId, 'guanyin_100');
    });

    test('fuzzy-matches OCR poem text back to the right lot', () async {
      // Simulated noisy OCR of lot #1 (missing chars, extra punctuation).
      const ocr = '天開地闢結良緣 日吉時良萬事全 若得此籤非小可 人行忠正帝王宣';
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
