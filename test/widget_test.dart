import 'package:avislap/models/auth_models.dart';
import 'package:avislap/models/station_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('auth and station models parse API payloads', () {
    final user = AuthUser.fromJson(const {
      'id': 'user-1',
      'uid': 'sup.user',
      'email': 'sup.user@example.com',
      'firstName': 'Sara',
      'lastName': 'Supervisor',
      'status': 'ACTIVE',
    });
    final station = StationSummary.fromJson(const {
      'stationId': 'station-1',
      'stationCode': 'JFK',
      'stationName': 'John F. Kennedy',
      'timezone': 'America/New_York',
      'roleCode': 'SUP',
      'roleName': 'Supervisor',
      'isDefault': true,
    });

    expect(user.fullName, 'Sara Supervisor');
    expect(station.displayName, 'JFK - John F. Kennedy');
    expect(station.isDefault, isTrue);
  });
}
