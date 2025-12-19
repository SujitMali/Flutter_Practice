import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherApiService {
  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';
  static const String _apiKey = '8a9918ad5544cd4679371a221f0610fe';

  Future<Weather> fetchWeatherByCity(String city) async {
    final uri = Uri.parse('$_baseUrl?q=$city&units=metric&appid=$_apiKey');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);

      return Weather.fromJson(json);
    } else {
      throw Exception('Failed to fetch weather (${response.statusCode})');
    }
  }
}
