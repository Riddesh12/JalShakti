import 'dart:convert';

class Availability {
  final String district;
  final double rechargeRainfallMonsoon;
  final double rechargeOtherMonsoon;
  final double rechargeRainfallNonMonsoon;
  final double rechargeOtherNonMonsoon;
  final double totalRecharge;
  final double naturalDischarge;
  final double netAnnualAvailability;
  final double annualDraftIrrigation;
  final double annualDraftDomesticIndustrial;
  final double totalDraft;
  final double projectedDemand2025;
  final double availabilityForFuture;
  final double stageOfDevelopment;

  Availability({
    required this.district,
    required this.rechargeRainfallMonsoon,
    required this.rechargeOtherMonsoon,
    required this.rechargeRainfallNonMonsoon,
    required this.rechargeOtherNonMonsoon,
    required this.totalRecharge,
    required this.naturalDischarge,
    required this.netAnnualAvailability,
    required this.annualDraftIrrigation,
    required this.annualDraftDomesticIndustrial,
    required this.totalDraft,
    required this.projectedDemand2025,
    required this.availabilityForFuture,
    required this.stageOfDevelopment,
  });

  /// helper function to parse safely
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// create object from Map
  factory Availability.fromMap(Map<String, dynamic> map) {
    return Availability(
      district: map['district'] ?? '',
      rechargeRainfallMonsoon: _toDouble(map['rechargeRainfallMonsoon']),
      rechargeOtherMonsoon: _toDouble(map['rechargeOtherMonsoon']),
      rechargeRainfallNonMonsoon: _toDouble(map['rechargeRainfallNonMonsoon']),
      rechargeOtherNonMonsoon: _toDouble(map['rechargeOtherNonMonsoon']),
      totalRecharge: _toDouble(map['totalRecharge']),
      naturalDischarge: _toDouble(map['naturalDischarge']),
      netAnnualAvailability: _toDouble(map['netAnnualAvailability']),
      annualDraftIrrigation: _toDouble(map['annualDraftIrrigation']),
      annualDraftDomesticIndustrial: _toDouble(map['annualDraftDomesticIndustrial']),
      totalDraft: _toDouble(map['totalDraft']),
      projectedDemand2025: _toDouble(map['projectedDemand2025']),
      availabilityForFuture: _toDouble(map['availabilityForFuture']),
      stageOfDevelopment: _toDouble(map['stageOfDevelopment']),
    );
  }

  /// convert object to Map
  Map<String, dynamic> toMap() {
    return {
      'district': district,
      'rechargeRainfallMonsoon': rechargeRainfallMonsoon,
      'rechargeOtherMonsoon': rechargeOtherMonsoon,
      'rechargeRainfallNonMonsoon': rechargeRainfallNonMonsoon,
      'rechargeOtherNonMonsoon': rechargeOtherNonMonsoon,
      'totalRecharge': totalRecharge,
      'naturalDischarge': naturalDischarge,
      'netAnnualAvailability': netAnnualAvailability,
      'annualDraftIrrigation': annualDraftIrrigation,
      'annualDraftDomesticIndustrial': annualDraftDomesticIndustrial,
      'totalDraft': totalDraft,
      'projectedDemand2025': projectedDemand2025,
      'availabilityForFuture': availabilityForFuture,
      'stageOfDevelopment': stageOfDevelopment,
    };
  }

  /// from JSON string
  factory Availability.fromJson(String source) =>
      Availability.fromMap(json.decode(source));

  /// to JSON string
  String toJson() => json.encode(toMap());
}
