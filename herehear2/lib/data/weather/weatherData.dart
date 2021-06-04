import 'dart:io';

// import 'package:closet/closet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart'
as locator;
import 'package:weather/weather.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';


class WeatherData {


  Widget weatherMessage(Weather weather) {
    int temp = extractTemperature(weather.temperature.toString());
    int maxTemp = extractTemperature(weather.tempMax.toString());
    int minTemp = extractTemperature(weather.tempMin.toString());

    String codi;
    String advice;
    String tempDifference ='';

    if(maxTemp - minTemp >= 10) {
      tempDifference = '일교차 주의!';
    }

    if(27 <= temp) {
      advice = "오늘은 정말 더운날이네요!";
      codi = "추천의상: 민소매/반팔/반바지/치마";
    } else if(23 <= temp && temp <= 26) {
      advice = "오늘은 아주 여름여름한 날씨네요!";
      codi = "추천의상: 반팔/얇은 셔츠/반바지/면바지";
    } else if(20 <= temp && temp <= 22) {
      advice = "오늘은 반팔을 입긴 애매한 날씨네요!";
      codi = "추천의상: 얇은 가디건/긴팔티/면바지/슬랙스";
    } else if(17 <= temp && temp <= 19) {
      advice = "이정도면 꽤나 시원한 날씨죠!";
      codi = "추천의상: 니트/가디건/맨투맨/원피스/면바지/청바지/슬랙스";
    } else if(12 <= temp && temp <= 16) {
      advice = "추위를 타시는 편이라면 아우터도 챙겨가세요!";
      codi = "추천의상: 자켓/셔츠/가디건/야상/맨투맨/니트/스타킹";
    } else if(9 <= temp && temp <= 11) {
      advice = "오늘은 아우터도 챙겨입으시는 게 좋아요!";
      codi = "추천의상: 자켓/트렌치코트/야상/니트/스타킹/청바지/면바지";
    } else if(5 <= temp && temp <= 8) {
      advice = "오늘은 쌀쌀한 게 코트 입기 좋은 날씨군요!";
      codi = "추천의상: 코트/가죽자켓/니트/청바지/레깅스";
    } else {
      advice = "당장 가지고 계신 가장 따뜻한 아우터를 꺼내보아요!";
      codi = "추천의상: 겨울 옷(패딩/목도리/야상 등)";
    }

    return Text("$advice $tempDifference\n$codi", style: TextStyle(color: Colors.grey[600],));
  }

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


  Widget weatherIcon(Weather weather, Weather weatherData, num width) {
    convertTimeToLocal(weather.sunrise);
    convertTimeToLocal(weather.sunset);

    // print("now: ${weather.rainLast3Hours}");
    if (weatherData.weatherMain == 'Rain') {
      return Image(
        image: AssetImage("assets/weather/rain.png"),
        width: width,
        fit: BoxFit.scaleDown,
      );
    } else if (weatherData.weatherMain == 'Snow') {
      return Image(
        image: AssetImage("assets/weather/snow.png"),
        width: width,
        fit: BoxFit.scaleDown,
      );
    } else if ((weather.sunrise.hour >= weatherData.date.hour) || (weather.sunset.hour < weatherData.date.hour)) {
      if ((weatherData.weatherConditionCode < 600) || (weatherData.weatherConditionCode == 804)) {
        return Image(
          image: AssetImage("assets/weather/cloudy_night.png"),
          width: width,
          fit: BoxFit.scaleDown,
        );
      } else if (weatherData.weatherConditionCode == 801) {
        return Image(
          image: AssetImage("assets/weather/few_clouds_night.png"),
          width: width,
          fit: BoxFit.scaleDown,
        );
      } else {
        return Image(
          image: AssetImage("assets/weather/moon.png"),
          width: width,
          fit: BoxFit.scaleDown,
        );
      }
    } else {
      if ((weatherData.weatherConditionCode < 600) ||
          (weatherData.weatherConditionCode == 804)) {
        return Image(
          image: AssetImage("assets/weather/cloudy.png"),
          width: width,
          fit: BoxFit.scaleDown,
        );
      } else if (weatherData.weatherConditionCode == 801) {
        return Image(
          image: AssetImage("assets/weather/few_clouds.png"),
          width: width,
          fit: BoxFit.scaleDown,
        );
      } else if ((weather.weatherConditionCode == 802) || (weather.weatherConditionCode == 803)) {
        return Image(
          image: AssetImage("assets/weather/broken_clouds.png"),
          width: width,
          fit: BoxFit.scaleDown,
        );
      } else {
        return Image(
          image: AssetImage("assets/weather/sunny.png"),
          width: width,
          fit: BoxFit.scaleDown,
        );
      }
    }
  }

  DateTime convertTimeToLocal(DateTime dateUtc) {
    var dateU = dateUtc;
    print("%%%: $dateU");
    var strToDateTime = DateTime.parse(dateUtc.toString());
    final convertLocal = strToDateTime.toLocal();

    print("&&&: $convertLocal");

    return convertLocal;
  }


  AssetImage detailWeatherBackground(Weather weather, Weather weatherData) {
    if((weather.sunrise.hour >= weatherData.date.hour) || (weather.sunset.hour < weatherData.date.hour)) {
      return AssetImage("assets/weather/detail_night.png");
    } else if(weather.weatherMain == 'Rain') {
      return AssetImage("assets/weather/detail_rain.png");
    } else if(weather.weatherMain == 'Snow') {
      return AssetImage("assets/weather/detail_snow.png");
    } else if(weather.weatherConditionCode < 600) {
      return AssetImage("assets/weather/detail_cloudy.png");
    } else {
      return AssetImage("assets/weather/detail_sunny.png");;
    }
    return weather.weatherMain == 'Rain'
        ? AssetImage("assets/weather/detail_rain.png")
        : weather.weatherMain == 'Snow'
        ? AssetImage("assets/weather/detail_snow.png")
        : weather.weatherConditionCode < 600
        ? AssetImage("assets/weather/detail_cloudy.png")
        : DateTime.now().hour >= 15
        ? AssetImage("assets/weather/detail_night.png")
        : AssetImage("assets/weather/detail_sunny.png");
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

  AssetImage humidityIcon(double humidity) {
    return (91 <= humidity)
        ? AssetImage('assets/weather/humidityLevel/humidity10.png')
        : ((81 <= humidity) && (humidity <= 90))
            ? AssetImage('assets/weather/humidityLevel/humidity9.png')
            : ((71 <= humidity) && (humidity <= 80))
                ? AssetImage('assets/weather/humidityLevel/humidity8.png')
                : ((61 <= humidity) && (humidity <= 70))
                    ? AssetImage('assets/weather/humidityLevel/humidity7.png')
                    : ((51 <= humidity) && (humidity <= 60))
                        ? AssetImage(
                            'assets/weather/humidityLevel/humidity6.png')
                        : ((41 <= humidity) && (humidity <= 50))
                            ? AssetImage(
                                'assets/weather/humidityLevel/humidity5.png')
                            : ((31 <= humidity) && (humidity <= 40))
                                ? AssetImage(
                                    'assets/weather/humidityLevel/humidity4.png')
                                : ((21 <= humidity) && (humidity <= 30))
                                    ? AssetImage(
                                        'assets/weather/humidityLevel/humidity3.png')
                                    : ((11 <= humidity) && (humidity <= 20))
                                        ? AssetImage(
                                            'assets/weather/humidityLevel/humidity2.png')
                                        : AssetImage(
                                            'assets/weather/humidityLevel/humidity1.png');
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

  AssetImage feelLikeIcon(Weather weather) {
    int feelLike = WeatherData().extractTemperature(weather.tempFeelsLike.toString());
    return (25 <= feelLike)
        ? AssetImage('assets/weather/feelLike/feelLike_high.png')
        : ((5 <= feelLike) && (feelLike <= 24))
            ? AssetImage('assets/weather/feelLike/feelLike_middle.png')
              : AssetImage('assets/weather/feelLike/feelLike_low.png');
  }
}