import 'package:flutter/material.dart';

class Customer{
  int? id;
  String name;
  String sdt;
  String cccd;
  DateTime? ngayvao;
  DateTime? ngayra;
  int idphong;

  Customer({this.id, required this.name,required this.sdt, required this.cccd
  ,required this.ngayvao, required this.ngayra, required this.idphong});

  customerToMap(){
    var mapping = Map<String,dynamic>();
      mapping['id'] = id;
    mapping['name'] = name;
    mapping['sdt'] = sdt;
    mapping['cccd'] = cccd;
    mapping['ngayvao'] = ngayvao?.toIso8601String();
    mapping['ngayra'] = ngayra?.toIso8601String();
    mapping['id_phong'] = idphong;
    return mapping;
  }


}