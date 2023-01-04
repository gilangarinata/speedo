
import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:location/location.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speedo/route_model.dart';
import 'dart:convert';

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  double DISTANCE_RADIUS = 0.1;
  int selectedIndex = 0;
  List<RouteModel> routes = [];

  LocationData? currentLocation;

  void toggleRoutes(){
    if(routes.first.noRute == 1){
      routes.sort((b, a) => a.noRute.compareTo(b.noRute));
      setState(() {});
    }else{
      routes.sort((a, b) => a.noRute.compareTo(b.noRute));
      setState(() {});
    }
  }

  final client = Dio();
  // client.interceptors.add(ApiInterceptors());

  Future<void> setData(String idbus, String asal, String tujuan, int state) async {
    const url = 'http://192.168.1.100/update.php';
    client.interceptors.add(
      PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90),
    );
    try {
      final response = await client.get(url, queryParameters: {
        "idbus" : idbus,
        "asal" : asal,
        "tujuan" : tujuan,
        "state" : state
      });

      if (response.statusCode == 200) {
        print("SEND DATA : request success : 200");
        // return _yourClass_.fromJson(response.data);
      } else {
        print('SEND DATA :  ${response.statusCode} : ${response.data.toString()}');
        // throw response.statusCode;
      }
    } catch (error) {
      print("SEND DATA : $error");
    }
  }

  RouteModel? lastRoute;

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

      var currentRoute = routes.firstWhereOrNull((element) {
        var distance = calculateDistance(element.terminalLat, element.terminalLong, event.latitude, event.longitude);
        if(distance < DISTANCE_RADIUS){
          print("distance : $distance");
          return true;
        }else{
          return false;
        }
      });

      if(currentRoute != null){
        var currentIndex = routes.indexOf(currentRoute);
        carouselController.animateToPage(currentIndex);
        lastRoute = currentRoute;

        var nextIndex = currentIndex + 1;
        var tujuan = "-";
        if(nextIndex < routes.length){
          tujuan = routes[nextIndex].terminal;
        }

        print("nextindex : $nextIndex");

        setData(currentRoute.idBus, currentRoute.terminal, tujuan, 1);

        print("currentIndex : $currentIndex");
        if(currentIndex == routes.length -1 ){
          toggleRoutes();
        }
      }else{
        if(lastRoute != null){
          var currentIndex = routes.indexOf(lastRoute!);

          var nextIndex = currentIndex + 1;
          var tujuan = "-";
          if(nextIndex < routes.length){
            tujuan = routes[nextIndex].terminal;
          }

          print("nextindex : $nextIndex");

          setData(lastRoute!.idBus, lastRoute!.terminal, tujuan, 0);
        }
      }
    });
  }

  String getTextTitle(int index, RouteModel routeModel){
    var text = "";
    var distance = calculateDistance(routeModel.terminalLat, routeModel.terminalLong, currentLocation?.latitude, currentLocation?.longitude);
    if(index == selectedIndex && distance < DISTANCE_RADIUS){
      text = "Tiba di Tujuan :";
    }else if(index == selectedIndex && distance > DISTANCE_RADIUS){
      text = "Dari :";
    }else{
      text = "Menuju :";
    }
    return text;
  }

  bool getHighlighted(int index, RouteModel routeModel){
    var currentRoute = routes.firstWhereOrNull((element) {
      var distance = calculateDistance(element.terminalLat, element.terminalLong, currentLocation?.latitude, currentLocation?.longitude);
      if(distance < DISTANCE_RADIUS){
        print("distance : $distance");
        return true;
      }else{
        return false;
      }
    });
    var highlight;
    if(currentRoute == null){
      if(index == selectedIndex) {
        highlight = false;
      }else{
        print("true2");
        highlight = true;
      }
      return highlight;
    }

    print("check null : ${currentRoute?.terminalLat}   ${currentRoute?.terminalLong}  ${currentLocation?.latitude}   ${currentLocation?.longitude}");

    var distance = calculateDistance(currentRoute?.terminalLat, currentRoute?.terminalLong, currentLocation?.latitude, currentLocation?.longitude);
    if(distance < DISTANCE_RADIUS){
      if(index == selectedIndex) {
        print("true1");
        highlight = true;
      }else{
        highlight = false;
      }
    }else{
      if(index == selectedIndex) {
        highlight = false;
      }else{
        print("true2");
        highlight = true;
      }
    }

    print("highlight $highlight    index $index    selected $selectedIndex    distance  $distance   currentRoute $currentRoute"   );

    return highlight;
  }

  List<Widget> generateItems() {
    return routes.mapIndexed((index, e) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
            visible: index >= selectedIndex,
            child: Text(
                getTextTitle(index, e),
                style: TextStyle(fontSize: 30, color: Colors.white.withOpacity(getHighlighted(index, e) ? 1 : 0.4)))),
        Visibility(
          visible: index >= selectedIndex,
          child: Text(
            e.terminal,
            style: TextStyle(fontSize: 75, color: Colors.white.withOpacity(getHighlighted(index, e) ? 1 : 0.4)),
          ),
        ),
      ],
    )).toList() ??
        [];
  }

  void getRoute() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var student = prefs.getString("ROUTE");
    var objectStudents = List<RouteModel>.from(json.decode(student ?? "").map((x) => RouteModel.fromJson(x)));

    setState(() {
      print(student);
      routes = objectStudents;
    });
  }

  void setRoute(RouteModel route) async {
    var newRoutes = routes;
    newRoutes.add(route);
    var routeObj = List<dynamic>.from((newRoutes).map((x) => x.toJson()));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("ROUTE",jsonEncode(routeObj));
    getRoute();
  }

  void deleteRoute(RouteModel route) async {
    var newRoutes = routes;
    newRoutes.remove(route);
    var routeObj = List<dynamic>.from((newRoutes).map((x) => x.toJson()));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("ROUTE",jsonEncode(routeObj));
    getRoute();
  }

  CarouselController carouselController = CarouselController();

  @override
  void initState() {
    getRoute();
    getLocations();
    routes.sort((a, b) => a.noRute.compareTo(b.noRute));
    setState(() {});
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff26434B),
      body: SafeArea(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Image.asset("assets/line.png"),
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: Stack(
                children: [
                  Align(
                    alignment : Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/lgo.png",width: 50,),
                          SizedBox(width: 10,),
                          Text(
                            "BUS LISTRIK MERAH PUTIH (BLiMP)",
                            style: TextStyle(fontSize: 30, color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      CarouselSlider(
                        carouselController: carouselController,
                        options: CarouselOptions(
                            aspectRatio: 2,
                            enableInfiniteScroll: false,
                            enlargeCenterPage: false,
                            viewportFraction: 0.4,
                            scrollDirection: Axis.vertical,
                            autoPlay: false,
                            enlargeStrategy: CenterPageEnlargeStrategy.scale,
                            onPageChanged: (index, page) {
                              selectedIndex = index;
                              setState(() {});
                            }),
                        items: generateItems(),
                      ),
                      SizedBox(height: 80,)
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Spacer(),
                          InkWell(
                              onTap: () {
                                TextEditingController idController =
                                TextEditingController();
                                TextEditingController passController =
                                TextEditingController();

                                Dialog errorDialog = Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0)),
                                  //this right here
                                  child: Container(
                                    height: 300.0,
                                    width: 300.0,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                          child: Text(
                                            'Masuk',
                                            style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 20),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: TextField(
                                            controller: idController,
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                filled: true,
                                                hintStyle: TextStyle(
                                                    color: Colors.grey[800]),
                                                hintText: "ID Pengguna",
                                                fillColor: Color(0xffECEBEB)),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: TextField(
                                            controller: passController,
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                filled: true,
                                                hintStyle: TextStyle(
                                                    color: Colors.grey[800]),
                                                hintText: "Password",
                                                fillColor: Color(0xffECEBEB)),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.end,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text("Batal"),
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  var id = idController.text
                                                      .toString()
                                                      .trim();
                                                  var pass = passController.text
                                                      .toString()
                                                      .trim();
                                                  if (id == "admin" &&
                                                      pass == "admin") {
                                                    Navigator.pop(context);
                                                    showList();
                                                  } else {
                                                    Navigator.pop(context);
                                                    var snackBar = SnackBar(
                                                        content: Text(
                                                            'ID pengguna atau password salah'));
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(snackBar);
                                                  }
                                                },
                                                child: Text('Masuk'),
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        12), // <-- Radius
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) => errorDialog);
                              },
                              child: Icon(
                                Icons.settings,
                                color: Colors.white,
                                size: 60,
                              )),
                          SizedBox(
                            width: 20,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "Nomor Bus :      ",
                                style: TextStyle(fontSize: 30, color: Colors.white),
                              ),
                              Text(
                                "N351",
                                style: TextStyle(fontSize: 60, color: Colors.white),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  List<Widget> generateList(){
    return routes.map((e) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(e.noRute.toString(),
              style: TextStyle(color: Colors.black87, fontSize: 20)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('${e.terminal}',
                  style: TextStyle(color: Colors.black87, fontSize: 20)),
              SizedBox(height: 10,),
              Text('(${e.terminalLat},${e.terminalLong})',
                  style: TextStyle(color: Colors.black87, fontSize: 16)),
            ],
          ),

          Text('${e.idBus}',
              style: TextStyle(color: Colors.black87, fontSize: 20)),
          IconButton(onPressed: (){

            // set up the buttons
            Widget cancelButton = TextButton(
              child: Text("Batal"),
              onPressed:  () {},
            );
            Widget continueButton = TextButton(
              child: Text("Hapus"),
              onPressed:  () {
                deleteRoute(e);
                Navigator.pop(context);
                Navigator.pop(listContext!);
                showList();
              },
            );

            // set up the AlertDialog
            AlertDialog alert = AlertDialog(
              title: Text("Peringatan!"),
              content: Text("Apakah anda yakin ingin menghapus terminal ${e.terminal}?"),
              actions: [
                cancelButton,
                continueButton,
              ],
            );

            // show the dialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return alert;
              },
            );
          }, icon: Icon(Icons.restore_from_trash_rounded))
        ],
      ),
    ),).toList();
  }

  void showList() {
    Dialog errorDialog = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      //this right here
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: [
                Spacer(),
                IconButton(onPressed: (){
                  Navigator.pop(context);
                }, icon: Icon(Icons.close))
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('No Rute',
                      style: TextStyle(color: Colors.black87, fontSize: 20)),
                  Text('Terminal     ',
                      style: TextStyle(color: Colors.black87, fontSize: 20)),
                  Text('  ID Bus  ',
                      style: TextStyle(color: Colors.black87, fontSize: 20)),
                  Text('       ',
                      style: TextStyle(color: Colors.black87, fontSize: 20)),
                ],
              ),
            ),
            Column(
              children: generateList(),
            ),
            SizedBox(height: 20,),
            Row(
              children: [
                Spacer(),
                ElevatedButton(
                  onPressed: () {
                    showEditRute();
                  },
                  child: Text('Tambah Rute'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                          12), // <-- Radius
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20,),
          ],
        ),
      ),
    );
    showDialog(
        context: context, builder: (BuildContext context) {
      listContext = context;
      return errorDialog;
    });
  }

  BuildContext? editContext;
  BuildContext? listContext;

  void showEditRute() {
    var idBusController = TextEditingController();
    var noRuteController = TextEditingController();
    var terminalRuteController = TextEditingController();
    var latitudeController = TextEditingController();
    var longitudeController = TextEditingController();
    Dialog errorDialog = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      //this right here
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: [
                Spacer(),
                IconButton(onPressed: (){
                  Navigator.pop(context);
                }, icon: Icon(Icons.close))
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Tambah Rute',
                      style: TextStyle(color: Colors.black87, fontSize: 20)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20),
              child: TextField(
                controller: idBusController,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    filled: true,
                    hintStyle: TextStyle(
                        color: Colors.grey[800]),
                    hintText: "ID Bus",
                    fillColor: Color(0xffECEBEB)),
              ),
            ),
            // SizedBox(height: 20,),
            // Padding(
            //   padding: const EdgeInsets.symmetric(
            //       horizontal: 20),
            //   child: TextField(
            //     keyboardType: TextInputType.numberWithOptions(
            //       decimal: false
            //     ),
            //     controller: noRuteController,
            //     decoration: InputDecoration(
            //         border: InputBorder.none,
            //         filled: true,
            //         hintStyle: TextStyle(
            //             color: Colors.grey[800]),
            //         hintText: "No Rute",
            //         fillColor: Color(0xffECEBEB)),
            //   ),
            // ),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20),
              child: TextField(
                controller: terminalRuteController,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    filled: true,
                    hintStyle: TextStyle(
                        color: Colors.grey[800]),
                    hintText: "Terminal",
                    fillColor: Color(0xffECEBEB)),
              ),
            ),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20),
              child: Row(
                children: [
                  Image.asset("assets/arrow_route.png", width: 20,height: 20, fit: BoxFit.fill,),
                  Expanded(
                    child: TextField(
                      controller: latitudeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          filled: true,
                          hintStyle: TextStyle(
                              color: Colors.grey[800]),
                          hintText: "Latitude",
                          fillColor: Color(0xffECEBEB)),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: TextField(
                      controller: longitudeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          filled: true,
                          hintStyle: TextStyle(
                              color: Colors.grey[800]),
                          hintText: "Longitude",
                          fillColor: Color(0xffECEBEB)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20,),
            Row(
              children: [
                Spacer(),
                ElevatedButton(
                  onPressed: () {
                    var noRute = routes.length + 1;
                    var idBus = idBusController.text.trim();
                    var terminal = terminalRuteController.text.trim();
                    var lat = double.tryParse(latitudeController.text.trim());
                    var long = double.tryParse(longitudeController.text.trim());
                    if(noRute != null && idBus.isNotEmpty && terminal.isNotEmpty && lat != null && long != null){
                      setRoute(RouteModel(terminal: terminal, terminalLat: lat, terminalLong: long, idBus: idBus, noRute: noRute));
                      Navigator.pop(listContext!);
                      Navigator.pop(editContext!);
                      showList();
                    }
                  },
                  child: Text('Simpan'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                          12), // <-- Radius
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20,),
          ],
        ),
      ),
    );

    showDialog(
        context: context, builder: (BuildContext context) {
          editContext = context;
          return errorDialog;
    });
  }

  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }
}
