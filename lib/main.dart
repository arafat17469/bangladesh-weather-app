import 'package:flutter/material.dart';
import 'package:myapp/models/weather_model.dart';
import 'package:myapp/services/weather_services.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bangladesh Weather',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: Colors.white70),
        ),
      ),
      home: const WeatherHomeScreen(),
    );
  }
}

class WeatherHomeScreen extends StatefulWidget {
  const WeatherHomeScreen({super.key});

  @override
  State<WeatherHomeScreen> createState() => _WeatherHomeScreenState();
}

class _WeatherHomeScreenState extends State<WeatherHomeScreen> {
  final WeatherServices _weatherServices = WeatherServices();
  final List<String> bangladeshZillas = [
    'Dhaka', 'Chittagong', 'Khulna', 'Rajshahi', 'Sylhet', 'Barisal', 'Rangpur',
    'Mymensingh', 'Comilla', 'Narayanganj', 'Gazipur', 'Tangail', 'Bogra',
    'Dinajpur', 'Jessore', 'Narsingdi', 'Faridpur', 'Noakhali', 'Kushtia',
    'Brahmanbaria', 'Satkhira', 'Sirajganj', 'Pabna', 'Naogaon', 'Natore',
    'Sunamganj', 'Joypurhat', 'Habiganj', 'Maulvibazar', 'Lakshmipur',
    'Feni', 'Chandpur', 'Bhola', 'Patuakhali', 'Barguna', 'Jhalokati',
    'Pirojpur', 'Bandarban', 'Khagrachhari', 'Rangamati', 'Cox\'s Bazar',
    'Madaripur', 'Gopalganj', 'Shariatpur', 'Rajbari', 'Manikganj',
    'Munshiganj', 'Netrokona', 'Sherpur', 'Jamalpur', 'Kishoreganj',
    'Thakurgaon', 'Panchagarh', 'Nilphamari', 'Lalmonirhat', 'Kurigram',
    'Gaibandha', 'Chapainawabganj', 'Meherpur', 'Chuadanga', 'Jhenaidah',
    'Magura', 'Bagerhat', 'Narail'
  ];
  String? selectedZilla = 'Dhaka';
  Weather? weatherData;
  bool _isLoading = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<String> filteredZillas = [];

  @override
  void initState() {
    super.initState();
    filteredZillas = bangladeshZillas;
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    if (selectedZilla == null) return;
    setState(() => _isLoading = true);
    try {
      final weather = await _weatherServices.fetchWeather(selectedZilla!);
      setState(() {
        weatherData = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        weatherData = null;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load weather data')),
      );
    }
  }

  void _filterZillas(String query) {
    setState(() {
      filteredZillas = bangladeshZillas
          .where((zilla) => zilla.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  String _getAnimationAsset(String? description) {
    if (description?.contains('rain') ?? false) return 'assets/rain.json';
    if (description?.contains('clear') ?? false) return 'assets/sunny.json';
    return 'assets/cloudy.json';
  }

  List<Map<String, dynamic>> _getHourlyForecast(Weather? weather) {
    if (weather == null) return [];
    return List.generate(5, (index) => {
      'time': '${index + 1}:00 PM',
      'temp': weather.temperature + (index * 0.5),
      'condition': index == 0 ? 'Sunny' : index <= 2 ? 'Cloudy' : 'Rainy',
    });
  }

  List<Color> _getBackgroundGradient(String? description) {
    if (description?.contains('rain') ?? false) return [Colors.blueGrey, Colors.grey];
    if (description?.contains('clear') ?? false) return [Colors.orange, Colors.yellow];
    return [Colors.grey, Colors.blueGrey];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _getBackgroundGradient(weatherData?.description),
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: _isSearching
                                ? TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: 'Search Zilla...',
                                      hintStyle: const TextStyle(color: Colors.white70),
                                      filled: true,
                                      fillColor: Colors.white.withOpacity(0.2),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    onChanged: _filterZillas,
                                    autofocus: true,
                                  )
                                : Text(
                                    selectedZilla ?? 'Select a Zilla',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 24),
                                  ),
                          ),
                          IconButton(
                            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _isSearching = !_isSearching;
                                if (!_isSearching) {
                                  _searchController.clear();
                                  filteredZillas = bangladeshZillas;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    if (_isSearching)
                      Container(
                        height: 200,
                        color: Colors.white.withOpacity(0.1),
                        child: ListView.builder(
                          itemCount: filteredZillas.length,
                          itemBuilder: (context, index) {
                            final zilla = filteredZillas[index];
                            return ListTile(
                              title: Text(zilla, style: const TextStyle(color: Colors.white)),
                              onTap: () {
                                setState(() {
                                  selectedZilla = zilla;
                                  _isSearching = false;
                                  _searchController.clear();
                                  filteredZillas = bangladeshZillas;
                                });
                                _fetchWeather();
                              },
                            );
                          },
                        ),
                      ),
                    if (!_isSearching)
                      Expanded(
                        child: weatherData == null
                            ? const Center(
                                child: Text(
                                  'No weather data available',
                                  style: TextStyle(color: Colors.white70, fontSize: 18),
                                ),
                              )
                            : ListView(
                                padding: const EdgeInsets.all(16.0),
                                children: [
                                  Lottie.asset(
                                    _getAnimationAsset(weatherData?.description),
                                    height: 150,
                                    width: double.infinity,
                                  ),
                                  Text(
                                    '${weatherData!.temperature.toStringAsFixed(1)}°C',
                                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                          fontSize: 64,
                                          color: Colors.white,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    weatherData!.description,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 20),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.water_drop, color: Colors.white70),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Humidity: ${weatherData!.humidity}%',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                      const SizedBox(width: 20),
                                      const Icon(Icons.air, color: Colors.white70),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Wind: ${weatherData!.windSpeed} m/s',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 30),
                                  const Text(
                                    'Hourly Forecast',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 120,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _getHourlyForecast(weatherData).length,
                                      itemBuilder: (context, index) {
                                        final hour = _getHourlyForecast(weatherData)[index];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                          child: Column(
                                            children: [
                                              Text(
                                                hour['time'],
                                                style: const TextStyle(color: Colors.white70),
                                              ),
                                              const SizedBox(height: 10),
                                              Icon(
                                                hour['condition'] == 'Sunny'
                                                    ? Icons.wb_sunny
                                                    : hour['condition'] == 'Cloudy'
                                                        ? Icons.cloud
                                                        : Icons.water_drop,
                                                color: Colors.white70,
                                                size: 30,
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                '${hour['temp'].toStringAsFixed(1)}°C',
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}