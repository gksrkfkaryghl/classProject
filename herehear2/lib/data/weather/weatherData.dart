import 'package:weather/weather.dart';
import 'package:flutter/material.dart';


class WeatherData {

  int extractTemperature(String data) {
    var parts = data.split(' ');
    var temp = parts[0].trim();
    var doubleNum = double.parse(temp);
    int result = doubleNum.round();

    return result;
  }

  String extractWeatherCondition(String data) {
    // var parts = data.split(', ');
    // String result = parts[0];

    return data;
  }

  DateTime convertTimeToLocal(DateTime dateUtc) {
    var dateU = dateUtc;
    print("%%%: $dateU");
    var strToDateTime = DateTime.parse(dateUtc.toString());
    final convertLocal = strToDateTime.toLocal();

    print("&&&: $convertLocal");

    return convertLocal;
  }

  Text humidityLevel(Weather weather) {
    double humidity = weather.humidity;
    if(80 <= humidity)
      return Text(
        '매우 습함',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      );
    else if((71 <= humidity) && (humidity <= 80))
      return Text(
        '습함',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.deepOrangeAccent,
        ),
      );
    else if((61 <= humidity) && (humidity <= 70))
      return Text(
        '조금 습함',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.orangeAccent,
        ),
      );
    else if((40 <= humidity) && (humidity <= 60))
      return Text(
        '쾌적',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      );
    else if((30 <= humidity) && (humidity <= 39))
      return Text(
        '조금 건조',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.orangeAccent,
        ),
      );
    else if((20 <= humidity) && (humidity <= 29))
      return Text(
        '건조',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.deepOrangeAccent,
        ),
      );
    else
      return Text(
        '매우 습함',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      );
  }

  Text feelLikeTempLevel(Weather weather) {
    int feelLike = WeatherData().extractTemperature(weather.tempFeelsLike.toString());

    if(28 <= feelLike)
      return Text(
        '매우 더움',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      );
    else if((25 <= feelLike) && (feelLike <= 27))
      return Text(
        '더움',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.deepOrange,
        ),
      );
    else if((21 <= feelLike) && (feelLike <= 24))
      return Text(
        '조금 더움',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.orange,
        ),
      );
    else if((12 <= feelLike) && (feelLike <= 20))
      return Text(
        '따뜻',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      );
    else if((-2 <= feelLike) && (feelLike <= 11))
      return Text(
        '시원',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      );
    else if((-9 <= feelLike) && (feelLike <= -3))
      return Text(
        '쌀쌀',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      );
    else if((-14 <= feelLike) && (feelLike <= -10))
      return Text(
        '추움',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.lightBlue,
        ),
      );
    else
      return Text(
        '매우 추움',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.lightBlueAccent,
        ),
      );
  }
}