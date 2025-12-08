import '../models/trip.dart';
import 'api_service.dart';

class TripService {
  static final TripService _instance = TripService._internal();
  factory TripService() => _instance;
  TripService._internal();

  final ApiService _api = ApiService();

  Future<List<Trip>> getTrips() async {
    final response = await _api.get('/trips');
    return (response as List).map((json) => Trip.fromJson(json)).toList();
  }

  Future<Trip> getTrip(int tripId) async {
    final response = await _api.get('/trips/$tripId');
    return Trip.fromJson(response);
  }

  Future<TripReport> getTripReport(int tripId) async {
    final response = await _api.get('/trips/$tripId/report');
    return TripReport.fromJson(response);
  }

  Future<Trip> uploadTrip(Trip trip) async {
    final response = await _api.post('/trips/upload', body: trip.toJson());
    return Trip.fromJson(response);
  }
}
