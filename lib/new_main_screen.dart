import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speedo/map_view_screen.dart';
import 'package:speedo/progress_loading.dart';
import 'package:speedo/screen_utils.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import 'condition.dart';
import 'my_snackbar.dart';

class NewMainScreen extends StatefulWidget {
  const NewMainScreen({Key? key}) : super(key: key);

  @override
  State<NewMainScreen> createState() => _NewMainScreenState();
}

class _NewMainScreenState extends State<NewMainScreen> {

  Map<int, String>? dataFromController;

  BluetoothConnection? connection;
  void connectBT(String mac) async{
    print("gilang $mac");
    try {
      connection = await BluetoothConnection.toAddress(mac);
      connection?.input?.listen((Uint8List data) async {
        String contain = ascii.decode(data);

        final split = contain.split(',');
        final Map<int, String> values = {
          for (int i = 0; i < split.length; i++)
            i: split[i]
        };

        print("=======================");
        print(contain);
        print("=======================");

        setState(() {
          dataFromController = values;
          isConnecting = false;
        });
      }).onDone(() {
        print('Disconnected by remote request');
      });
    }
    catch (exception) {
      setState(() {
        isConnecting = false;
      });
      MySnackbar(context).errorSnackbar("Gagal terkoneksi ke HC-05 : ${exception}");
      print('Cannot connect, exception occured');

      _displayTextInputDialog(context);
    }
  }
  LocationData? currentLocation;
  void getLocations(){
    Location location = Location();
    location.getLocation().then((value) {
      currentLocation = value;
      print("location : $value");
    } );

    location.onLocationChanged.listen((event) {
      currentLocation = event;
      print("location : ${event.latitude}  ${event.longitude}");
      setState(() {});
    });
  }

  Widget _getSpeedGauge() {
    return SfRadialGauge(
        title: GaugeTitle(
            text: '',
            textStyle:
                const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
        axes: <RadialAxis>[
          RadialAxis(minimum: 0, maximum: 100, ranges: <GaugeRange>[
            GaugeRange(
                startValue: 0,
                endValue: 80,
                color: Color(0xffDDE1EC),
                startWidth: 10,
                endWidth: 10),
            GaugeRange(
                startValue: 80,
                endValue: 100,
                color: Color(0xff798FFF),
                startWidth: 10,
                endWidth: 10),
          ], pointers: <GaugePointer>[
            NeedlePointer(value: double.tryParse(dataFromController?[0] ?? "0") ?? 0.0 )
          ], annotations: <GaugeAnnotation>[
            GaugeAnnotation(
                widget: Container(
                    child: Text("${dataFromController?[0]}",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold))),
                angle: 90,
                positionFactor: 0.9)
          ])
        ]);
  }

  Widget _getRpmGauge() {
    return SfRadialGauge(
        title: GaugeTitle(
            text: '',
            textStyle:
            const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
        axes: <RadialAxis>[
          RadialAxis(minimum: 0, maximum: 5000, ranges: <GaugeRange>[
            GaugeRange(
                startValue: 0,
                endValue: 4000,
                color: Color(0xffDDE1EC),
                startWidth: 10,
                endWidth: 10),
            GaugeRange(
                startValue: 4000,
                endValue: 5000,
                color: Color(0xff798FFF),
                startWidth: 10,
                endWidth: 10),
          ], pointers: <GaugePointer>[
            NeedlePointer(value: double.tryParse(dataFromController?[1] ?? "0") ?? 0.0 )
          ], annotations: <GaugeAnnotation>[
            GaugeAnnotation(
                widget: Container(
                    child: Text("${dataFromController?[1]}",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold))),
                angle: 90,
                positionFactor: 0.9)
          ])
        ]);
  }

  List<Condition> conditions() {
    return [
      Condition("Engine Load", double.tryParse(dataFromController?[1] ?? "0") ?? 0),
      Condition("Throttle Position", double.tryParse(dataFromController?[2] ?? "0") ?? 0),
      Condition("Heading", currentLocation?.heading  ?? 0),
    ];
  }

  List<Condition> gps() {
    return [
      // Condition("GPS Position", currentLocation?.heading  ?? 0),
      Condition("GPS Speed", currentLocation?.speed  ?? 0),
      Condition("GPS Alt", currentLocation?.altitude  ?? 0),
      Condition("GPS Sat", currentLocation?.satelliteNumber?.toDouble()  ?? 0),
    ];
  }

  Future<String?> _getMacAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var pesantren = prefs.getString("mac_address");
    return pesantren;
  }

  Future<void> saveMacAddress(String macAddress) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("mac_address", macAddress);
  }

  TextEditingController _textFieldController = TextEditingController();
  bool isConnecting = false;

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('HC-05 Mac Address'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _textFieldController,
                  decoration: InputDecoration(hintText: "Ex : 00:20:10:08:1B:00"),
                ),
                isConnecting ? ProgressLoading() : ElevatedButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all<
                          RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(18.0)))),
                  onPressed: () async {
                    setState(() {
                      isConnecting = true;
                    });
                    var macAddress = _textFieldController.text.toString();
                    saveMacAddress(macAddress);
                    connectBT(macAddress);
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Save",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2
                              ?.apply(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).then((value) => isConnecting = false);
  }

  void init() async {
    print("macaddress");
    await Future.delayed(const Duration(milliseconds: 1000));
    var macAddress = await _getMacAddress();
    print("macaddress: $macAddress");
    if(macAddress != null){
      connectBT(macAddress);
    }else{
      _displayTextInputDialog(context);
    }
  }

  @override
  void initState() {
    init();
    getLocations();
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Card(
                        elevation: 10,
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              color: Color(0xffF8F9FD),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: InkWell(
                                  onTap: (){
                                    _displayTextInputDialog(context);
                                  },
                                  child: Text(
                                    "SPEED",
                                    style: TextStyle(
                                      color: Color(0xff8091C3),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                child: _getSpeedGauge(),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Card(
                        elevation: 10,
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              color: Color(0xffF8F9FD),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  "RPM",
                                  style: TextStyle(
                                    color: Color(0xff8091C3),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                child: _getRpmGauge(),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Column(
                        children: [
                          Text(
                            "Condition",
                            style: TextStyle(
                                color: Color(0xff798FFF),
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                          Column(
                            children: conditions()
                                .map(
                                  (e) => Container(
                                    width: double.infinity,
                                    child: Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 10,
                                              width: 10,
                                              decoration: BoxDecoration(
                                                  color: Color(0xffACB2E5),
                                                  borderRadius:
                                                      BorderRadius.circular(100)
                                                  //more than 50% of width makes circle
                                                  ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(child: Text(e.title)),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(e.value.toString()),
                                            SizedBox(
                                              width: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          )
                        ],
                      )),
                      Expanded(
                          child: Column(
                        children: [
                          Text(
                            "GPS",
                            style: TextStyle(
                                color: Color(0xff798FFF),
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                          Column(
                            children: gps()
                                .map(
                                  (e) => Container(
                                    width: double.infinity,
                                    child: Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 10,
                                              width: 10,
                                              decoration: BoxDecoration(
                                                  color: Color(0xffACB2E5),
                                                  borderRadius:
                                                      BorderRadius.circular(100)
                                                  //more than 50% of width makes circle
                                                  ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(child: Text(e.title)),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(e.value.toString()),
                                            SizedBox(
                                              width: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          )
                        ],
                      )),
                    ],
                  ),
                )),
            Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Card(
                        elevation: 10,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 10),
                              child: Image.asset("assets/battery_1.png"),
                            ),
                            Text("${int.tryParse(dataFromController?[9] ?? "0") ?? 0}%"),
                            SizedBox(
                              height: 10,
                            )
                          ],
                        ),
                      ),
                      Expanded(
                          child: Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Battery Status",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Card(
                            elevation: 10,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.electric_bolt),
                                      Expanded(
                                        child: Text("Voltage"),
                                      ),
                                      Text("${int.tryParse(dataFromController?[10] ?? "0") ?? 0}%")
                                    ],
                                  ),
                                  SizedBox(
                                    height: 6,
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.electrical_services_sharp),
                                      Expanded(
                                        child: Text("State of Charge"),
                                      ),
                                      Text("${int.tryParse(dataFromController?[11] ?? "0") ?? 0}%")
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height:20,
                          ),
                          Row(
                            children: [
                              Card(
                                child: Icon(
                                  Icons.star,
                                  color: Colors.white,
                                ),
                                color: Color(0xff778EEB),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Vehicle Status"),
                                    Text("${dataFromController?[12]}")
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          Row(
                            children: [
                              Card(
                                child: Icon(
                                  Icons.star,
                                  color: Colors.white,
                                ),
                                color: Color(0xff778EEB),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Vehicle Health"),
                                    Text("${dataFromController?[13]}")
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          Row(
                            children: [
                              Card(
                                child: Icon(
                                  Icons.star,
                                  color: Colors.white,
                                ),
                                color: Color(0xff778EEB),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Sensor Health"),
                                    Text("${dataFromController?[14]}")
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          // InkWell(
                          //   onTap: (){
                          //     ScreenUtils(context).navigateTo(MapView());
                          //   },
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.end,
                          //     children: [
                          //       Text("Route Control"),
                          //       Icon(Icons.arrow_forward_ios_sharp)
                          //     ],
                          //   ),
                          // )
                        ],
                      ))
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
