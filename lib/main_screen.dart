import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  int batteryLevel = 0;
  int temperatureLevel = 0;
  int speedLevel = 0;




  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    const oneSec = Duration(milliseconds:50);
    Timer.periodic(oneSec, (Timer t) {
      if(speedLevel > 100)  speedLevel = 0;
      if(batteryLevel > 100)  batteryLevel = 0;
      if(temperatureLevel > 100)  temperatureLevel = 0;

      batteryLevel++;
      temperatureLevel++;
      speedLevel++;
      setState(() {

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        Image.asset("assets/background.png",
            width: size.width, height: size.height),
        Container(
          padding: EdgeInsets.symmetric(vertical: 25),
          width: size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "27 Juni 2022 Tuesday",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w200),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    width: 1,
                    height: 16,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    "07:21 AM",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w200),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    width: 1,
                    height: 16,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    "E-INOBUS",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w200),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/ic_top_1.svg",
                    color: Colors.white,
                  ),
                  SvgPicture.asset(
                    "assets/ic_top_2.svg",
                    color: Colors.white,
                  ),
                  SvgPicture.asset(
                    "assets/ic_top_3.svg",
                    color: Colors.white,
                  ),
                  SvgPicture.asset(
                    "assets/ic_top_4.svg",
                    color: Colors.white,
                  ),
                  SvgPicture.asset(
                    "assets/ic_top_5.svg",
                    color: Colors.white,
                  ),
                  SvgPicture.asset(
                    "assets/ic_top_6.svg",
                    color: Colors.white,
                  ),
                  SvgPicture.asset(
                    "assets/ic_top_7.svg",
                    color: Colors.white,
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Text("Ready",
                  style: TextStyle(
                      color: Color(0xff4ebf93),
                      fontSize: 26,
                      fontWeight: FontWeight.w100)),
              SizedBox(
                height: 5,
              ),
              Stack(
                children: [
                  Center(
                      child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Container(
                              height : 120,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("H",style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w100),),
                                      SizedBox(),
                                      Text("C",style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w100),)
                                    ],
                                  ),
                                  SizedBox(width: 10,),
                                  RotatedBox(
                                    quarterTurns: 3,
                                    child: SliderTheme(
                                      data: SliderThemeData(
                                          thumbColor: Color(0xffe97a3a),
                                          activeTrackColor: Color(0xffe97a3a),
                                          inactiveTrackColor: Color(0xffb6c1c4).withAlpha(100),
                                          trackShape: RectangularSliderTrackShape(

                                          ),
                                          overlayShape: SliderComponentShape.noOverlay,
                                          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6)),
                                      child: Slider(
                                        value: 0.5,
                                        onChanged: (val) {

                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  Column(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width: 70,
                                          decoration: BoxDecoration(
                                              border: Border.all(color: Colors.white),
                                              borderRadius: BorderRadius.all(Radius.circular(4))
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 5,),
                                      Expanded(
                                        child: Container(
                                          width: 70,
                                          decoration: BoxDecoration(
                                              border: Border.all(color: Colors.white),
                                              borderRadius: BorderRadius.all(Radius.circular(4))
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 5,),
                                      Expanded(
                                        child: Container(
                                          width: 70,
                                          decoration: BoxDecoration(
                                              border: Border.all(color: Colors.white),
                                              borderRadius: BorderRadius.all(Radius.circular(4))
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 5,),
                                      Expanded(
                                        child: Container(
                                          width: 70,
                                          decoration: BoxDecoration(
                                              border: Border.all(color: Colors.white),
                                              borderRadius: BorderRadius.all(Radius.circular(4))
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 5,),
                                      Expanded(
                                        child: Container(
                                          width: 70,
                                          decoration: BoxDecoration(
                                              border: Border.all(color: Color(0xffe97a3a)),
                                              color: Color(0xffe97a3a),
                                              borderRadius: BorderRadius.all(Radius.circular(4))
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 10,),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [ 
                                      SvgPicture.asset("assets/ic_temp.svg"),
                                      SizedBox(height: 10,),
                                      Text("60",style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.w400),)
                                    ],
                                  ),
                                  SizedBox(height: 5,),
                                  Text("\u2103", style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w200),),
                                  SizedBox(width: 50,)

                                ],
                              ),
                            ),
                          ),
                          Container(
                              width: 205,
                              height: 205,
                              child: SfRadialGauge(
                                  enableLoadingAnimation: true,
                                  axes: <RadialAxis>[
                                RadialAxis(
                                    centerY: 0.63,
                                    minimum: 0,
                                    maximum: 100,
                                    startAngle: 155,
                                    radiusFactor: 1,
                                    endAngle: 25,
                                    ranges: <GaugeRange>[
                                      GaugeRange(
                                          startValue: 0,
                                          endValue: speedLevel.toDouble(),
                                          startWidth: 26,
                                          endWidth: 26,
                                          gradient : SweepGradient(
                                            startAngle: 3 * 3.14 / 2,
                                            endAngle: 7 * 3.14 / 2,
                                            tileMode: TileMode.repeated,
                                            colors: [Color(0xff112d38), Color(0xff279e5a)],
                                          ),
                                        color: Color(0xff279e5a),
                                      ),
                                    ],
                                    pointers: <GaugePointer>[
                                      NeedlePointer(value: 90)
                                    ],
                                    annotations: <GaugeAnnotation>[
                                      GaugeAnnotation(
                                          widget: Container(
                                              child: Text(speedLevel.toString(),
                                                  style: TextStyle(
                                                      fontSize: 30,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w500))),
                                          angle: 90,
                                          positionFactor: 0)
                                    ])
                              ])),
                          Expanded(
                            child: Container(
                              height : 120,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(width: 50,),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("$batteryLevel%",style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.w400),),
                                      Text("Range 540  km",style: TextStyle(fontSize:10, color: Colors.white, fontWeight: FontWeight.w100),)
                                    ],
                                  ),
                                  SizedBox(width: 10,),
                                  Container(
                                    height: 120,
                                    width: 70,
                                    child: Stack(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10,
                                            horizontal: 15
                                          ),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Expanded(
                                                child: Container(
                                                  width: 70,
                                                  decoration: BoxDecoration(
                                                      border: Border.all(color: Color(0xff279e5a)),
                                                      color:  batteryLevel > 80 ? Color(0xff279e5a) : Colors.transparent ,
                                                      borderRadius: BorderRadius.all(Radius.circular(4))
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 5,),
                                              Expanded(
                                                child: Container(
                                                  width: 70,
                                                  decoration: BoxDecoration(
                                                      border: Border.all(color: Color(0xff279e5a)),
                                                      color:  batteryLevel > 60 ? Color(0xff279e5a) : Colors.transparent ,
                                                      borderRadius: BorderRadius.all(Radius.circular(4))
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 5,),
                                              Expanded(
                                                child: Container(
                                                  width: 70,
                                                  decoration: BoxDecoration(
                                                      border: Border.all(color: Color(0xff279e5a)),
                                                      color:  batteryLevel > 40 ? Color(0xff279e5a) : Colors.transparent ,
                                                      borderRadius: BorderRadius.all(Radius.circular(4))
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 5,),
                                              Expanded(
                                                child: Container(
                                                  width: 70,
                                                  decoration: BoxDecoration(
                                                      border: Border.all(color: Color(0xff279e5a)),
                                                      color:  batteryLevel > 20 ? Color(0xff279e5a) : Colors.transparent ,
                                                      borderRadius: BorderRadius.all(Radius.circular(4))
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 5,),
                                              Expanded(
                                                child: Container(
                                                  width: 70,
                                                  decoration: BoxDecoration(
                                                      border: Border.all(color: batteryLevel <= 20 ? Colors.red : Color(0xff279e5a)),
                                                      color: batteryLevel <= 20 ? Colors.red : Color(0xff279e5a),
                                                      borderRadius: BorderRadius.all(Radius.circular(4))
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Center(child: Image.asset("assets/battery.png", height: 150, fit: BoxFit.fill,)),
                                      ],
                                    )
                                  ),
                                  SizedBox(width: 10,),
                                  RotatedBox(
                                    quarterTurns: 3,
                                    child: SliderTheme(
                                      data: SliderThemeData(
                                          thumbColor: Color(0xff279e5a),
                                          activeTrackColor: Color(0xff279e5a),
                                          inactiveTrackColor: Color(0xffb6c1c4).withAlpha(100),
                                          trackShape: RectangularSliderTrackShape(

                                          ),
                                          overlayShape: SliderComponentShape.noOverlay,
                                          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6)),
                                      child: Slider(
                                        value: 0.5,
                                        onChanged: (val) {

                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("F",style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w100),),
                                      SizedBox(),
                                      Text("E",style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w100),)
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
                  Center(
                      child: SvgPicture.asset(
                    "assets/speedo_1.svg",
                    width: 250,
                    height: 250,
                  )),
                  Positioned.fill(
                    child: Align(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                child: Stack(
                                  children: [
                                    Image.asset("assets/ic_transmission.png", width: 30, height: 30, fit: BoxFit.fill,),
                                    Center(
                                      child: Text(
                                        "P", style: TextStyle(
                                          fontSize: 22, color: Colors.white,
                                          fontWeight: FontWeight.w200
                                      ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                )
                              ),
                              Container(
                                  width: 30,
                                  height: 30,
                                  child: Stack(
                                    children: [
                                      // Image.asset("assets/ic_transmission.png", width: 30, height: 30, fit: BoxFit.fill,),
                                      Center(
                                        child: Text(
                                          "R", style: TextStyle(
                                          fontSize: 22, color: Colors.white,
                                            fontWeight: FontWeight.w200
                                        ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  )
                              ),
                              Container(
                                  width: 30,
                                  height: 30,
                                  child: Stack(
                                    children: [
                                      // Image.asset("assets/ic_transmission.png", width: 30, height: 30, fit: BoxFit.fill,),
                                      Center(
                                        child: Text(
                                          "N", style: TextStyle(
                                          fontSize: 22, color: Colors.white,
                                            fontWeight: FontWeight.w200
                                        ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  )
                              ),
                              Container(
                                  width: 30,
                                  height: 30,
                                  child: Stack(
                                    children: [
                                      // Image.asset("assets/ic_transmission.png", width: 30, height: 30, fit: BoxFit.fill,),
                                      Center(
                                        child: Text(
                                          "D", style: TextStyle(
                                          fontSize: 22, color: Colors.white,
                                          fontWeight: FontWeight.w200
                                        ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  )
                              ),
                            ],
                          ),
                          SizedBox(height: 15,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "ODO", style: TextStyle(
                                  fontSize: 12, color: Colors.white,
                                  fontWeight: FontWeight.w200
                              ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(width: 10,),
                              Text(
                                "007654", style: TextStyle(
                                  fontSize: 16, color: Colors.white,
                                  fontWeight: FontWeight.w300
                              ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(width: 10,),
                              Text(
                                "km", style: TextStyle(
                                  fontSize: 12, color: Colors.white,
                                  fontWeight: FontWeight.w200
                              ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ]),
    );
  }
}
