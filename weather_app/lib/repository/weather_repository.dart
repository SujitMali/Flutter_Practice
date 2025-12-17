import '../models/weather.dart';
import '../services/weather_api_service.dart';
import '../db/weather_database.dart';

class WeatherRepository {
  final WeatherApiService _apiService = WeatherApiService();
  final WeatherDatabase _database = WeatherDatabase.instance;

  //! Always fetch from API, then cache
  Future<Weather> fetchAndCacheWeather(String city) async {
    final weather = await _apiService.fetchWeatherByCity(city);
    await _database.insertWeather(weather);
    return weather;
  }

  //! Load cached weather (offline support)
  Future<Weather?> getCachedWeather(int cityId) async {
    return await _database.getWeatherByCityId(cityId);
  }
}
