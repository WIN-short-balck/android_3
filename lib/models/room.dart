import 'package:flutter/material.dart';

class Room {
   int id;
   String name;
   String status;
   String image;
   String loaiphong;

  Room({
    // required this.id,
    required this.id,
    required this.name,
    required this.status,
    required this.image,
    required this.loaiphong
  });

  roomMap(){
    var mapping = Map<String, dynamic>();
    // mapping['id'] = id;
    mapping['name'] = name;
    mapping['status'] = status;
    mapping['image'] = image;
    mapping['loaiphong'] = loaiphong;
    return mapping;
  }
}
