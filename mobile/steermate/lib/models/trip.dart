class TripEvent {
  final int? id;
  final String eventType;
  final DateTime? timestamp;
  final double? lat;
  final double? lon;
  final double? speedMs;
  final double? accelMs2;

  TripEvent({
    this.id,
    required this.eventType,
    this.timestamp,
    this.lat,
    this.lon,
    this.speedMs,
    this.accelMs2,
  });

  factory TripEvent.fromJson(Map<String, dynamic> json) {
    return TripEvent(
      id: json['id'],
      eventType: json['event_type'],
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
      lat: json['lat']?.toDouble(),
      lon: json['lon']?.toDouble(),
      speedMs: json['speed_m_s']?.toDouble(),
      accelMs2: json['accel_m_s2']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_type': eventType,
      'timestamp': timestamp?.toIso8601String(),
      'lat': lat,
      'lon': lon,
      'speed_m_s': speedMs,
      'accel_m_s2': accelMs2,
    };
  }

  String get displayName {
    switch (eventType) {
      case 'hard_brake':
        return 'Hard Brake';
      case 'harsh_accel':
        return 'Harsh Acceleration';
      case 'overspeed':
        return 'Overspeeding';
      case 'unsafe_curve':
        return 'Unsafe Curve';
      default:
        return eventType;
    }
  }
}

class SignDetection {
  final int? id;
  final DateTime? ts;
  final String signClass;
  final double? confidence;
  final Map<String, dynamic>? bbox;

  SignDetection({
    this.id,
    this.ts,
    required this.signClass,
    this.confidence,
    this.bbox,
  });

  factory SignDetection.fromJson(Map<String, dynamic> json) {
    return SignDetection(
      id: json['id'],
      ts: json['ts'] != null ? DateTime.parse(json['ts']) : null,
      signClass: json['sign_class'],
      confidence: json['confidence']?.toDouble(),
      bbox: json['bbox'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ts': ts?.toIso8601String(),
      'sign_class': signClass,
      'confidence': confidence,
      'bbox': bbox,
    };
  }

  int? get speedLimit {
    final match = RegExp(r'speed_limit_(\d+)').firstMatch(signClass);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }
}

class Trip {
  final int? id;
  final int? userId;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? durationSeconds;
  final double? distanceM;
  final double? avgSpeedMs;
  final double? maxSpeedMs;
  final int? unsafeEvents;
  final DateTime? createdAt;
  final List<TripEvent> events;
  final List<SignDetection> signDetections;

  Trip({
    this.id,
    this.userId,
    this.startTime,
    this.endTime,
    this.durationSeconds,
    this.distanceM,
    this.avgSpeedMs,
    this.maxSpeedMs,
    this.unsafeEvents,
    this.createdAt,
    this.events = const [],
    this.signDetections = const [],
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      userId: json['user_id'],
      startTime: json['start_time'] != null ? DateTime.parse(json['start_time']) : null,
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      durationSeconds: json['duration_seconds'],
      distanceM: json['distance_m']?.toDouble(),
      avgSpeedMs: json['avg_speed_m_s']?.toDouble(),
      maxSpeedMs: json['max_speed_m_s']?.toDouble(),
      unsafeEvents: json['unsafe_events'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      events: (json['events'] as List?)?.map((e) => TripEvent.fromJson(e)).toList() ?? [],
      signDetections: (json['sign_detections'] as List?)?.map((e) => SignDetection.fromJson(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'duration_seconds': durationSeconds,
      'distance_m': distanceM,
      'avg_speed_m_s': avgSpeedMs,
      'max_speed_m_s': maxSpeedMs,
      'events': events.map((e) => e.toJson()).toList(),
      'sign_detections': signDetections.map((e) => e.toJson()).toList(),
    };
  }

  // Computed properties
  double get distanceKm => (distanceM ?? 0) / 1000;
  double get avgSpeedKmh => (avgSpeedMs ?? 0) * 3.6;
  double get maxSpeedKmh => (maxSpeedMs ?? 0) * 3.6;
  Duration get duration => Duration(seconds: durationSeconds ?? 0);
  
  String get formattedDuration {
    final d = duration;
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
  }

  int get safetyScore {
    if (durationSeconds == null || durationSeconds! < 60) return 100;
    final eventsPerMinute = (unsafeEvents ?? 0) / (durationSeconds! / 60);
    final score = 100 - (eventsPerMinute * 20).clamp(0, 100);
    return score.round();
  }
}

class TripReport {
  final Trip trip;
  final Map<String, dynamic> summary;
  final List<String> recommendations;

  TripReport({
    required this.trip,
    required this.summary,
    required this.recommendations,
  });

  factory TripReport.fromJson(Map<String, dynamic> json) {
    return TripReport(
      trip: Trip.fromJson(json['trip']),
      summary: json['summary'] ?? {},
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }
}
