import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:myapp/models/weather_model.dart';

class WeatherServices {
  final String apiKey = '08daa38495d3f18bc054503db57df590';

  Future<Weather> fetchWeather(String cityName) async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Weather.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}