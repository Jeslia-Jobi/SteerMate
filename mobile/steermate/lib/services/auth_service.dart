import '../models/user.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  Future<User> register({
    required String email,
    required String password,
    String? name,
  }) async {
    final response = await _api.post('/auth/register', body: {
      'email': email,
      'password': password,
      if (name != null) 'name': name,
    });
    return User.fromJson(response);
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.postForm('/auth/login', {
      'username': email,
      'password': password,
    });
    final token = response['access_token'];
    await _storage.saveToken(token);
    return token;
  }

  Future<User> getProfile() async {
    final response = await _api.get('/user/profile');
    final user = User.fromJson(response);
    await _storage.saveUser(user);
    return user;
  }

  Future<User> updateProfile({String? name}) async {
    final response = await _api.put('/user/profile', body: {
      if (name != null) 'name': name,
    });
    final user = User.fromJson(response);
    await _storage.saveUser(user);
    return user;
  }

  Future<void> logout() async {
    await _storage.deleteToken();
    await _storage.deleteUser();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.getToken();
    return token != null;
  }

  Future<User?> getCurrentUser() async {
    return await _storage.getUser();
  }
}
