import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

final _openDustkey = '2690c33d-3f03-4b89-8d37-60e15af10963';

class DustData {
  String lat;
  String lon;

  DustData({@required this.lat, @required this.lon});

  Future<String> getDustData({
    @required String lat,
    @required String lon,
  }) async {
    var str =
        'http://api.airvisual.com/v2/nearest_city?lat=$lat&lon=$lon&key=$_openDustkey';
    print(str);
    var response = await http.get(Uri.parse(str));

    if (response.statusCode == 200) {
      var data = response.body;
      print('dust data = $data');
      var jsonData = jsonDecode(data);
      String dustValue = jsonData['data']['current']['pollution']['aqius'].toString();

      print('dust data = $dustValue');

      return dustValue;
    } else {
      print('response status code = ${response.statusCode}');
    }
  }

  // String DustLevel(String data) {
  //   print('???????????????????????????????????????????????????');
  //   int dustData = int.parse(data);
  //   if(201 <= dustData)
  //     return '심각';
  //   else if((151 <= dustData) && (dustData <= 200))
  //     return '매우 나쁨';
  //   else if((101 <= dustData) && (dustData <= 150))
  //     return '나쁨';
  //   else if((51 <= dustData) && (dustData <= 100))
  //     return '양호';
  //   else
  //     return '좋음';
  // }

  Text DustLevel(String data) {
    print('???????????????????????????????????????????????????');
    int dustData = int.parse(data);
    if(201 <= dustData)
      return Text(
        '심각',
        style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold
        ),
      );
    else if((151 <= dustData) && (dustData <= 200))
      return Text(
        '매우 나쁨',
        style: TextStyle(
            color: Colors.deepOrangeAccent,
            fontWeight: FontWeight.bold
        ),
      );
    else if((101 <= dustData) && (dustData <= 150))
      return Text(
        '나쁨',
        style: TextStyle(
            color: Colors.orangeAccent,
            fontWeight: FontWeight.bold
        ),
      );
    else if((51 <= dustData) && (dustData <= 100))
      return Text(
        '보통',
        style: TextStyle(
            color: Colors.lightGreen,
            fontWeight: FontWeight.bold
        ),
      );
    else
      return Text(
        '좋음',
        style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold
        ),
      );
  }

  AssetImage DustIcon(String data) {
    int dustData = int.parse(data);
    return (201 <= dustData)
        ? AssetImage('assets/weather/dustLevel/dust_worst.png')
        : ((151 <= dustData) && (dustData <= 200))
            ? AssetImage('assets/weather/dustLevel/dust_bad.png')
            : ((51 <= dustData) && (dustData <= 150))
                ? AssetImage('assets/weather/dustLevel/dust_notBad.png')
                  : AssetImage('assets/weather/dustLevel/dust_good.png');
  }
}
