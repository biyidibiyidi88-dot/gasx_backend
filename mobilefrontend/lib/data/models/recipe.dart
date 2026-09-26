class Recipe {
  final int id;
  final String name;
  final double estimatedGasRequired;
  final int cookingTimeMinutes;
  final String? imageUrl;

  Recipe({
    required this.id,
    required this.name,
    required this.estimatedGasRequired,
    required this.cookingTimeMinutes,
    this.imageUrl,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: _toInt(json['id']),
      name: json['name'] ?? 'Unknown Food',
      estimatedGasRequired: _toDouble(json['estimated_gas_required']),
      cookingTimeMinutes: _toInt(json['cooking_time_minutes']),
      imageUrl: json['image_url'],
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
