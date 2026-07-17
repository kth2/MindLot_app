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

  group('LotRepository · 媽祖六十甲子籤', () {
    late LotRepository repo;
    setUp(() => repo = LotRepository());

    test('mazu_60 is registered with a data file', () async {
      final set = await repo.setById('mazu_60');
      expect(set, isNotNull);
      expect(set!.hasLocalData, isTrue);
      expect(set.numberingStyle, 'sexagenary');
      expect(set.totalLots, 60);
    });

    test('bundles the full set of 60 lots in traditional stem order', () async {
      final lots = await repo.loadLots('mazu_60');
      expect(lots.length, 60);
      // Numbers are contiguous 1..60.
      for (var i = 0; i < lots.length; i++) {
        expect(lots[i].number, i + 1);
      }
      // Authentic 六十甲子 ordering groups by stem: 甲子·甲寅·甲辰·甲午·甲申·甲戌…
      expect(lots[0].sexagenary, '甲子');
      expect(lots[1].sexagenary, '甲寅');
      expect(lots[6].sexagenary, '乙丑');
      expect(lots[59].sexagenary, '癸亥');
    });

    test('every lot has a complete schema incl. 五行 and 聖意', () async {
      final lots = await repo.loadLots('mazu_60');
      final seen = <String>{};
      for (final lot in lots) {
        expect(lot.poem.length, 4, reason: '${lot.label} poem');
        expect(lot.sexagenary, isNotNull, reason: lot.label);
        expect(lot.label, '${lot.sexagenary}籤');
        expect(lot.wuxing, isNotEmpty, reason: '${lot.label} 五行');
        expect(lot.meaning, isNotEmpty, reason: '${lot.label} 聖意');
        expect(lot.poemTranslation, isNotEmpty, reason: lot.label);
        expect(lot.aspects.keys, containsAll(
            ['career', 'love', 'wealth', 'health', 'study', 'travel']));
        expect(seen.add(lot.sexagenary!), isTrue,
            reason: 'duplicate ${lot.sexagenary}');
      }
    });

    test('resolves a lot by its sexagenary designation', () async {
      final lot = await repo.findBySexagenary('mazu_60', '丁亥');
      expect(lot, isNotNull);
      expect(lot!.number, 24);
      expect(lot.poem.first, '月出光輝四海明');
    });

    test('六十甲子籤 shares the same poems but keeps its own setId', () async {
      final jiazi = await repo.setById('jiazi_60');
      expect(jiazi, isNotNull);
      expect(jiazi!.hasLocalData, isTrue);

      final jiaziLots = await repo.loadLots('jiazi_60');
      final mazuLots = await repo.loadLots('mazu_60');
      expect(jiaziLots.length, 60);
      // Same poem system…
      expect(jiaziLots[23].poem, mazuLots[23].poem);
      expect(jiaziLots[23].sexagenary, '丁亥');
      // …but each lot is stamped with the set it was loaded as.
      expect(jiaziLots.every((l) => l.setId == 'jiazi_60'), isTrue);
    });

    test('both sexagenary sets appear in the drawable list', () async {
      final ids = (await repo.setsWithData()).map((s) => s.id);
      expect(ids, containsAll(['guanyin_100', 'mazu_60', 'jiazi_60']));
    });
  });

  group('LotRepository · 黃大仙靈籤', () {
    late LotRepository repo;
    setUp(() => repo = LotRepository());

    test('wongtaisin_100 is registered with a data file', () async {
      final set = await repo.setById('wongtaisin_100');
      expect(set, isNotNull);
      expect(set!.hasLocalData, isTrue);
      expect(set.numberingStyle, 'numeric');
      expect(set.totalLots, 100);
    });

    test('bundles the full set of 100 lots, contiguous', () async {
      final lots = await repo.loadLots('wongtaisin_100');
      expect(lots.length, 100);
      for (var i = 0; i < lots.length; i++) {
        expect(lots[i].number, i + 1);
      }
    });

    test('every lot has a complete schema incl. authentic aspects', () async {
      final lots = await repo.loadLots('wongtaisin_100');
      for (final lot in lots) {
        expect(lot.poem.length, 4, reason: '第${lot.number}籤 poem');
        expect(lot.level, isNotEmpty, reason: '第${lot.number}籤 level');
        expect(lot.title, isNotEmpty, reason: '第${lot.number}籤 title');
        expect(lot.poemTranslation, isNotEmpty, reason: '第${lot.number}籤 白話');
        expect(lot.allusion, isNotEmpty, reason: '第${lot.number}籤 典故');
        expect(lot.meaning, isNotEmpty, reason: '第${lot.number}籤 解籤');
        expect(lot.aspects.keys, containsAll(
            ['career', 'love', 'wealth', 'health', 'study', 'travel']));
      }
    });

    test('lot 1 (姜公封相) resolves with its 上上 grade', () async {
      final lot = await repo.findLot('wongtaisin_100', 1);
      expect(lot, isNotNull);
      expect(lot!.title, '姜公封相');
      expect(lot.level, '上上');
      expect(lot.poem.first, '靈籤求得第一枝');
    });

    test('all four lot systems are now drawable', () async {
      final ids = (await repo.setsWithData()).map((s) => s.id);
      expect(ids, containsAll(
          ['guanyin_100', 'mazu_60', 'jiazi_60', 'wongtaisin_100']));
    });
  });
}
