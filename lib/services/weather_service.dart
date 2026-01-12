import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../constants/app_constant.dart';

class WeatherService {
  Future<Weather> getWeatherByCity(String city) async {
    final url = Uri.parse(
      '${AppConstants.weatherBaseUrl}/weather?q=$city&appid=${AppConstants.weatherApiKey}',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Weather.fromJson(json);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<Weather> getWeatherByLocation(double lat, double lon) async {
    final url = Uri.parse(
      '${AppConstants.weatherBaseUrl}/weather?lat=$lat&lon=$lon&appid=${AppConstants.weatherApiKey}',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Weather.fromJson(json);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
