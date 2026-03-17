class StationSummary {
  StationSummary({
    required this.stationId,
    required this.stationCode,
    required this.stationName,
    required this.timezone,
    required this.roleCode,
    required this.roleName,
    required this.isDefault,
  });

  final String stationId;
  final String stationCode;
  final String stationName;
  final String timezone;
  final String roleCode;
  final String roleName;
  final bool isDefault;

  String get displayName => '$stationCode - $stationName';

  factory StationSummary.fromJson(Map<String, dynamic> json) {
    return StationSummary(
      stationId: json['stationId']?.toString() ?? '',
      stationCode: json['stationCode']?.toString() ?? '',
      stationName: json['stationName']?.toString() ?? '',
      timezone: json['timezone']?.toString() ?? '',
      roleCode: json['roleCode']?.toString() ?? '',
      roleName: json['roleName']?.toString() ?? '',
      isDefault: json['isDefault'] == true,
    );
  }
}

class StationsResponse {
  StationsResponse({required this.stations, required this.autoSelectSuggested});

  final List<StationSummary> stations;
  final bool autoSelectSuggested;

  factory StationsResponse.fromJson(Map<String, dynamic> json) {
    final rawStations = json['stations'];
    return StationsResponse(
      stations: rawStations is List
          ? rawStations
                .whereType<Map<dynamic, dynamic>>()
                .map(
                  (item) => StationSummary.fromJson(
                    item.map((key, value) => MapEntry(key.toString(), value)),
                  ),
                )
                .toList()
          : const <StationSummary>[],
      autoSelectSuggested: json['autoSelectSuggested'] == true,
    );
  }
}
