import 'package:flutter/material.dart';

class MyMaterialColor extends MaterialColor{

  MyMaterialColor(int primary, Map<int, Color> swatch) : super(primary, swatch);

  Map<String,dynamic> toMap(){    
    return {
      'value' : this.value,
      'swatch' : {
        'shade50' : this.shade50.value,
        'shade100' : this.shade100.value,
        'shade200' : this.shade200.value,
        'shade300' : this.shade300.value,
        'shade400' : this.shade400.value,
        'shade500' : this.shade500.value,
        'shade600' : this.shade600.value,
        'shade700' : this.shade700.value,
        'shade800' : this.shade800.value,
        'shade900' : this.shade900.value,
      }
    };
  }

  // MaterialColor.fromMap(Map<String,dynamic> map){
  //   int value = map['value'];
  //   <int,Color> co= {

  //   }
  //   return MaterialColor(primary, swatch);
  // }
}