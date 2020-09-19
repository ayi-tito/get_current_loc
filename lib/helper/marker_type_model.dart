import 'package:flutter/cupertino.dart';

class MarkerTypeModel {
  final String id;
  final int zoomLevel;
  final String name;
  final Widget avatar;

  MarkerTypeModel({this.id, this.zoomLevel, this.name, this.avatar});

  factory MarkerTypeModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return MarkerTypeModel(
      id: json["id"],
      zoomLevel: json["zoomLevel"] == null ? null : int.parse(json["zoomLevel"]),
      name: json["name"],
      avatar: json["avatar"],
    );
  }

  static List<MarkerTypeModel> fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => MarkerTypeModel.fromJson(item)).toList();
  }

  ///this method will prevent the override of toString
  String markerAsString() {
    return '#${this.id} ${this.name}';
  }

  ///this method will prevent the override of toString
  bool markerFilter(String filter) {
    return this?.zoomLevel?.toString()?.contains(filter);
  }

  ///custom comparing function to check if two users are equal
  bool isEqual(MarkerTypeModel model) {
    return this?.id == model?.id;
  }

  @override
  String toString() => name;
}