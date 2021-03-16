import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(MyApp());
}

// Function which get user location
_getCurrentLocation() async {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  var coordonnees = [];

  await geolocator
      .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
      .then((Position position) {
    coordonnees = [position.latitude, position.longitude];
  });
  return coordonnees;
}

// Class which stores weather data (works with Future<Weather>)
class Weather {
  final int temperature;
  final String temps;
  final int wind;
  final int humidity;
  final int sunrise;
  final int sunset;

  Weather(
      {this.temperature,
      this.temps,
      this.wind,
      this.humidity,
      this.sunrise,
      this.sunset});

  // Connection to Future<Weather>
  factory Weather.fromJson(final json) {
    return Weather(
        sunset: json['sys']['sunset'],
        sunrise: json['sys']['sunrise'],
        humidity: json['main']['humidity'].toInt(),
        wind: json['wind']['speed'].toInt(),
        temperature: json['main']['temp'].toInt(),
        temps: json['weather'][0]['main']);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Météo',
        home: Scaffold(
          backgroundColor: Colors.blue[100],
          appBar: AppBar(title: Text("Météo"), backgroundColor: Colors.blue),
          body: Home(),
        ));
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(children: [
      Container(
        margin: const EdgeInsets.only(top: 10.0),
        width: 340,
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.blue,
        ),
        child: Row(children: [
          Container(
              margin: const EdgeInsets.only(left: 40.0),
              height: 90,
              child: FutureBuilder<Weather>(
                  // Shows weather image
                  future: getWeather(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final weather = snapshot.data;
                      if (weather.temps == 'Clouds') {
                        return Image.asset('assets/cloud.png');
                      } else if (weather.temps == 'Clear') {
                        return Image.asset('assets/clear.png');
                      } else if (weather.temps == 'Rain') {
                        return Image.asset('assets/rain.png');
                      } else if (weather.temps == 'Snow') {
                        return Image.asset('assets/snow.png');
                      } else if (weather.temps == 'Drizzle') {
                        return Image.asset('assets/rain.png');
                      } else if (weather.temps == 'Thunderstorm') {
                        return Image.asset('assets/thunderstorm.png');
                      } else if (weather.temps == 'Mist') {
                        return Image.asset('assets/cloud.png');
                      }
                    } else if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    }
                  })),
          Container(
              margin: const EdgeInsets.only(left: 40.0),
              child: FutureBuilder<Weather>(
                  // Shows temperature
                  future: getWeather(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final weather = snapshot.data;
                      final temp = (weather.temperature - 273.15).round();
                      return Text("${temp.toString()}°C",
                          style: TextStyle(
                              fontSize: 50, fontWeight: FontWeight.bold));
                    } else if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    }
                  }))
        ]),
      ),
      Row(children: [
        Container(
          margin: const EdgeInsets.only(top: 10.0, left: 12.0),
          width: 160,
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: Colors.blue,
          ),
          child: Row(children: [
            Container(
                margin: const EdgeInsets.only(left: 10.0),
                height: 70,
                child: Image.asset('assets/wind.png')),
            Container(
                margin: const EdgeInsets.only(left: 10.0),
                child: FutureBuilder<Weather>(
                    // Shows wind velocity
                    future: getWeather(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final weather = snapshot.data;
                        final wind = weather.wind;
                        return Text("${wind.toString()}m/s",
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold));
                      } else if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      }
                    }))
          ]),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10.0, left: 17.0),
          width: 160,
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: Colors.blue,
          ),
          child: Row(children: [
            Container(
                margin: const EdgeInsets.only(left: 10.0),
                height: 70,
                child: Image.asset('assets/humidity.png')),
            Container(
                margin: const EdgeInsets.only(left: 10.0),
                child: FutureBuilder<Weather>(
                    // Shows humidity %
                    future: getWeather(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final weather = snapshot.data;
                        final humidity = weather.humidity;
                        return Text("${humidity.toString()}%",
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold));
                      } else if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      }
                    }))
          ]),
        ),
      ]),
      Row(children: [
        Container(
          margin: const EdgeInsets.only(top: 10.0, left: 12.0),
          width: 160,
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: Colors.deepOrange,
          ),
          child: Row(children: [
            Container(
                margin: const EdgeInsets.only(left: 10.0),
                height: 70,
                child: Image.asset('assets/sunrise.png')),
            Container(
                margin: const EdgeInsets.only(left: 7.0),
                child: FutureBuilder<Weather>(
                    // Shows sunrise hour
                    future: getWeather(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final weather = snapshot.data;
                        final sunrise = weather.sunrise;
                        int timeInMillis = sunrise * 1000;
                        var date =
                            DateTime.fromMillisecondsSinceEpoch(timeInMillis);
                        var formattedDate = DateFormat.Hm().format(date);
                        return Text("${formattedDate.toString()}",
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold));
                      } else if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      }
                    }))
          ]),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10.0, left: 17.0),
          width: 160,
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: Colors.deepOrange,
          ),
          child: Row(children: [
            Container(
                margin: const EdgeInsets.only(left: 10.0),
                height: 70,
                child: Image.asset('assets/sunset.png')),
            Container(
                margin: const EdgeInsets.only(left: 7.0),
                child: FutureBuilder<Weather>(
                    // Shows sunset hour
                    future: getWeather(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final weather = snapshot.data;
                        final sunset = weather.sunset;
                        int timeInMillis = sunset * 1000;
                        var date =
                            DateTime.fromMillisecondsSinceEpoch(timeInMillis);
                        var formattedDate = DateFormat.Hm().format(date);
                        return Text("${formattedDate.toString()}",
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold));
                      } else if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      }
                    }))
          ]),
        ),
      ]),
    ]));
  }
}

// Future which gets weather data (works with Weather class)
Future<Weather> getWeather() async {
  var coordonnees = await _getCurrentLocation();
  var lat = coordonnees[0];
  var lon = coordonnees[1];
  print(coordonnees);
  final response = await http.get(
      'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&APPID={key}');

  final jsonWeather = jsonDecode(response.body);
  return Weather.fromJson(jsonWeather);
}
