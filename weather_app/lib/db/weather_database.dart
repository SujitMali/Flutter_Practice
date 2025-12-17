import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/weather.dart';

class WeatherDatabase {
  static final WeatherDatabase instance = WeatherDatabase._internal();

  static Database? _database;

  WeatherDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'weather.db');

    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE weather (
        city_id INTEGER PRIMARY KEY,
        city_name TEXT,
        country TEXT,
        lat REAL,
        lon REAL,
        timezone INTEGER,
        condition_id INTEGER,
        main TEXT,
        description TEXT,
        icon TEXT,
        temp REAL,
        feels_like REAL,
        temp_min REAL,
        temp_max REAL,
        pressure INTEGER,
        humidity INTEGER,
        sea_level INTEGER,
        ground_level INTEGER,
        wind_speed REAL,
        wind_deg INTEGER,
        wind_gust REAL,
        visibility INTEGER,
        clouds INTEGER,
        dt INTEGER,
        sunrise INTEGER,
        sunset INTEGER
      )
    ''');
  }

  Future<void> insertWeather(Weather weather) async {
    final db = await database;
    await db.insert(
      'weather',
      weather.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Weather?> getWeatherByCityId(int cityId) async {
    final db = await database;

    final result = await db.query(
      'weather',
      where: 'city_id = ?',
      whereArgs: [cityId],
    );

    if (result.isEmpty) return null;

    final map = result.first;

    return Weather(
      cityId: map['city_id'] as int,
      cityName: map['city_name'] as String,
      country: map['country'] as String,
      latitude: map['lat'] as double,
      longitude: map['lon'] as double,
      timezoneOffset: map['timezone'] as int,
      conditionId: map['condition_id'] as int,
      main: map['main'] as String,
      description: map['description'] as String,
      icon: map['icon'] as String,
      temperature: map['temp'] as double,
      feelsLike: map['feels_like'] as double,
      minTemp: map['temp_min'] as double,
      maxTemp: map['temp_max'] as double,
      pressure: map['pressure'] as int,
      humidity: map['humidity'] as int,
      seaLevel: map['sea_level'] as int?,
      groundLevel: map['ground_level'] as int?,
      windSpeed: map['wind_speed'] as double,
      windDegree: map['wind_deg'] as int,
      windGust: map['wind_gust'] as double?,
      visibility: map['visibility'] as int,
      cloudiness: map['clouds'] as int,
      dataTime: map['dt'] as int,
      sunrise: map['sunrise'] as int,
      sunset: map['sunset'] as int,
    );
  }
}
