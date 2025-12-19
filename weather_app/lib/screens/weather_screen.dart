import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../repository/weather_repository.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});
  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherRepository _repository = WeatherRepository();

  Weather? _weather;
  bool _loading = false;

  static const int puneCityId = 1259229;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    final cached = await _repository.getCachedWeather(puneCityId);

    if (cached != null) {
      setState(() {
        _weather = cached;
      });
    }

    setState(() {
      _loading = true;
    });

    try {
      final fresh = await _repository.fetchAndCacheWeather('Pune');

      setState(() {
        _weather = fresh;
      });
    } catch (e) {
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather')),
      body:
          _weather == null
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadWeather,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildDetails(),
                  ],
                ),
              ),
    );
  }

  //Ui Part onnly needs to be build
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_weather!.cityName}, ${_weather!.country}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(_weather!.description, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Text(
          '${_weather!.temperature.toStringAsFixed(1)} °C',
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w300),
        ),
        Text('Feels like ${_weather!.feelsLike.toStringAsFixed(1)} °C'),
      ],
    );
  }

  Widget _buildDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _row('Humidity', '${_weather!.humidity}%'),
            _row('Pressure', '${_weather!.pressure} hPa'),
            _row('Wind', '${_weather!.windSpeed} m/s'),
            _row('Clouds', '${_weather!.cloudiness}%'),
            _row(
              'Coordinates',
              '${_weather!.latitude}, ${_weather!.longitude}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
