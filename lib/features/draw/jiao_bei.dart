import 'dart:math';

/// Which face of a moon block (筊杯) lands upward.
///
/// A physical block has a [flat] side (平面, the 陽 face) and a [round] side
/// (凸面, the 陰 face).
enum BlockFace { flat, round }

/// The outcome of a single throw of the pair of blocks (擲筊).
enum JiaoResult {
  /// 聖筊 — one flat, one round (陰陽各一). The deity approves.
  sacred,

  /// 笑筊 — both flat up (兩平面). The deity smiles; unclear, throw again.
  laughing,

  /// 陰筊 — both round up (兩凸面). Not approved; reconsider or draw anew.
  negative,
}

/// Maps a pair of landed faces to the traditional outcome.
JiaoResult jiaoResultOf(BlockFace a, BlockFace b) {
  if (a != b) return JiaoResult.sacred; // 一平一凸
  return a == BlockFace.flat ? JiaoResult.laughing : JiaoResult.negative;
}

/// One throw of the two blocks.
class JiaoThrow {
  const JiaoThrow(this.first, this.second);

  final BlockFace first;
  final BlockFace second;

  JiaoResult get result => jiaoResultOf(first, second);

  /// A fair throw: each block lands flat or round with equal probability,
  /// giving 聖筊 50%, 笑筊 25%, 陰筊 25%.
  factory JiaoThrow.random([Random? rng]) {
    final r = rng ?? Random();
    BlockFace face() => r.nextBool() ? BlockFace.flat : BlockFace.round;
    return JiaoThrow(face(), face());
  }
}

