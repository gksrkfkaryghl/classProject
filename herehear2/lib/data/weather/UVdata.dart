import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:image/image.dart';

final _openUVkey = '7905d47bf86f1bd41e1ea01539633b5d';

class UVData {
  String lat;
  String lon;
  int uvData;

  UVData({@required this.lat, @required this.lon});

  Future<String> getUVData({
    @required String lat,
    @required String lon,
  }) async {
    print("response-asdfasdfasdfasffffghhhjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjkkkkkkkkkkkkkkkk");
    var nowDate = DateTime.now().toString();
    var str = 'https://api.openuv.io/api/v1/uv?lat=$lat&lng=$lon&dt=$nowDate';
    print(str);
    var response = await http.get(Uri.parse(str), headers: {'x-access-token': _openUVkey});
    print("response-asdfasdfasdf: $response");

    if (response.statusCode == 200) {
      var data = response.body;
      print('uv data = $data');
      var jsonData = jsonDecode(data);
      uvData = jsonData['result']['uv_max'].round();
      String uv = uvData.toString();

      print('uv data = $uvData');
      print('uv max data = ${jsonData['result']['uv_max']}');

      return uv;
    } else {
      print("@@@@@@@@@@22222");
      print('response status code = ${response.statusCode}');
    }
  }

  // String UVLevel(String data) {
  //   print('???????????????????????????????????????????????????');
  //   int uvData = int.parse(data);
  //   if(11 <= uvData)
  //     return '위험';
  //   else if((8 <= uvData) && (uvData <= 10))
  //     return '매우 높음';
  //   else if((6 <= uvData) && (uvData <= 7))
  //     return '높음';
  //   else if((3 <= uvData) && (uvData <= 5))
  //     return '보통';
  //   else
  //     return '안심';
  // }

  Text UVLevel(String data) {
    print('???????????????????????????????????????????????????');
    int uvData = int.parse(data);
    if(11 <= uvData)
      return Text(
        '위험',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold
        ),
      );
    else if((8 <= uvData) && (uvData <= 10))
      return Text(
        '매우 높음',
        style: TextStyle(
            color: Colors.deepOrangeAccent,
            fontWeight: FontWeight.bold
        ),
      );
    else if((6 <= uvData) && (uvData <= 7))
      return Text(
        '높음',
        style: TextStyle(
            color: Colors.orangeAccent,
            fontWeight: FontWeight.bold
        ),
      );
    else if((3 <= uvData) && (uvData <= 5))
      return Text(
        '보통',
        style: TextStyle(
            color: Colors.lightGreen,
            fontWeight: FontWeight.bold
        ),
      );
    else
      return Text(
        '안심',
        style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold
        ),
      );
  }
}

