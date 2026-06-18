import 'package:flutter/material.dart';

class DrawingModel {
  String name;
  String data;
  String ownerId;
  bool isPublic;
  List<DrawingModel> children;

  DrawingModel({
    required this.name,
    required this.data,
    this.ownerId = '',
    this.isPublic = false,
    this.children = const [],
  });

  DrawingModel copy() {
    return DrawingModel(
      name: name,
      data: data,
      ownerId: ownerId,
      isPublic: isPublic,
      children: children,
    );
  }

  Map toJson() {
    return {
      'name': name,
      'data': data,
      'ownerId': ownerId,
      'isPublic': isPublic,
      'children': children,
    };
  }

  factory DrawingModel.fromJson(Map json) {
    return DrawingModel(
      name: json['name'],
      data: json['data'],
      ownerId: json['ownerId'],
      isPublic: json['isPublic'],
      children: [],
    );
  }

  Widget buildPreview(BuildContext context) {
    return Container(
      width: 200,
      height: 150,
      color: Colors.grey[300],
      child: Center(
        child: Text(name),
      ),
    );
  }
}
