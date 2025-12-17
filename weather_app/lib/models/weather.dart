class Weather {
  // Location
  final int cityId;
  final String cityName;
  final String country;
  final double latitude;
  final double longitude;
  final int timezoneOffset;

  // Weather condition
  final int conditionId;
  final String main;
  final String description;
  final String icon;

  // Temperature & atmosphere
  final double temperature;
  final double feelsLike;
  final double minTemp;
  final double maxTemp;
  final int pressure;
  final int humidity;
  final int? seaLevel;
  final int? groundLevel;

  // Wind & visibility
  final double windSpeed;
  final int windDegree;
  final double? windGust;
  final int visibility;
  final int cloudiness;

  // Time
  final int dataTime;
  final int sunrise;
  final int sunset;

  Weather({
    required this.cityId,
    required this.cityName,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.timezoneOffset,
    required this.conditionId,
    required this.main,
    required this.description,
    required this.icon,
    required this.temperature,
    required this.feelsLike,
    required this.minTemp,
    required this.maxTemp,
    required this.pressure,
    required this.humidity,
    this.seaLevel,
    this.groundLevel,
    required this.windSpeed,
    required this.windDegree,
    this.windGust,
    required this.visibility,
    required this.cloudiness,
    required this.dataTime,
    required this.sunrise,
    required this.sunset,
  });

  /// API JSON → App Data
  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityId: json['id'],
      cityName: json['name'],
      country: json['sys']['country'],
      latitude: (json['coord']['lat'] as num).toDouble(),
      longitude: (json['coord']['lon'] as num).toDouble(),
      timezoneOffset: json['timezone'],
      conditionId: json['weather'][0]['id'],
      main: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      minTemp: (json['main']['temp_min'] as num).toDouble(),
      maxTemp: (json['main']['temp_max'] as num).toDouble(),
      pressure: json['main']['pressure'],
      humidity: json['main']['humidity'],
      seaLevel: json['main']['sea_level'],
      groundLevel: json['main']['grnd_level'],
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      windDegree: json['wind']['deg'],
      windGust:
          json['wind']['gust'] != null
              ? (json['wind']['gust'] as num).toDouble()
              : null,
      visibility: json['visibility'],
      cloudiness: json['clouds']['all'],
      dataTime: json['dt'],
      sunrise: json['sys']['sunrise'],
      sunset: json['sys']['sunset'],
    );
  }

  /// App Data → SQLite
  Map<String, dynamic> toMap() {
    return {
      'city_id': cityId,
      'city_name': cityName,
      'country': country,
      'lat': latitude,
      'lon': longitude,
      'timezone': timezoneOffset,
      'condition_id': conditionId,
      'main': main,
      'description': description,
      'icon': icon,
      'temp': temperature,
      'feels_like': feelsLike,
      'temp_min': minTemp,
      'temp_max': maxTemp,
      'pressure': pressure,
      'humidity': humidity,
      'sea_level': seaLevel,
      'ground_level': groundLevel,
      'wind_speed': windSpeed,
      'wind_deg': windDegree,
      'wind_gust': windGust,
      'visibility': visibility,
      'clouds': cloudiness,
      'dt': dataTime,
      'sunrise': sunrise,
      'sunset': sunset,
    };
  }
}
