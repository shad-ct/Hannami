import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  const WeatherService();

  Future<String?> fetchWeatherSummary(double latitude, double longitude) async {
    final uri = Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true');
    try {
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final cw = data['current_weather'] as Map<String, dynamic>?;
        if (cw != null) {
          final temp = cw['temperature'];
          final wind = cw['windspeed'];
          final weatherCode = cw['weathercode'];
          return '${temp}°C code:$weatherCode wind:${wind}km/h';
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
