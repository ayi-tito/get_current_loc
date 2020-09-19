import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:flushbar/flushbar.dart';

class FullMap extends StatefulWidget {
  final String accessToken;
  final String lat;
  final String lng;
  final String nameObject;
  final String imgPath;
  const FullMap(
      {Key key,
      this.accessToken,
      this.lat,
      this.lng,
      this.nameObject,
      this.imgPath})
      : super(key: key);
  @override
  _FullMapState createState() => _FullMapState();
}

class _FullMapState extends State<FullMap> {
  MapboxMapController mapController;
  int _symbolCount = 0;
  Symbol _selectedSymbol;
  var lat;
  var lng;

  @override
  void dispose() {
    mapController?.onSymbolTapped?.remove(_onSymbolTapped);
    super.dispose();
  }

  void _onSymbolTapped(Symbol symbol) async {
    if (_selectedSymbol != null) {
      _updateSelectedSymbol(
        const SymbolOptions(iconSize: 1.0),
      );
    }
    setState(() {
      _selectedSymbol = symbol;
    });
    _updateSelectedSymbol(
      SymbolOptions(
        iconSize: 1.4,
      ),
    );
    LatLng latLng = await mapController.getSymbolLatLng(_selectedSymbol);
    //Scaffold.of(context).showSnackBar(
    //  SnackBar(
    //    content: Text(latLng.toString()),
    //  ),
    //);
    Flushbar(
      titleText: Text("Marker", style: TextStyle(color: Colors.blue),),
      flushbarStyle: FlushbarStyle.FLOATING,
      backgroundColor: Colors.white24,
      boxShadows: [BoxShadow(color: Colors.white70, offset: Offset(0.0, 2.0), blurRadius: 3.0)],
      margin: EdgeInsets.only(left:80.0, right: 80.0, bottom: 20.0),
      borderRadius: 8,
      messageText: Column(
        children: <Widget>[
          Container(
            child: Text(
              "${widget.nameObject}",
              style: TextStyle(color: Colors.black, fontSize: 11.0),
            ),
          ),
          Container(
            width: 200,
            height: 200,
            child: Image.file(
              File(widget.imgPath),
            ),
          ),
          Container(
            child: Text(
              "Latitude : ${latLng.latitude.toString()}",
              style: TextStyle(color: Colors.black, fontSize: 11.0),
            ),
          ),
          Container(
            child: Text(
              "Longitude : ${latLng.longitude.toString()}",
              style: TextStyle(color: Colors.black, fontSize: 11.0),
            ),
          ),
        ],
      ),
      duration: Duration(seconds: 7),
    )..show(context);
  }

  void _updateSelectedSymbol(SymbolOptions changes) {
    mapController.updateSymbol(_selectedSymbol, changes);
  }

  void _removeMarker() {
    mapController.removeSymbol(_selectedSymbol);
    setState(() {
      _selectedSymbol = null;
      _symbolCount -= 1;
    });
  }

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
    mapController.onSymbolTapped.add(_onSymbolTapped);
    //mapController.onSymbolTapped.add(_showDialog(_context));
  }

  @override
  Widget build(BuildContext context) {
    print('access token : ${widget.accessToken}');
    var _lat = double.parse(widget.lat);
    var _lng = double.parse(widget.lng);
    setState(() {
      lat = _lat;
      lng = _lng;
    });
    print('$_lat, $_lng');
    return Scaffold(
      body: MapboxMap(
        accessToken: widget.accessToken,
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(_lat, _lng),
          zoom: 15.0,
        ),
        trackCameraPosition: true,
        onStyleLoadedCallback: () => onStyleLoaded(mapController),
      ),
    );
  }

  void onStyleLoaded(MapboxMapController controller) {
    //addImageFromAsset("mosque", "/assets/mosque.png");
    print('dlm onStyleLoaded : $lat,$lng');
    print('$mapController.get');
    //Offset currentAnchor = _selectedSymbol.options.iconOffset;
    controller.addSymbol(
      SymbolOptions(
        geometry: LatLng(
          lat,
          lng,
        ),
        iconImage: "religious-muslim-15",
        iconColor: "blue",
        iconAnchor: "bottom",
        textField: widget.nameObject,
        textColor: "red",
        textAnchor: "top",
        textSize: 11.0,
      ),
    );
  }

  void setMarker(MapboxMapController controller) {
    controller.addSymbol(SymbolOptions(
        geometry: LatLng(
          lat,
          lng,
        ),
        iconImage: "religious-muslim-15"));
  }

  void _showDialog(BuildContext context) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(widget.nameObject),
      content: Column(
        children: <Widget>[
          Container(
              child: widget.imgPath != null
                  ? Image.file(
                      File(widget.imgPath),
                    )
                  : Text("no image")),
        ],
      ),
      actions: [
        FlatButton(
          child: Text("Remove"),
          onPressed: () => _removeMarker,
        ),
        FlatButton(
          child: Text("Close"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
