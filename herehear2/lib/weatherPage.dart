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
import 'data/weather/UVdata.dart';
import 'data/weather/dust.dart';
import 'data/location.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'data/weather/weatherData.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;
final String UserEmail = _auth.currentUser.email;

class weatherPage extends StatefulWidget {
  @override
  _weatherPageState createState() => _weatherPageState();
}

class _weatherPageState extends State<weatherPage> {
  String _key = "f781792aecfebe7bcce77b83a692ff4b";

  // String cityName = 'Kongens Lyngby';
  WeatherFactory wf;
  Weather weather;
  List<Weather> forecasts;
  File _imageFile;
  User _user;
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  String _downloadURL;
  String _downloadURL2; // <-- 지울 것
  String path = "user/" + "$UserEmail/1ba64621c29b461aab9a7dc495e7a178.jpg";
  String path2 = "user/" + "$UserEmail/74c33bd4028dc12361ff8a2457eed71f.jpg"; // <-- 이것도 지울것
  String uvData;
  var uvLevel;
  String dustData;
  var dustLevel;
  String nickname;
  double lat;
  double lon;

  void _prepareService() async {
    _user = await _auth.currentUser;
    FirebaseFirestore.instance.
      collection('user').
      doc(UserEmail).get().
      then((DocumentSnapshot snapshot) {
        nickname = snapshot.get('nickname');
        print('nickname: $nickname');
    });
    Reference ref = FirebaseStorage.instance.ref().child(path);
    _downloadURL = await ref.getDownloadURL();
    Reference ref2 = FirebaseStorage.instance.ref().child(path2);
    _downloadURL2 = await ref2.getDownloadURL();
    print("What?!: $_downloadURL");
    print(_firebaseStorage.ref().getDownloadURL());
  }

  // void _uploadImageStorage(ImageSource source) async {
  //   String docID = Timestamp.now().seconds.toString();
  //   File image = await ImagePicker.pickImage(source: source);
  //
  //   Reference ref = FirebaseStorage.instance.ref().child(path);
  //
  //   _downloadURL = await ref.getDownloadURL();
  //
  //   if (image == null) return;
  //   setState(() {
  //     _imageFile = image;
  //   });
  // }


  @override
  void initState() {
    super.initState(); // super : 자식 클래스에서 부모 클래스의 멤버변수 참조할 때 사용
    wf = new WeatherFactory(_key, language: Language.KOREAN);
    _prepareService();
    getWeather();
    // UVandDustData();
    getFiveDaysWeather();
    // getForecastData();
  }

  Future<List<Weather>> getWeather() async {
    final locator.Position position = await Location().getCurrentLocation();
    double lat = position.latitude;
    double lon = position.longitude;

    weather = await wf.currentWeatherByLocation(lat, lon);
    print("UV: $uvData");
    print("dust: $dustData");
    setState(() {
      print("*********** $weather");
    });
  }

  Future<List<Weather>> getFiveDaysWeather() async {
    final locator.Position position = await Location().getCurrentLocation();
    double lat = position.latitude;
    double lon = position.longitude;

    forecasts = await wf.fiveDayForecastByLocation(lat, lon);

    await DustData().getDustData(lat: lat.toString(), lon: lon.toString())
        .then((value){
      dustData = value;
      dustLevel = DustData().DustLevel(value);
    });

    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>> ${weather.sunrise}");
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>> ${forecasts[0]}");
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>> ${forecasts[1]}");
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>> ${forecasts[2]}");
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>> ${forecasts[3]}");
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>> ${forecasts[4]}");
    return forecasts;
  }

  void UVandDustData() async {
    final locator.Position position = await Location().getCurrentLocation();
    lat = position.latitude;
    lon = position.longitude;

    await UVData().getUVData(lat: lat.toString(), lon: lon.toString())
        .then((value){
      uvData = value;
      uvLevel = UVData().UVLevel(value);
    });
    await DustData().getDustData(lat: lat.toString(), lon: lon.toString())
        .then((value){
      dustData = value;
      dustLevel = DustData().DustLevel(value);
    });
  }



  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getFiveDaysWeather(),
      builder: (context, AsyncSnapshot<List<Weather>> forecasts) {
        if (forecasts.hasData == false) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: Center(
              child: SizedBox(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
                ),
                height: 40.0,
                width: 40.0,
              ),
            ),
          );
        } else {
          return weatherInformation();
        }
      },
    );
  }

  Widget weatherInformation() {
    final Size size = MediaQuery.of(context).size;
    int temp = WeatherData().extractTemperature(weather.temperature.toString());
    int feelLike = WeatherData().extractTemperature(weather.tempFeelsLike.toString());
    int maxTemp = WeatherData().extractTemperature(weather.tempMax.toString());
    int minTemp = WeatherData().extractTemperature(weather.tempMin.toString());
    String weatherCondition = WeatherData().extractWeatherCondition(weather.weatherMain.toString());

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left,
            color: Theme.of(context).colorScheme.primary,
            size: 30,
          ),
          onPressed: () {
            // Navigator.of(context).pop(SwipeablePageRoute(
            //   // onlySwipeFromEdge: true,
            //   builder: (BuildContext context) => closet(),
            // ));
          },
        ),
        //
        title: Text(
          "Here 날씨",
          style: TextStyle(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
        ),
        actions: [
          Icon(Icons.menu),
        ],
      ),
      body: ListView(
        // shrinkWrap: true,
        // padding: EdgeInsets.all(15.0),
        children: [
          weatherScreen(size, temp, maxTemp, minTemp, feelLike, weatherCondition),
          Divider(),
          // codiRecommend(size),
          subTitle("시간대별 기온", size),
          forecastChart(size),
          SizedBox(height: 10,),
          subTitle("상세날씨", size),
          detailWeatherInformation(feelLike),
          Divider(),

          // subTitle("생활지수", size),
          // livingIndexInformation(feelLike),
        ],
      ),
    );
  }

  Widget weatherScreen(Size size, int temp, int maxTemp, int minTemp, int feelLike, String weatherCondition) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        // height: size.height * 0.239,
        // height: size.height * 0.26,
        // height: size.height * 0.32,
        // decoration: BoxDecoration(
        //   image: DecorationImage(
        //     image: WeatherData().detailWeatherBackground(weather, weather),
        //     fit: BoxFit.fill,
        //   ),
        // ),
        child: Padding(
            padding: EdgeInsets.fromLTRB(
                size.width * 0.03, 8, size.width * 0.04, 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on),
                    SizedBox(width: 5),
                    Text(
                      "${weather.areaName}",
                      style: TextStyle(
                        fontSize: 20,
                        // fontWeight: FontWeight.bold,
                        // color: Colors.b,
                        // color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    // Column(
                    //   children: <Widget>[
                    //     Padding(
                    //       padding: EdgeInsets.fromLTRB(
                    //           size.width * 0.056, size.height * 0.024, 0, 0),
                    //       child: WeatherData().weatherIcon(weather, weather, size.width * 0.15),
                    //     ),
                    //     SizedBox(height: 60),
                    //     Padding(
                    //         padding: EdgeInsets.fromLTRB(
                    //             size.width * 0.04, size.height * 0.024, 0, 0),
                    //         child: Image(
                    //             image: AssetImage("assets/cloy.png"),
                    //             width: size.width * 0.085))
                    //   ],
                    // ),
                    // SizedBox(
                    //   // width: size.width * 0.3,
                    //   width: size.width * 0.18,
                    // ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
                      child: Text(
                        "${temp.toString()}°",
                        style: TextStyle(
                          fontSize: 65,
                          fontWeight: FontWeight.bold,
                          // color: Theme.of(context).colorScheme.onPrimary,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    Expanded(child: Container()),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 1.0),
                            child: Text(
                              "${weatherCondition} ",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 1.0),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "${maxTemp.toString()}°",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.red,
                                  ),
                                ),
                                Text(
                                  " / ",
                                  style: TextStyle(
                                    fontSize: 13,
                                    // color: Theme.of(context).colorScheme.onPrimary,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  "${minTemp.toString()}°",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "체감온도 ${feelLike.toString()}°",
                            style: TextStyle(
                              fontSize: 13,
                              // color: Theme.of(context).colorScheme.onPrimary,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // WeatherData().weatherMessage(weather),
              ],
            )
        ),
      ),
    );
  }



  Widget forecastChart(Size size) {
    return Stack(
      children: <Widget>[
        SfCartesianChart(
            // backgroundColor: Colors.blue,
            enableAxisAnimation: true,
            primaryXAxis: CategoryAxis(
              labelPosition: ChartDataLabelPosition.inside,
              tickPosition: TickPosition.inside,
              axisLine: AxisLine(width: 0),
              opposedPosition: true,
              labelStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            primaryYAxis: NumericAxis(
                isVisible: false,
                labelFormat: '{value}°',
                minimum: -20,
                maximum: 40,
                majorGridLines: MajorGridLines(width: 0),
                plotBands: <PlotBand>[
                  PlotBand(
                    start: 0,
                    end: 0,
                    borderColor: Colors.lightBlueAccent,
                    borderWidth: 1,
                    verticalTextPadding: '2%',
                    horizontalTextPadding: '-46%',
                    text: '0°',
                    textAngle: 0,
                    textStyle:
                    TextStyle(color: Colors.blueAccent, fontSize: 14),
                  ),
                ]),
            // Chart title
            // title: ChartTitle(text: '시간별 기온'),
            // Enable tooltip
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <LineSeries<forecastData, String>>[
              LineSeries<forecastData, String>(
                  dataSource: <forecastData>[
                    forecastData(
                        "${DateTime.parse(weather.date.toString()).hour}시",
                        WeatherData().extractTemperature(
                            weather.temperature.toString())),
                    forecastData(
                        "${DateTime.parse(forecasts[0].date.toString()).hour}시",
                        WeatherData().extractTemperature(
                            forecasts[0].temperature.toString())),
                    forecastData(
                        "${DateTime.parse(forecasts[1].date.toString()).hour}시",
                        WeatherData().extractTemperature(
                            forecasts[1].temperature.toString())),
                    forecastData(
                        "${DateTime.parse(forecasts[2].date.toString()).hour}시",
                        WeatherData().extractTemperature(
                            forecasts[2].temperature.toString())),
                    forecastData(
                        "${DateTime.parse(forecasts[3].date.toString()).hour}시",
                        WeatherData().extractTemperature(
                            forecasts[3].temperature.toString())),
                    forecastData(
                        "${DateTime.parse(forecasts[4].date.toString()).hour}시",
                        WeatherData().extractTemperature(
                            forecasts[4].temperature.toString())),
                  ],
                  xValueMapper: (forecastData data, _) => data.time,
                  yValueMapper: (forecastData data, _) => data.temp,
                  markerSettings: MarkerSettings(isVisible: true),
                  // Enable data label
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                  ))
            ]),
        Padding(
          padding: EdgeInsets.only(top: 45),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              WeatherData().weatherIcon(weather, weather, size.width * 0.08),
              WeatherData().weatherIcon(weather, forecasts[0], size.width * 0.08),
              WeatherData().weatherIcon(weather, forecasts[1], size.width * 0.08),
              WeatherData().weatherIcon(weather, forecasts[2], size.width * 0.08),
              WeatherData().weatherIcon(weather, forecasts[3], size.width * 0.08),
              WeatherData().weatherIcon(weather, forecasts[4], size.width * 0.08),
            ],
          ),
        ),
      ],
    );
  }


  Widget codiRecommend(Size size) {
    print('img??: $_downloadURL');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image(
            width: size.width * 0.47,
            image: NetworkImage(_downloadURL)),
        Image(
            width: size.width * 0.47,
            image: NetworkImage(_downloadURL2)),
      ],
    );
  }


  Widget detailWeatherInformation(int feelLike) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              children: <Widget>[
                // Padding(
                //   padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                //   child: Image(
                //     image: WeatherData().feelLikeIcon(weather),
                //     height: 40,
                //   ),
                // ),
                SizedBox(
                  height: 13,
                ),
                Text("체감온도"),
                SizedBox(
                  height: 7,
                ),
                WeatherData().feelLikeTempLevel(weather),
                SizedBox(
                  height: 7,
                ),
                Text("$feelLike°"),
              ],
            ),
            Column(
              children: <Widget>[
                // Padding(
                //   padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                //   child: Image(
                //     image: WeatherData().humidityIcon(weather.humidity),
                //     height: 40,
                //   ),
                // ),
                SizedBox(
                  height: 13,
                ),
                Text("습도"),
                SizedBox(
                  height: 7,
                ),
                WeatherData().humidityLevel(weather),
                SizedBox(
                  height: 7,
                ),
                Text("${weather.humidity}%"),
              ],
            ),
            Column(
              children: <Widget>[
                // Padding(
                //   padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                //   child: Image(
                //     image: AssetImage('assets/weather/UV.png'),
                //     height: 40,
                //   ),
                // ),
                SizedBox(
                  height: 13,
                ),
                Text("자외선"),
                SizedBox(
                  height: 7,
                ),
                // uvLevel,
                SizedBox(
                  height: 7,
                ),
                // Text("${uvData}"),
              ],
            ),
            Column(
              children: <Widget>[
                // Padding(
                //   padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                //   child: Image(
                //     image: DustData().DustIcon(dustData),
                //     height: 40,
                //   ),
                // ),
                SizedBox(
                  height: 13,
                ),
                Text("미세먼지"),
                SizedBox(
                  height: 7,
                ),
                dustLevel,
                SizedBox(
                  height: 7,
                ),
                Text("${dustData}"),
              ],
            ),
          ],
        ),
        SizedBox(
          height: 15,
        ),
      ],
    );
  }


  Widget livingIndexInformation(int feelLike) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Column(
          children: <Widget>[
            SizedBox(
              height: 15,
            ),
            Icon(
              Icons.sick_outlined,
              size: 40,
            ),
            Text("$feelLike°"),
            SizedBox(
              height: 15,
            ),
            Text("감기"),
            Text(""),
          ],
        ),
        Column(
          children: <Widget>[
            SizedBox(
              height: 15,
            ),
            Icon(
              Icons.flare_outlined,
              size: 40,
            ),
            Text("${weather.humidity}%"),
            SizedBox(
              height: 15,
            ),
            Text("자외선"),
            Text(""),
          ],
        ),
        Column(
          children: <Widget>[
            SizedBox(
              height: 15,
            ),
            Icon(
              Icons.flag_outlined,
              size: 40,
            ),
            Text("${weather.windSpeed}m/s"),
            SizedBox(
              height: 15,
            ),
            Text("풍속"),
            Text(""),
          ],
        ),
        Column(
          children: <Widget>[
            SizedBox(
              height: 15,
            ),
            Icon(
              Icons.flag_outlined,
              size: 40,
            ),
            Text("${weather.windSpeed}m/s"),
            SizedBox(
              height: 15,
            ),
            Text("풍속"),
            Text(""),
          ],
        ),
      ],
    );
  }


  subTitle(String text, Size size) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          size.width * 0.0426, 8, size.width * 0.0426, 8
      ),
      child: Text(
        "$text",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }


  //   else if((weatherData.weatherConditionCode < 600) || (weatherData.weatherConditionCode == 804)) {
  //     return Image(
  //       image: AssetImage("assets/weather/cloudy.png"),
  //       width: width,
  //       fit: BoxFit.scaleDown,
  //     );
  //   } else if (weatherData.weatherConditionCode == 801) {
  //       if((weather.sunrise.isBefore(weatherData.date)) || (weather.sunset.isAfter(weatherData.date))) {
  //         return Image(
  //           image: AssetImage("assets/weather/few_clouds_night.png"),
  //           width: width,
  //           fit: BoxFit.scaleDown,
  //         );
  //       } else {
  //         return Image(
  //           image: AssetImage("assets/weather/few_clouds.png"),
  //           width: width,
  //           fit: BoxFit.scaleDown,
  //         );
  //       }
  //   } else if ((weather.weatherConditionCode == 802) || (weather.weatherConditionCode == 803)) {
  //     if((weather.sunrise.isBefore(weatherData.date)) || (weather.sunset.isAfter(weatherData.date))) {
  //       return Image(
  //         image: AssetImage("assets/weather/broken_clouds_night.png"),
  //         width: width,
  //         fit: BoxFit.scaleDown,
  //       );
  //     } else {
  //       return Image(
  //         image: AssetImage("assets/weather/broken_clouds.png"),
  //         width: width,
  //         fit: BoxFit.scaleDown,
  //       );
  //     }
  //   } else if((weather.sunrise.isBefore(weatherData.date)) || (weather.sunset.isAfter(weatherData.date))) {
  //     return Image(
  //       image: AssetImage("assets/weather/moon.png"),
  //       width: width,
  //       fit: BoxFit.scaleDown,
  //     );
  //   } else {
  //     return Image(
  //       image: AssetImage("assets/weather/sunny.png"),
  //       width: width,
  //       fit: BoxFit.scaleDown,
  //     );
  //   }
  //   return weather.weatherMain == 'Rain'
  //       ? Image(
  //           image: AssetImage("assets/weather/rain.png"),
  //           width: width,
  //           fit: BoxFit.scaleDown,
  //         )
  //       : weather.weatherMain == 'Snow'
  //           ? Image(
  //               image: AssetImage("assets/weather/snow.png"),
  //               width: width,
  //               fit: BoxFit.scaleDown,
  //             )
  //           : weather.weatherConditionCode < 600
  //               ? Image(
  //                   image: AssetImage("assets/weather/cloudy.png"),
  //                   width: width,
  //                   fit: BoxFit.scaleDown,
  //                 )
  //               : ((18 < DateTime.parse(weather.date.toString()).hour) || (DateTime.parse(weather.date.toString()).hour < 8))
  //                   ? Image(
  //                       image: AssetImage("assets/weather/moon.png"),
  //                       width: width,
  //                       fit: BoxFit.scaleDown,
  //                     )
  //                   : Image(
  //                       image: AssetImage("assets/weather/sunny.png"),
  //                       width: width,
  //                       fit: BoxFit.scaleDown,
  //                     );
  // }
}

class forecastData {
  forecastData(this.time, this.temp);

  final String time;
  final int temp;
}
