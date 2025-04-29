// api/api_config.dart

class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8000';
  static String? authToken;

  static void setAuthToken(String token) {
    authToken = token;
  }

  static void initialize() {
    setAuthToken(
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJtb2giLCJmcmVzaCI6dHJ1ZSwiZXhwIjoxNzQ4NDkzNjYxLCJzY29wZSI6ImFjY2Vzc190b2tlbiJ9.kNBmmC2zGNDSP1RCrMEibBdG6gAYk3GI7Z6Gp_hl_TM');
  }
}
