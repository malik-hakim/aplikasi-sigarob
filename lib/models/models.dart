// ── StatusData (Beranda) ──────────────────────────────────────────────────────
class StatusData {
  final String  alertLevel;
  final double? floodProbability24h;
  final String? alertReason;
  final String? alertUpdatedAt;
  final double  waterLevelCm;
  final double? temperatureC;
  final double? humidityPct;
  final String  sensorStatus;
  final String? sensorRecordedAt;
  final String? weatherDesc;
  final double? rainfallMm;
  final double? windSpeedKmh;
  final String? windDirection;
  final String? bmkgUpdatedAt;

  const StatusData({
    required this.alertLevel,
    this.floodProbability24h,
    this.alertReason,
    this.alertUpdatedAt,
    required this.waterLevelCm,
    this.temperatureC,
    this.humidityPct,
    required this.sensorStatus,
    this.sensorRecordedAt,
    this.weatherDesc,
    this.rainfallMm,
    this.windSpeedKmh,
    this.windDirection,
    this.bmkgUpdatedAt,
  });

  factory StatusData.fromJson(Map<String, dynamic> j) => StatusData(
    alertLevel:          j['alert_level']           as String? ?? 'INFO',
    floodProbability24h: (j['flood_probability_24h'] as num?)?.toDouble(),
    alertReason:         j['alert_reason']           as String?,
    alertUpdatedAt:      j['alert_updated_at']       as String?,
    waterLevelCm:       (j['water_level_cm']         as num?)?.toDouble() ?? 0,
    temperatureC:       (j['temperature_c']          as num?)?.toDouble(),
    humidityPct:        (j['humidity_pct']           as num?)?.toDouble(),
    sensorStatus:        j['sensor_status']           as String? ?? 'OFFLINE',
    sensorRecordedAt:    j['sensor_recorded_at']      as String?,
    weatherDesc:         j['weather_desc']            as String?,
    rainfallMm:         (j['rainfall_mm']            as num?)?.toDouble(),
    windSpeedKmh:       (j['wind_speed_kmh']         as num?)?.toDouble(),
    windDirection:       j['wind_direction']          as String?,
    bmkgUpdatedAt:       j['bmkg_updated_at']         as String?,
  );
}

// ── PrakiraanDay (Prakiraan) ──────────────────────────────────────────────────
class PrakiraanDay {
  final String  label;
  final String  date;
  final String  alertLevel;
  final double? floodProbability;
  final double? predictedLevelCm;
  final double? rainfallMm;
  final String? weatherDesc;
  final double? windSpeedKmh;

  const PrakiraanDay({
    required this.label,
    required this.date,
    required this.alertLevel,
    this.floodProbability,
    this.predictedLevelCm,
    this.rainfallMm,
    this.weatherDesc,
    this.windSpeedKmh,
  });

  factory PrakiraanDay.fromJson(Map<String, dynamic> j) => PrakiraanDay(
    label:            j['label']              as String? ?? '',
    date:             j['date']               as String? ?? '',
    alertLevel:       j['alert_level']        as String? ?? 'INFO',
    floodProbability:(j['flood_probability']  as num?)?.toDouble(),
    predictedLevelCm:(j['predicted_level_cm'] as num?)?.toDouble(),
    rainfallMm:      (j['rainfall_mm']        as num?)?.toDouble(),
    weatherDesc:      j['weather_desc']       as String?,
    windSpeedKmh:    (j['wind_speed_kmh']     as num?)?.toDouble(),
  );
}

// ── FloodEvent (Riwayat) ──────────────────────────────────────────────────────
class FloodEvent {
  final int     id;
  final String  maxLevel;
  final double  maxWaterLevelCm;
  final String  startedAt;
  final String? endedAt;
  final int?    durationMinutes;
  final String? notes;

  const FloodEvent({
    required this.id,
    required this.maxLevel,
    required this.maxWaterLevelCm,
    required this.startedAt,
    this.endedAt,
    this.durationMinutes,
    this.notes,
  });

  factory FloodEvent.fromJson(Map<String, dynamic> j) => FloodEvent(
    id:               j['id']                  as int,
    maxLevel:         j['max_level']            as String? ?? 'INFO',
    maxWaterLevelCm: (j['max_water_level_cm']   as num).toDouble(),
    startedAt:        j['started_at']           as String,
    endedAt:          j['ended_at']             as String?,
    durationMinutes:  j['duration_minutes']     as int?,
    notes:            j['notes']                as String?,
  );
}

// ── RiwayatStats ──────────────────────────────────────────────────────────────
class RiwayatStats {
  final int totalKejadian;
  final int totalSiaga;
  final int totalEvakuasi;

  const RiwayatStats({
    required this.totalKejadian,
    required this.totalSiaga,
    required this.totalEvakuasi,
  });

  factory RiwayatStats.fromJson(Map<String, dynamic> j) => RiwayatStats(
    totalKejadian: j['total_kejadian'] as int? ?? 0,
    totalSiaga:    j['total_siaga']    as int? ?? 0,
    totalEvakuasi: j['total_evakuasi'] as int? ?? 0,
  );
}

// ── EvacuationPoint (Panduan) ─────────────────────────────────────────────────
class EvacuationPoint {
  final int     id;
  final String  name;
  final String  address;
  final double  latitude;
  final double  longitude;
  final int     capacity;
  final String? description;

  const EvacuationPoint({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.capacity,
    this.description,
  });

  factory EvacuationPoint.fromJson(Map<String, dynamic> j) => EvacuationPoint(
    id:         j['id']          as int,
    name:       j['name']        as String,
    address:    j['address']     as String,
    latitude:  (j['latitude']    as num).toDouble(),
    longitude: (j['longitude']   as num).toDouble(),
    capacity:   j['capacity']    as int? ?? 0,
    description:j['description'] as String?,
  );
}

// ── EmergencyContact (Panduan) ────────────────────────────────────────────────
class EmergencyContact {
  final int     id;
  final String  name;
  final String  category;
  final String  phoneNumber;
  final String? address;
  final String? description;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.category,
    required this.phoneNumber,
    this.address,
    this.description,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> j) => EmergencyContact(
    id:          j['id']           as int,
    name:        j['name']         as String,
    category:    j['category']     as String? ?? 'LAINNYA',
    phoneNumber: j['phone_number'] as String,
    address:     j['address']      as String?,
    description: j['description']  as String?,
  );
}

// ── SensorPoint (grafik) ──────────────────────────────────────────────────────
class SensorPoint {
  final DateTime recordedAt;
  final double   waterLevelCm;

  const SensorPoint({required this.recordedAt, required this.waterLevelCm});

  factory SensorPoint.fromJson(Map<String, dynamic> j) => SensorPoint(
    recordedAt:   DateTime.parse(j['recorded_at'] as String),
    waterLevelCm:(j['water_level_cm'] as num).toDouble(),
  );
}
