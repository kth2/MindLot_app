import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mindlot/features/draw/jiao_bei.dart';

void main() {
  group('擲筊 outcome mapping', () {
    test('one flat + one round is 聖筊 (either order)', () {
      expect(jiaoResultOf(BlockFace.flat, BlockFace.round), JiaoResult.sacred);
      expect(jiaoResultOf(BlockFace.round, BlockFace.flat), JiaoResult.sacred);
    });

    test('both flat is 笑筊', () {
      expect(
          jiaoResultOf(BlockFace.flat, BlockFace.flat), JiaoResult.laughing);
    });

    test('both round is 陰筊', () {
      expect(jiaoResultOf(BlockFace.round, BlockFace.round),
          JiaoResult.negative);
    });
  });

  group('JiaoThrow.random', () {
    test('produces all three outcomes with 聖筊 around one half', () {
      final rng = Random(1234); // seeded for determinism
      final counts = <JiaoResult, int>{};
      const n = 4000;
      for (var i = 0; i < n; i++) {
        final r = JiaoThrow.random(rng).result;
        counts[r] = (counts[r] ?? 0) + 1;
      }
      // All outcomes occur.
      expect(counts.keys.toSet(), JiaoResult.values.toSet());
      // 聖筊 ~ 50%, the two others ~ 25% each — allow generous tolerance.
      expect(counts[JiaoResult.sacred]! / n, closeTo(0.5, 0.06));
      expect(counts[JiaoResult.laughing]! / n, closeTo(0.25, 0.06));
      expect(counts[JiaoResult.negative]! / n, closeTo(0.25, 0.06));
    });
  });
}
