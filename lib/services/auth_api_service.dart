import 'package:avislap/models/auth_models.dart';
import 'package:avislap/models/station_model.dart';

import 'api_client.dart';

class AuthApiService {
  AuthApiService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<AuthTokens> login({
    required String userId,
    required String password,
    required bool rememberMe,
  }) async {
    final response = await _apiClient.post(
      'auth/login',
      body: <String, dynamic>{
        'userId': userId,
        'password': password,
        'rememberMe': rememberMe,
        'deviceName': 'Flutter App',
      },
    );

    return AuthTokens.fromJson(_asMap(response.data));
  }

  Future<AuthTokens> refresh(String refreshToken) async {
    final response = await _apiClient.post(
      'auth/refresh',
      body: <String, dynamic>{'refreshToken': refreshToken},
    );

    return AuthTokens.fromJson(_asMap(response.data));
  }

  Future<void> logout({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _apiClient.post(
      'auth/logout',
      accessToken: accessToken,
      body: <String, dynamic>{
        if (refreshToken != null && refreshToken.isNotEmpty)
          'refreshToken': refreshToken,
      },
    );
  }

  Future<UserSessionSnapshot> me(String accessToken) async {
    final response = await _apiClient.get('auth/me', accessToken: accessToken);

    return UserSessionSnapshot.fromJson(_asMap(response.data));
  }

  Future<StationsResponse> getMyStations(String accessToken) async {
    final response = await _apiClient.get(
      'stations/my',
      accessToken: accessToken,
    );

    return StationsResponse.fromJson(_asMap(response.data));
  }

  Future<StationSummary?> getActiveStation(String accessToken) async {
    final response = await _apiClient.get(
      'stations/active',
      accessToken: accessToken,
    );
    if (response.data == null) {
      return null;
    }

    return StationSummary.fromJson(_asMap(response.data));
  }

  Future<StationSummary> selectStation({
    required String accessToken,
    required String stationId,
  }) async {
    final response = await _apiClient.post(
      'stations/select',
      accessToken: accessToken,
      body: <String, dynamic>{'stationId': stationId},
    );

    return StationSummary.fromJson(_asMap(response.data));
  }

  Future<void> requestPasswordReset(String email) async {
    await _apiClient.post(
      'auth/forgot-password/request',
      body: <String, dynamic>{'email': email},
    );
  }

  Future<String> verifyPasswordReset({
    required String email,
    required String code,
  }) async {
    final response = await _apiClient.post(
      'auth/forgot-password/verify',
      body: <String, dynamic>{'email': email, 'code': code},
    );

    return _asMap(response.data)['resetToken']?.toString() ?? '';
  }

  Future<void> confirmPasswordReset({
    required String token,
    required String newPassword,
  }) async {
    await _apiClient.post(
      'auth/forgot-password/confirm',
      body: <String, dynamic>{'token': token, 'newPassword': newPassword},
    );
  }

  Future<void> requestUidRecovery(String email) async {
    await _apiClient.post(
      'auth/forgot-uid/request',
      body: <String, dynamic>{'email': email},
    );
  }

  Future<String> verifyUidRecovery({
    required String email,
    required String code,
  }) async {
    final response = await _apiClient.post(
      'auth/forgot-uid/verify',
      body: <String, dynamic>{'email': email, 'code': code},
    );

    return _asMap(response.data)['userId']?.toString() ?? '';
  }

  Future<String> getNoEmailAccessMessage() async {
    final response = await _apiClient.get('auth/no-email-access-message');
    return response.message;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, data) => MapEntry(key.toString(), data));
    }
    return <String, dynamic>{};
  }
}
