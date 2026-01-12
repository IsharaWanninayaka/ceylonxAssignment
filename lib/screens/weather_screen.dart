import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/responsive.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  Weather? _weather;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _cityController.text = 'Colombo';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Weather',
          style: TextStyle(
            color: Colors.blue,
            fontSize: context.tp(6),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Search Section
            Container(
              padding: EdgeInsets.all(context.wp(4)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(context.wp(5)),
                  bottomRight: Radius.circular(context.wp(5)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: context.wp(2),
                    offset: Offset(0, context.wp(0.5)),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(context.wp(3)),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        controller: _cityController,
                        textInputAction: TextInputAction.search,
                        style: TextStyle(fontSize: context.tp(4)),
                        decoration: InputDecoration(
                          hintText: 'Enter city name',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: context.tp(4),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: context.wp(4),
                              vertical: context.hp(1.7)),
                          prefixIcon: Icon(Icons.search,
                              color: Colors.blue, size: context.tp(5)),
                          suffixIcon: _cityController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear,
                                      color: Colors.grey, size: context.tp(4)),
                                  onPressed: () {
                                    _cityController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                        ),
                        onSubmitted: (value) => _fetchWeather(),
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                  ),
                  SizedBox(width: context.wp(3)),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.blue, Colors.lightBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(context.wp(3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: _isLoading
                          ? SizedBox(
                              width: context.wp(4.8),
                              height: context.wp(4.8),
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : Icon(Icons.search,
                              color: Colors.white, size: context.tp(5)),
                      onPressed: _isLoading ? null : _fetchWeather,
                    ),
                  ),
                ],
              ),
            ),

            // Weather Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(context.wp(4)),
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.blue),
                              strokeWidth: 3,
                            ),
                            SizedBox(height: context.hp(2.4)),
                            Text(
                              'Fetching weather data...',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: context.tp(4),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _errorMessage.isNotEmpty
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: context.wp(6)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: context.tp(15),
                                    color: Colors.red.shade300,
                                  ),
                                  SizedBox(height: context.hp(2.4)),
                                  Text(
                                    'Error',
                                    style: TextStyle(
                                      fontSize: context.tp(6),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade400,
                                    ),
                                  ),
                                  SizedBox(height: context.hp(1.2)),
                                  Text(
                                    _errorMessage,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: context.tp(4),
                                    ),
                                  ),
                                  SizedBox(height: context.hp(3.8)),
                                  ElevatedButton(
                                    onPressed: _fetchWeather,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: context.wp(8),
                                          vertical: context.hp(1.6)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            context.wp(3)),
                                      ),
                                    ),
                                    child: Text(
                                      'Try Again',
                                      style: TextStyle(fontSize: context.tp(4)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _weather != null
                            ? _buildWeatherCard(_weather!)
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cloud,
                                      size: context.tp(20),
                                      color: Colors.blue.shade200,
                                    ),
                                    SizedBox(height: context.hp(2.4)),
                                    Text(
                                      'No Weather Data',
                                      style: TextStyle(
                                        fontSize: context.tp(5),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    SizedBox(height: context.hp(1.2)),
                                    Text(
                                      'Search for a city to get weather information',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: context.tp(3.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard(Weather weather) {
    final isDay = DateTime.now().hour >= 6 && DateTime.now().hour < 18;
    final backgroundColor = isDay
        ? [Colors.lightBlue.shade50, Colors.blue.shade50]
        : [Colors.indigo.shade50, Colors.purple.shade50];

    return SingleChildScrollView(
      child: Column(
        children: [
          //---- Main Weather Card -----
          Container(
            padding: EdgeInsets.all(context.wp(4.5)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: backgroundColor,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(context.wp(5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade100.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Location and Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weather.city,
                          style: TextStyle(
                            fontSize: context.tp(7),
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        SizedBox(height: context.hp(0.6)),
                        Text(
                          '${DateTime.now().day} ${_getMonthName(DateTime.now().month)}, ${DateTime.now().year}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: context.tp(3.5),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(context.wp(2.5)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(context.wp(3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isDay ? Icons.wb_sunny : Icons.nightlight,
                        color: isDay ? Colors.orange : Colors.indigo,
                        size: context.tp(6.5),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.hp(3)),

                // Weather Icon and Temperature
                Container(
                  width: context.wp(28).clamp(80.0, 140.0) as double,
                  height: context.wp(28).clamp(80.0, 140.0) as double,
                  child: Image.network(
                    'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.cloud,
                        size: context.tp(15),
                        color: Colors.blue),
                  ),
                ),
                SizedBox(height: context.hp(2)),

                // Temperature
                Text(
                  '${weather.temperature.toStringAsFixed(1)}°C',
                  style: TextStyle(
                    fontSize: context.tp(11),
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                SizedBox(height: context.hp(1)),

                // Weather Description
                Text(
                  weather.description.toUpperCase(),
                  style: TextStyle(
                    fontSize: context.tp(4.5),
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: context.hp(3)),

                // Weather data
                Container(
                  padding: EdgeInsets.all(context.wp(4)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(context.wp(4)),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildWeatherStat(
                        context,
                        'Humidity',
                        '${weather.humidity}%',
                        Icons.water_drop,
                        Colors.blue,
                      ),
                      _buildWeatherStat(
                        context,
                        'Wind',
                        '${weather.windSpeed} m/s',
                        Icons.air,
                        Colors.green,
                      ),
                      _buildWeatherStat(
                        context,
                        'Feels Like',
                        '${weather.temperature.toStringAsFixed(1)}°C',
                        Icons.thermostat,
                        Colors.orange,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.hp(2.6)),

          // Additional Info
          Container(
            padding: EdgeInsets.all(context.wp(4)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(context.wp(4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: context.wp(2),
                  offset: Offset(0, context.wp(0.5)),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weather Details',
                  style: TextStyle(
                    fontSize: context.tp(4.5),
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: context.hp(1.6)),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        context,
                        'Sunrise',
                        '6:30 AM',
                        Icons.wb_twilight,
                        Colors.orange,
                      ),
                    ),
                    SizedBox(width: context.wp(3)),
                    Expanded(
                      child: _buildDetailItem(
                        context,
                        'Sunset',
                        '6:30 PM',
                        Icons.nights_stay,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.hp(1.6)),
                _buildDetailItem(
                  context,
                  'Pressure',
                  '1013 hPa',
                  Icons.compress,
                  Colors.blueGrey,
                ),
                SizedBox(height: context.hp(1.6)),
                _buildDetailItem(
                  context,
                  'Visibility',
                  '10 km',
                  Icons.remove_red_eye,
                  Colors.cyan,
                ),
              ],
            ),
          ),
          SizedBox(height: context.hp(2.6)),

          // Last Updated
          Container(
            padding: EdgeInsets.all(context.wp(3)),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(context.wp(3)),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.update, size: context.tp(3.5), color: Colors.blue),
                SizedBox(width: context.wp(2)),
                Text(
                  'Last updated: ${_formatTime(DateTime.now())}',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: context.tp(3.5),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.hp(2)),
        ],
      ),
    );
  }

  Widget _buildWeatherStat(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(context.wp(2.2)),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: context.tp(5.5), color: color),
        ),
        SizedBox(height: context.hp(1)),
        Text(
          value,
          style: TextStyle(
            fontSize: context.tp(4.5),
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: context.hp(0.6)),
        Text(
          label,
          style: TextStyle(
            fontSize: context.tp(3.5),
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: context.wp(3), vertical: context.hp(1.2)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(context.wp(3)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.wp(1.8)),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.wp(2)),
            ),
            child: Icon(icon, size: context.tp(4.5), color: color),
          ),
          SizedBox(width: context.wp(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: context.tp(3.5),
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: context.hp(0.6)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: context.tp(4),
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _fetchWeather() async {
    final city = _cityController.text.trim();
    if (city.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a city name';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _weather = null;
    });

    try {
      final weatherService =
          Provider.of<WeatherService>(context, listen: false);
      final weather = await weatherService
          .getWeatherByCity(city)
          .timeout(const Duration(seconds: 6));

      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch weather for "$city"';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }
}
