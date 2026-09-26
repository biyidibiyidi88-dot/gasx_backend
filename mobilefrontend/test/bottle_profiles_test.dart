import 'package:flutter_test/flutter_test.dart';
import 'package:gas_monitor_flutter/core/constants/bottle_profiles.dart';

void main() {
  test('bottle sizes use the backend capacities', () {
    expect(BottleProfiles.capacityFor('SMALL_6KG'), 6.0);
    expect(BottleProfiles.capacityFor('MEDIUM_12_5KG'), 12.5);
    expect(BottleProfiles.capacityFor('BIG_50KG'), 50.0);
  });

  test(
    'tare suggestions are estimates that remain separately configurable',
    () {
      expect(
        BottleProfiles.estimatedTareFor('SMALL_6KG', 'TOTAL_ENERGIES'),
        8.0,
      );
      expect(BottleProfiles.estimatedTareFor('MEDIUM_12_5KG', 'OTHER'), 12.5);
      expect(BottleProfiles.estimatedTareFor('BIG_50KG', 'OTHER'), 48.0);
    },
  );

  test('remaining gas uses gross weight, tare, and selected capacity', () {
    expect(
      BottleProfiles.remainingGasFromGrossWeight(
        grossWeightKg: 20,
        tareWeightKg: 10,
        bottleSize: 'SMALL_6KG',
      ),
      6,
    );
    expect(
      BottleProfiles.remainingGasFromGrossWeight(
        grossWeightKg: 20,
        tareWeightKg: 10,
        bottleSize: 'BIG_50KG',
      ),
      10,
    );
    expect(
      BottleProfiles.remainingGasFromGrossWeight(
        grossWeightKg: 8,
        tareWeightKg: 10,
        bottleSize: 'MEDIUM_12_5KG',
      ),
      0,
    );
  });
}
