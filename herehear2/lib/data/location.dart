import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';


class Location {
  double lat; //위도
  double lon; //경도
  Position position;

  Future<Position> getCurrentLocation() async {
    try {
      // print("111!!!");
      bool isLocationServiceEnabled =
      await Geolocator.isLocationServiceEnabled();
      if (isLocationServiceEnabled) {
        print("True!!");
      } else {
        print("False!!");
      }
      //이 코드는 오류가 날 수 있으니 try catch 로 오류잡기
      // print("222!!!");
      // Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low, timeLimit: Duration(seconds: 10)); <-- 이게 문제였음. 이유는 모르겠음.
      position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

      return position;

    } catch (e) {
      print("error!!!");
      print(e);
    }
    // return position;
  }
}
