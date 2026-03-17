import 'package:avislap/healper/route.dart';
import 'package:avislap/models/auth_models.dart';
import 'package:avislap/models/station_model.dart';
import 'package:avislap/services/api_client.dart';
import 'package:avislap/services/auth_api_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

enum AuthLaunchTarget { login, stationSelection, dashboard }

class AuthController extends GetxController {
  AuthController({AuthApiService? authApiService})
    : _authApiService = authApiService ?? AuthApiService();

  static AuthController ensureRegistered() {
    if (Get.isRegistered<AuthController>()) {
      return Get.find<AuthController>();
    }

    return Get.put(AuthController(), permanent: true);
  }

  final AuthApiService _authApiService;
  final GetStorage _box = GetStorage();

  static const String _accessTokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';

  final isPasswordVisible = false.obs;
  final rememberMe = false.obs;
  final selectedIssue = ''.obs;
  final isNewPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  final isBusy = false.obs;
  final currentUser = Rxn<AuthUser>();
  final session = Rxn<AuthSessionInfo>();
  final stations = <StationSummary>[].obs;
  final activeStation = Rxn<StationSummary>();
  final noEmailAccessSupportMessage = ''.obs;
  final pendingRecoveryEmail = Rxn<String>();
  final pendingPasswordResetToken = Rxn<String>();
  final recoveredUserId = Rxn<String>();

  void togglePassword() => isPasswordVisible.value = !isPasswordVisible.value;
  void toggleNewPassword() =>
      isNewPasswordVisible.value = !isNewPasswordVisible.value;
  void toggleConfirmPassword() =>
      isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;

  String? get accessToken => _box.read(_accessTokenKey) as String?;
  String? get refreshToken => _box.read(_refreshTokenKey) as String?;

  String get currentUserName {
    final user = currentUser.value;
    if (user == null) {
      return 'there';
    }

    return user.firstName.isNotEmpty ? user.firstName : user.fullName;
  }

  Future<AuthLaunchTarget> restoreSession() async {
    if (accessToken == null || refreshToken == null) {
      _clearLocalSession();
      return AuthLaunchTarget.login;
    }

    try {
      await refreshSessionContext();
      return _resolveLaunchTarget();
    } on ApiException {
      _clearLocalSession();
      return AuthLaunchTarget.login;
    }
  }

  Future<AuthLaunchTarget> login({
    required String userId,
    required String password,
    required bool rememberUser,
  }) async {
    isBusy.value = true;
    try {
      final tokens = await _authApiService.login(
        userId: userId.trim(),
        password: password,
        rememberMe: rememberUser,
      );
      _persistTokens(tokens);
      await refreshSessionContext();
      return _resolveLaunchTarget();
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> refreshSessionContext() async {
    await _withFreshAccessToken((token) async {
      final snapshot = await _authApiService.me(token);
      final stationResponse = await _authApiService.getMyStations(token);
      final selectedStation = await _authApiService.getActiveStation(token);

      currentUser.value = snapshot.user;
      session.value = snapshot.session;
      stations.assignAll(stationResponse.stations);
      activeStation.value = selectedStation;
    });
  }

  Future<void> ensureStationContextLoaded() async {
    if (currentUser.value != null && stations.isNotEmpty) {
      return;
    }
    await refreshSessionContext();
  }

  Future<void> selectStation(String stationId) async {
    isBusy.value = true;
    try {
      await _withFreshAccessToken((token) async {
        final station = await _authApiService.selectStation(
          accessToken: token,
          stationId: stationId,
        );
        activeStation.value = station;
      });
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> logout({bool navigateToLogin = true}) async {
    final token = accessToken;
    final currentRefreshToken = refreshToken;

    if (token != null) {
      try {
        await _authApiService.logout(
          accessToken: token,
          refreshToken: currentRefreshToken,
        );
      } catch (_) {
        // Local cleanup still happens if the network request fails.
      }
    }

    _clearLocalSession();

    if (navigateToLogin) {
      Get.offAllNamed(RouteHelper.login);
    }
  }

  Future<void> requestPasswordReset(String email) async {
    isBusy.value = true;
    try {
      await _authApiService.requestPasswordReset(email.trim());
      pendingRecoveryEmail.value = email.trim();
      pendingPasswordResetToken.value = null;
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> resendPasswordResetCode() async {
    final email = pendingRecoveryEmail.value;
    if (email == null || email.isEmpty) {
      throw ApiException(
        message: 'No recovery email found. Please start again.',
        statusCode: 400,
      );
    }
    await requestPasswordReset(email);
  }

  Future<void> verifyPasswordResetCode(String code) async {
    final email = pendingRecoveryEmail.value;
    if (email == null || email.isEmpty) {
      throw ApiException(
        message: 'Recovery email is missing. Please request a new code.',
        statusCode: 400,
      );
    }

    isBusy.value = true;
    try {
      final resetToken = await _authApiService.verifyPasswordReset(
        email: email,
        code: code.trim(),
      );
      if (resetToken.isEmpty) {
        throw ApiException(
          message: 'Verification completed but no reset token was returned.',
          statusCode: 500,
        );
      }
      pendingPasswordResetToken.value = resetToken;
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> submitNewPassword(String newPassword) async {
    final resetToken = pendingPasswordResetToken.value;
    if (resetToken == null || resetToken.isEmpty) {
      throw ApiException(
        message: 'Reset session expired. Please request a new code.',
        statusCode: 400,
      );
    }

    isBusy.value = true;
    try {
      await _authApiService.confirmPasswordReset(
        token: resetToken,
        newPassword: newPassword,
      );
      pendingPasswordResetToken.value = null;
      pendingRecoveryEmail.value = null;
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> requestUidRecovery(String email) async {
    isBusy.value = true;
    try {
      await _authApiService.requestUidRecovery(email.trim());
      pendingRecoveryEmail.value = email.trim();
      recoveredUserId.value = null;
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> resendUidRecoveryCode() async {
    final email = pendingRecoveryEmail.value;
    if (email == null || email.isEmpty) {
      throw ApiException(
        message: 'No recovery email found. Please start again.',
        statusCode: 400,
      );
    }
    await requestUidRecovery(email);
  }

  Future<String> verifyUidRecoveryCode(String code) async {
    final email = pendingRecoveryEmail.value;
    if (email == null || email.isEmpty) {
      throw ApiException(
        message: 'Recovery email is missing. Please request a new code.',
        statusCode: 400,
      );
    }

    isBusy.value = true;
    try {
      final userId = await _authApiService.verifyUidRecovery(
        email: email,
        code: code.trim(),
      );
      recoveredUserId.value = userId;
      pendingRecoveryEmail.value = null;
      return userId;
    } finally {
      isBusy.value = false;
    }
  }

  Future<String> loadNoEmailAccessMessage() async {
    if (noEmailAccessSupportMessage.value.isNotEmpty) {
      return noEmailAccessSupportMessage.value;
    }

    isBusy.value = true;
    try {
      final message = await _authApiService.getNoEmailAccessMessage();
      noEmailAccessSupportMessage.value = message;
      return message;
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> _refreshTokens() async {
    final currentRefreshToken = refreshToken;
    if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
      throw ApiException(
        message: 'Your session has expired. Please sign in again.',
        statusCode: 401,
      );
    }

    final tokens = await _authApiService.refresh(currentRefreshToken);
    _persistTokens(tokens);
  }

  Future<T> _withFreshAccessToken<T>(
    Future<T> Function(String accessToken) action,
  ) async {
    final currentAccessToken = accessToken;
    if (currentAccessToken == null || currentAccessToken.isEmpty) {
      throw ApiException(
        message: 'Your session has expired. Please sign in again.',
        statusCode: 401,
      );
    }

    try {
      return await action(currentAccessToken);
    } on ApiException catch (error) {
      if (error.statusCode != 401) {
        rethrow;
      }

      await _refreshTokens();
      final refreshedAccessToken = accessToken;
      if (refreshedAccessToken == null || refreshedAccessToken.isEmpty) {
        throw ApiException(
          message: 'Your session has expired. Please sign in again.',
          statusCode: 401,
        );
      }

      return action(refreshedAccessToken);
    }
  }

  AuthLaunchTarget _resolveLaunchTarget() {
    if (activeStation.value != null) {
      return AuthLaunchTarget.dashboard;
    }

    if (stations.isEmpty) {
      return AuthLaunchTarget.login;
    }

    return AuthLaunchTarget.stationSelection;
  }

  void _persistTokens(AuthTokens tokens) {
    _box.write(_accessTokenKey, tokens.accessToken);
    _box.write(_refreshTokenKey, tokens.refreshToken);
  }

  void _clearLocalSession() {
    _box.remove(_accessTokenKey);
    _box.remove(_refreshTokenKey);
    currentUser.value = null;
    session.value = null;
    stations.clear();
    activeStation.value = null;
    pendingRecoveryEmail.value = null;
    pendingPasswordResetToken.value = null;
    recoveredUserId.value = null;
  }
}
