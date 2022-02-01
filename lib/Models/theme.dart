import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemePreDifendTextSize{
  Small,
  Medium,
  Large,
}

enum ThemePreDifendColors{
  white,
  Dark,
  Red,
  Blue,
  Green,
  Yellow,
  Orange
}

class MyTheme with ChangeNotifier{

  late TextTheme text = TextTheme();
  MaterialColor? _selectedMainColor;
  double? _selectedTextSize;

  final appPreDefinedTextSizes = <ThemePreDifendTextSize,double>{
    ThemePreDifendTextSize.Small : 7,
    ThemePreDifendTextSize.Medium : 10,
    ThemePreDifendTextSize.Large : 30, 
  };

  final appPreDefinedColors = {
    ThemePreDifendColors.white : MaterialColor(
      Colors.white.value,
       <int, Color>{
        50: Colors.white54,
        100: Colors.white60,
        200: Colors.white70,
        300: Colors.grey.shade300,
        400: Colors.grey.shade400,
        500: Colors.grey,
        600: Colors.grey.shade600,
        700: Colors.white,
        800: Colors.white,
        900: Colors.white,
      }
    ),
    ThemePreDifendColors.Dark : MaterialColor(
      Colors.black.value,
      const <int, Color>{
        50: Colors.black,
        100: Colors.black,
        200: Colors.black,
        300: Colors.black,
        400: Colors.black,
        500: Colors.black,
        600: Colors.black,
        700: Colors.black,
        800: Colors.black,
        900: Colors.black,
      }
    ),
    ThemePreDifendColors.Red : Colors.red,
    ThemePreDifendColors.Blue : Colors.blue,
    ThemePreDifendColors.Green : Colors.green,
    ThemePreDifendColors.Yellow : Colors.yellow,
    ThemePreDifendColors.Orange : Colors.deepOrange
  };


  void selectTextSize(ThemePreDifendTextSize preDifendTextSize) async {
    final prefs = await SharedPreferences.getInstance();
    _selectedTextSize = appPreDefinedTextSizes[preDifendTextSize]!;
    prefs.setDouble('textSize', _selectedTextSize ?? 20);
    notifyListeners();
  }



  void selectedMainColor(ThemePreDifendColors preDifendColors) async {
    final prefs = await SharedPreferences.getInstance();
    print(appPreDefinedColors[preDifendColors]!.value);
    // MaterialColor(appPreDefinedColors[preDifendColors]!.value,appPreDefinedColors[preDifendColors]!.)
    prefs.setInt('color-value', appPreDefinedColors[preDifendColors]!.value);
    prefs.setInt('color-shade50', appPreDefinedColors[preDifendColors]!.shade50.value);
    prefs.setInt('color-shade100', appPreDefinedColors[preDifendColors]!.shade100.value);
    prefs.setInt('color-shade200', appPreDefinedColors[preDifendColors]!.shade200.value);
    prefs.setInt('color-shade300', appPreDefinedColors[preDifendColors]!.shade300.value);
    prefs.setInt('color-shade400', appPreDefinedColors[preDifendColors]!.shade400.value);
    prefs.setInt('color-shade500', appPreDefinedColors[preDifendColors]!.shade500.value);
    prefs.setInt('color-shade600', appPreDefinedColors[preDifendColors]!.shade600.value);
    prefs.setInt('color-shade700', appPreDefinedColors[preDifendColors]!.shade700.value);
    prefs.setInt('color-shade800', appPreDefinedColors[preDifendColors]!.shade800.value);
    prefs.setInt('color-shade900', appPreDefinedColors[preDifendColors]!.shade900.value);
    _selectedMainColor = appPreDefinedColors[preDifendColors]!;
    notifyListeners();
  }

  Future<void> setTheme() async {
    final prefs= await SharedPreferences.getInstance();
    if(prefs.containsKey('color-value')){
      int value = prefs.getInt('color-value')!;
      final swatch = <int,Color>{
        50 : Color(prefs.getInt('color-shade50')!),
        100 : Color(prefs.getInt('color-shade100')!),
        200 : Color(prefs.getInt('color-shade200')!),
        300 : Color(prefs.getInt('color-shade300')!),
        400 : Color(prefs.getInt('color-shade400')!),
        500 : Color(prefs.getInt('color-shade500')!),
        600 : Color(prefs.getInt('color-shade600')!),
        700 : Color(prefs.getInt('color-shade700')!),
        800 : Color(prefs.getInt('color-shade800')!),
        900 : Color(prefs.getInt('color-shade900')!),
      };
      _selectedMainColor = MaterialColor(value, swatch);
    }else{
      _selectedMainColor = Colors.deepPurple;
    }
    if(prefs.containsKey('textSize') && prefs.getDouble('textSize') != null){
      _selectedTextSize = prefs.getDouble('textSize');
    }else{
      _selectedTextSize = 20;
    }
  }

  ThemeData get getTheme{
    if(_selectedMainColor == null){
      return ThemeData(primarySwatch: Colors.indigo);
    }
    return ThemeData(primarySwatch: _selectedMainColor,textTheme: TextTheme(bodyText2: TextStyle(fontSize: _selectedTextSize)));
  }


}