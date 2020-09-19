import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_current_loc/helper/full-map.dart';
import 'package:get_current_loc/helper/marker_type_model.dart';
import 'package:get_current_loc/helper/my_icon_logo.dart';
import 'package:get_current_loc/helper/my_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
//import 'package:account_manager_plugin/account_manager_plugin.dart';
import 'helper/db_helper.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:fluttericon/maki_icons.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracker',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Wanderer'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static bool _isSwitched = false;
  Switch mySwitch = new Switch(value: _isSwitched, onChanged: null);
  //Position _currentPosition;
  static const String ACCESS_TOKEN =
      "pk.eyJ1IjoiYXlpLXRpdG8iLCJhIjoiY2tkZmM1b2J1MGYxaDMxcGYyZTVlM3V4NyJ9.iYXH2MCF34_5Ec0BNcPQfA";
  File _image;
  final picker = ImagePicker();
  var _txtLat = TextEditingController();
  var _txtLong = TextEditingController();
  var _txtName = TextEditingController();
  var _txtAddress = TextEditingController();

  var _ldLatBak1;
  var _ldLngBak1;
  MapboxMapController controller;
  MyLocationTrackingMode _myLocationTrackingMode =
      MyLocationTrackingMode.Tracking;
  int _symbolCount = 0;
  Symbol _selectedSymbol;
  String lcMarkerType;
  LatLng center = const LatLng(-0.934921, 114.8897499);
  final dbHelper = DatabaseHelper.instance;
  final listMarkerTypeModel = new List<MarkerTypeModel>();
  var _iconMarkers1 = [
      'Mosque',
      'Church',
      'Temple',
      'Restaurant',
      'Hotel',
      'Hospital',
      'Airport',
      'Port',
      'Railroad',
      'Bus Station',
      'Building',
      'Police',
      'Bank',
      'Atm',
      'Gas Station',
      'Park',
      'Zoo',
      'Museum'
    ];
  final iconMarkers = const <Widget>[
    const Icon(Maki.religious_islam, color: Colors.blue,),
    const Icon(Maki.religious_christian, color: Colors.blue,),
    const Icon(Maki.religious_budhist, color: Colors.blue,),
    const Icon(Maki.restaurant, color: Colors.blue,),
    const Icon(Maki.lodging, color: Colors.blue,),
    const Icon(Maki.hospital, color: Colors.blue,)
  ];

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      _image = File(pickedFile.path);
    });
  }

  void _onClicked(bool value) {
    print(_isSwitched); // prints false the first time and true for the rest
    setState(() {
      _isSwitched = value;
    });
    print(_isSwitched); // Always prints true
  }

  @override
  Widget build(BuildContext context) {
    MapboxMap mapboxMap = MapboxMap(
      accessToken: ACCESS_TOKEN,
      onMapCreated: onMapCreated,
      onStyleLoadedCallback: () => onStyleLoaded(controller),
      initialCameraPosition: CameraPosition(
        target: center,
        zoom: 15.0,
      ),
      trackCameraPosition: true,
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
        Factory<OneSequenceGestureRecognizer>(
          () => EagerGestureRecognizer(),
        ),
      ].toSet(),
      styleString: _isSwitched
          ? MapboxStyles.SATELLITE_STREETS
          : MapboxStyles.MAPBOX_STREETS,
      onMapLongClick: (point, latLng) async {
        print(
            "Map click: ${point.x},${point.y}   ${latLng.latitude}/${latLng.longitude}");
        setState(() {
          _ldLatBak1 = _txtLat.text;
          _ldLngBak1 = _txtLong.text;
          //this.setMarker();
          _txtLat.text = latLng.latitude.toString();
          _txtLong.text = latLng.longitude.toString();
        });
        controller.addSymbol(
          SymbolOptions(
            geometry: LatLng(
              latLng.latitude,
              latLng.longitude,
            ),
            iconImage: "religious-muslim-15",
          ),
        );
      },
      onCameraTrackingDismissed: () {
        this.setState(() {
          _myLocationTrackingMode = MyLocationTrackingMode.None;
        });
      },
    );
    List<Widget> widgetList = [];
    Switch myWidget = new Switch(value: _isSwitched, onChanged: _onClicked);
    widgetList.add(myWidget);

    return WillPopScope(
      onWillPop: () => _onBackPressed(),
      child: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
          leading: Icon(MyIconLogo.antenna, color: Colors.white, size: 28.0),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Icon(MyIconLogo.backpacker_2,
                  color: Colors.grey[800], size: 36.0),
            ),
          ],
        ),
        body: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 5.0, right: 5.0, top: 5),
              child: ExpansionTile(
                title: Text('View Map'),
                initiallyExpanded: true,
                children: <Widget>[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              _isSwitched
                                  ? Text("Satellite")
                                  : Text("Mapbox Street"),
                              myWidget,
                            ],
                          ),
                          Center(
                            child: SizedBox(
                              width: 374.0,
                              height: 350.0,
                              child: mapboxMap,
                            ),
                          ),
                          FlatButton(
                            child: const Text('Remove Marker'),
                            onPressed: (_selectedSymbol == null)
                                ? null
                                : _removeMarker,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5.0, right: 5.0, top: 5),
              child: ExpansionTile(
                title: Text('View Image'),
                backgroundColor: Colors.grey[200],
                children: <Widget>[
                  Container(
                    height: 374,
                    width: 374,
                    padding: EdgeInsets.only(left: 5, right: 5),
                    child: Center(
                      heightFactor: .75,
                      widthFactor: .75,
                      child: _image == null
                          ? Text('No image selected.')
                          : Image.file(
                              _image,
                              fit: BoxFit.fitHeight,
                            ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5.0, right: 5.0, top: 5),
              child: ExpansionTile(
                title: Text('Additional Info'),
                backgroundColor: Colors.grey[200],
                children: <Widget>[
                  Container(
                    height: 50,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 5.0, left: 20.0, right: 20.0),
                      child: new TextField(
                        autofocus: false,
                        textAlignVertical: TextAlignVertical(y: 1),
                        controller: _txtName,
                        decoration: new InputDecoration(
                          hintText: "Name",
                          labelText: "Name",
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(5.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 5.0, left: 20.0, right: 20.0),
                      child: new TextField(
                        autofocus: false,
                        textAlignVertical: TextAlignVertical(y: 1),
                        controller: _txtAddress,
                        decoration: new InputDecoration(
                          hintText: "Address",
                          labelText: "Address",
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(5.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 50.0,
              child: Padding(
                padding: const EdgeInsets.only(
                          top: 5.0, bottom: 0, left: 20.0, right: 20.0),
                child: DropdownSearch<MarkerTypeModel>(
                  showSelectedItem: true,
                  compareFn: (MarkerTypeModel i, MarkerTypeModel s) => i.isEqual(s),
                  label: "Marker",
                  showSearchBox: true,
                  showClearButton: false,
                  autoFocusSearchBox: true,
                  onFind: (String filter) async {
                    print(' $filter');
                    return listMarkerTypeModel;
                  },
                  onChanged: (MarkerTypeModel data) {
                    print(data);
                    print(data.avatar);
                  },
                  dropdownBuilder: _customDropDownMarker,
                ),
              ),
            ),
            Container(
              height: 50,
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 5.0, left: 20.0, right: 20.0),
                child: new TextField(
                  autofocus: false,
                  textAlignVertical: TextAlignVertical(y: 1),
                  controller: _txtLat,
                  decoration: new InputDecoration(
                    hintText: "Latitude",
                    labelText: "Latitude",
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 50,
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 5.0, left: 20.0, right: 20.0),
                child: new TextField(
                  autofocus: false,
                  textAlignVertical: TextAlignVertical(y: 1),
                  controller: _txtLong,
                  decoration: new InputDecoration(
                    hintText: "Longitude",
                    labelText: "Longitude",
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10.0,
                    right: 10.0,
                    top: 5.0,
                    bottom: 5.0,
                  ),
                  child: Container(
                    height: 80,
                    width: 128,
                    child: OutlineButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      borderSide: BorderSide(color: Colors.grey[500]),
                      child: Stack(
                        children: <Widget>[
                          Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 8.0, bottom: 5.0),
                                child: Icon(
                                  MyIcons.my_location,
                                  size: 32,
                                  color: Colors.blue,
                                ),
                              )),
                          Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 5.0, bottom: 5),
                                child: Text(
                                  "Get Current Location",
                                  textAlign: TextAlign.center,
                                ),
                              ))
                        ],
                      ),
                      onPressed: () async {
                        bool _isLocationEnabled =
                            await Geolocator().isLocationServiceEnabled();

                        if (_isLocationEnabled) {
                          final Geolocator geolocator = Geolocator()
                            ..forceAndroidLocationManager;

                          Position pos = await geolocator.getCurrentPosition(
                              desiredAccuracy: LocationAccuracy.high);

                          var latPos = pos.latitude;

                          var longPos = pos.longitude;

                          print('Position $latPos, $longPos');

                          setState(() {
                            _txtLat.text = latPos.toString();
                            _txtLong.text = longPos.toString();
                            center = LatLng(pos.latitude, pos.longitude);
                            setMarker(controller);
                          });
                          //_addLocation(pos);
                        }
                      },
                    ),
                  ),
                ),
                Container(
                  height: 80,
                  width: 128,
                  child: OutlineButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    borderSide: BorderSide(color: Colors.grey[500]),
                    child: Stack(
                      children: <Widget>[
                        Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 5),
                              child: Icon(
                                MyIcons.add_a_photo,
                                size: 32,
                                color: Colors.blue,
                              ),
                            )),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 5.0, bottom: 5),
                              child: Text(
                                "Take Object Picture",
                                textAlign: TextAlign.center,
                              ),
                            ))
                      ],
                    ),
                    onPressed: () {
                      print('bangsat');

                      getImage();
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 5.0, bottom: 5.0),
                  child: Container(
                    height: 80,
                    width: 128,
                    child: OutlineButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      borderSide: BorderSide(color: Colors.grey[500]),
                      child: Stack(
                        children: <Widget>[
                          Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 8.0, bottom: 2.5),
                                child: Icon(
                                  Icons.save,
                                  size: 32,
                                  color: Colors.blue,
                                ),
                              )),
                          Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 5.0, bottom: 5),
                                child: Text(
                                  "Save Current Location",
                                  textAlign: TextAlign.center,
                                ),
                              ))
                        ],
                      ),
                      onPressed: () async {
                        _insert();
                      },
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 5.0, right: 5.0, bottom: 5.0),
                  child: Container(
                    height: 80,
                    width: 128,
                    child: OutlineButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      borderSide: BorderSide(color: Colors.grey[500]),
                      child: Stack(
                        children: <Widget>[
                          Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 8.0, bottom: 5),
                                child: Icon(
                                  Icons.backup,
                                  size: 32,
                                  color: Colors.blue,
                                ),
                              )),
                          Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 5.0, bottom: 5),
                                child: Text(
                                  "Backup File Survey",
                                  textAlign: TextAlign.center,
                                ),
                              ))
                        ],
                      ),
                      onPressed: () {
                        print('subhanallah');
                        dbHelper.backupDB();
                      },
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 5.0, bottom: 5.0),
                  child: Container(
                    height: 80,
                    width: 128,
                    child: OutlineButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      borderSide: BorderSide(color: Colors.grey[500]),
                      child: Stack(
                        children: <Widget>[
                          Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 8.0, bottom: 2.5),
                                child: Icon(
                                  Icons.map,
                                  size: 32,
                                  color: Colors.blue,
                                ),
                              )),
                          Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 5.0, bottom: 5),
                                child: Text(
                                  "View on Full Map",
                                  textAlign: TextAlign.center,
                                ),
                              ))
                        ],
                      ),
                      onPressed: () async {
                        String _lat = _txtLat.text;
                        String _lng = _txtLong.text;
                        String _nameObject = _txtName.text;
                        String _addressObject = _txtAddress.text;
                        String _imgPath = _image
                            .path; //.toString().trim().substring(6,_image.toString().trim().length-1);
                        print('babi: $_imgPath');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullMap(
                              accessToken: ACCESS_TOKEN,
                              lat: _lat,
                              lng: _lng,
                              nameObject: _nameObject,
                              imgPath: _imgPath,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 5.0, right: 5.0, bottom: 5.0),
                  child: Container(
                    height: 80,
                    width: 128,
                    child: OutlineButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      borderSide: BorderSide(color: Colors.grey[500]),
                      child: Stack(
                        children: <Widget>[
                          Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 8.0, bottom: 5),
                                child: Icon(
                                  MyIconLogo.backpacker_2,
                                  size: 32,
                                  color: Colors.blue,
                                ),
                              )),
                          Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 5.0, bottom: 5),
                                child: Text(
                                  "About Wanderer",
                                  textAlign: TextAlign.center,
                                ),
                              ))
                        ],
                      ),
                      onPressed: () {
                        print('subhanallah');
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  @override
  void initState() {g
    getDeviceLocation();
    var _nameMarker = [
      'Mosque',
      'Church',
      'Temple',
      'Food',
      'Hotel',
      'Hospital',
      'Airport',
      'Port',
      'Railroad',
      'Bus Station',
      'Building',
      'Police',
      'Bank',
      'Atm',
      'Gas Station',
      'Park',
      'Zoo',
      'Museum'
    ];
    var _iconMarker = [iconMarkers[0], iconMarkers[1], iconMarkers[2], iconMarkers[3],iconMarkers[4],iconMarkers[5]];
    var _zoomLevel = [12, 12, 12, 12, 12,10];
    for (int i = 0; i <= 5; i++) {
      var markerTypeModel = new MarkerTypeModel(
        id: i.toString(),
        name: _nameMarker[i],
        avatar: _iconMarker[i],
        zoomLevel: _zoomLevel[i]
      );
      listMarkerTypeModel.add(markerTypeModel);
      print('$listMarkerTypeModel');
    }

    super.initState();
  }

  /// Adds an asset image to the currently displayed style
  Future<void> addImageFromAsset(String name, String assetName) async {
    final ByteData bytes = await rootBundle.load(assetName);
    final Uint8List list = bytes.buffer.asUint8List();
    return controller.addImage(name, list);
  }

  void getDeviceLocation() async {
    bool _isLocationEnabled = await Geolocator().isLocationServiceEnabled();

    if (_isLocationEnabled) {
      final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

      Position pos = await geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      var latPos = pos.latitude;

      var longPos = pos.longitude;

      print('Position $latPos, $longPos');

      setState(() {
        _txtLat.text = latPos.toString();
        _txtLong.text = longPos.toString();
        center = LatLng(pos.latitude, pos.longitude);
      });
    }
  }

  @override
  void dispose() {
    controller?.onSymbolTapped?.remove(_onSymbolTapped);
    super.dispose();
  }

  void _onSymbolTapped(Symbol symbol) {
    if (_selectedSymbol != null) {
      _updateSelectedSymbol(
        const SymbolOptions(iconSize: 1.0),
      );
    }
    setState(() {
      _selectedSymbol = symbol;
      _txtLat.text = center.latitude.toString();
      _txtLong.text = center.longitude.toString();
    });
    _updateSelectedSymbol(
      SymbolOptions(
        iconSize: 1.4,
      ),
    );
  }

  void _updateSelectedSymbol(SymbolOptions changes) {
    controller.updateSymbol(_selectedSymbol, changes);
  }

  void _removeMarker() {
    controller.removeSymbol(_selectedSymbol);
    setState(() {
      _selectedSymbol = null;
      _symbolCount -= 1;
    });
  }

  void onMapCreated(MapboxMapController controller) {
    this.controller = controller;
    controller.onSymbolTapped.add(_onSymbolTapped);
  }

  void onStyleLoaded(MapboxMapController controller) {
    //addImageFromAsset("mosque", "/assets/mosque.png");
    controller.addSymbol(SymbolOptions(
      geometry: LatLng(
        center.latitude,
        center.longitude,
      ),
      iconImage: "marker-15",
    ));
  }

  void setMarker(MapboxMapController controller) {
    controller.addSymbol(SymbolOptions(
      geometry: LatLng(
        center.latitude,
        center.longitude,
      ),
      iconImage: "religious-muslim-15",
      iconAnchor: "bottom",
      iconColor: "blue",
      textField: _txtName.text,
      textAnchor: "top",
      textColor: "red",
      textSize: 10.0,
    ));
    controller.moveCamera(CameraUpdate.newLatLng(
      LatLng(center.latitude, center.longitude),
    ));
  }

  void _insert() async {
    // row to insert
    DateTime now = DateTime.now();
    String _formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: _txtName.text.trim(),
      DatabaseHelper.columnAddress: _txtAddress.text.trim(),
      DatabaseHelper.columnLat: _txtLat.text,
      DatabaseHelper.columnLng: _txtLong.text,
      DatabaseHelper.columnImgPath: _image.toString(),
      DatabaseHelper.columnDateStamp: _formattedDate,
      DatabaseHelper.columnUserID: "User",
    };
    final id = await dbHelper.insert(row);
    print('inserted row id: $id');
  }

  void _query() async {
    final allRows = await dbHelper.queryAllRows();
    print('query all rows:');
    allRows.forEach((row) => print(row));
  }

  void _update() async {
    // row to update
    Map<String, dynamic> row = {
      DatabaseHelper.columnId: 1,
      DatabaseHelper.columnName: 'Mary',
      DatabaseHelper.columnAddress: 32
    };
    final rowsAffected = await dbHelper.update(row);
    print('updated $rowsAffected row(s)');
  }

  void _delete() async {
    // Assuming that the number of rows is the id for the last row.
    final id = await dbHelper.queryRowCount();
    final rowsDeleted = await dbHelper.delete(id);
    print('deleted $rowsDeleted row(s): row $id');
  }

  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit?'),
            actions: <Widget>[
              new GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Text("No"),
              ),
              SizedBox(height: 16),
              new GestureDetector(
                onTap: () => Navigator.of(context).pop(true),
                child: Text("Yes"),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _customDropDownMarker(BuildContext context, MarkerTypeModel item, String itemDesignation) {
    return Container(
      padding: EdgeInsets.only(bottom:2.0),
      child: (item?.avatar == null)
          ? ListTile(
              leading: CircleAvatar(radius: 5.0,),
              title: Padding(
                padding: const EdgeInsets.only(bottom:17.0),
                child: Text("No item selected", textAlign: TextAlign.start),
              ),
            )
          : ListTile(
              leading: item.avatar,
              title: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(item.name),
              ),
              //subtitle: Text(
              //  item.zoomLevel.toString(),
              //),
            ),
    );
  }
}
