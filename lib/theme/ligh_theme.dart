import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,

  //------------------------- App Bar theme ---------------------------------//

  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white70,
    foregroundColor: Colors.black,
    centerTitle: true,
    shape: Border(bottom: BorderSide(color: Colors.purple, width: 2)),
  ),
  scaffoldBackgroundColor: Colors.white,

  //------------------------- Bottom Navigation Bar---------------------------------//

  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    unselectedIconTheme: IconThemeData(
      color: Colors.black,
    ),
    selectedIconTheme: IconThemeData(
      color: Colors.purple,
    ),
  ),

  //------------------------- Text Theme of Project---------------------------------//

  textTheme: TextTheme(
    headlineLarge: TextStyle(color: Colors.black, fontSize: 35),
  ),

  //------------------------- Drawer ---------------------------------//

  drawerTheme: DrawerThemeData(
    backgroundColor: Colors.white,
  ),

  //------------------------Icons data---------------------------//

  iconTheme: IconThemeData(
    color: Colors.black,
  ),
// -------------------- Divider -----------------------//

  dividerColor: Colors.black,
  dialogTheme: DialogTheme(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.black)),
    backgroundColor: Colors.white,
    contentTextStyle: TextStyle(color: Colors.black),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black, foregroundColor: Colors.white)),
  textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.black),
          foregroundColor: WidgetStatePropertyAll(Colors.white))),
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(
      iconColor: WidgetStatePropertyAll(Colors.black),
    ),
  ),

  // ---------------------------- Input Fields ------------------------- //

 
);
