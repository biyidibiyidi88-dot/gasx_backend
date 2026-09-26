class BottleProfiles {
  static const capacitiesKg = <String, double>{
    'SMALL_6KG': 6.0,
    'MEDIUM_12_5KG': 12.5,
    'BIG_50KG': 50.0,
  };

  static const _baseTaresKg = <String, double>{
    'SMALL_6KG': 6.5,
    'MEDIUM_12_5KG': 12.5,
    'BIG_50KG': 48.0,
  };

  static const _brandOffsetsKg = <String, double>{
    'SCTM': 1.0,
    'TOTAL_ENERGIES': 1.5,
    'TRADEX': 2.0,
    'STAR_GAS': 2.5,
    'AZA_MRS': 0.5,
  };

  static const labels = <String, String>{
    'SMALL_6KG': 'Small (6 kg)',
    'MEDIUM_12_5KG': 'Medium (12.5 kg)',
    'BIG_50KG': 'Big (50 kg)',
  };

  static double capacityFor(String size) => capacitiesKg[size] ?? 12.5;

  static double remainingGasFromGrossWeight({
    required double grossWeightKg,
    required double tareWeightKg,
    required String bottleSize,
  }) => (grossWeightKg - tareWeightKg)
      .clamp(0.0, capacityFor(bottleSize))
      .toDouble();

  static double estimatedTareFor(String size, String brand) =>
      (_baseTaresKg[size] ?? _baseTaresKg['MEDIUM_12_5KG']!) +
      (_brandOffsetsKg[brand] ?? 0.0);
}
