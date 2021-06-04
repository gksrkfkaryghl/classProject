import 'dart:convert';

import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
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

  Future<String> getLocation() async {
    // LocationPermission permission = await Geolocator.requestPermission();
    String location = '';

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    debugPrint('location: ${position.latitude}');
    final coordinates = new Coordinates(position.latitude, position.longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    print("detail address : ${first.addressLine}");
    print("needed address data : ${first.locality} ${first.subLocality}");
    location = '${first.locality} ${first.subLocality}';
    print('location: $location');
    return location;
  }
}
