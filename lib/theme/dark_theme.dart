import 'package:flutter/material.dart';

ThemeData darktheme = ThemeData(
  brightness: Brightness.dark,


//--------------------------- App bar Dark Theme ---------------------//
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      centerTitle: true,
        shape: Border(bottom: BorderSide(color: Colors.purple,width: 2)),
    ),

//--------------------------- Scaffold Theme ---------------------//

    scaffoldBackgroundColor: Colors.black,

//--------------------------- Bottom bar Theme ---------------------//

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
      
      unselectedIconTheme: IconThemeData(
        color: Colors.white,
      ),
      selectedIconTheme: IconThemeData(
        color: Colors.purple,
      ),
    ),

//--------------------------- Text Theme ---------------------//
   
    textTheme: TextTheme(
      headlineLarge: TextStyle(color: Colors.white, fontSize: 35),
      
    ),

//--------------------------- Drawer Theme ---------------------//


    drawerTheme: DrawerThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),side: BorderSide(color: Colors.black)),      

      backgroundColor: Colors.black,
    ),

//------------------------Icons data---------------------------//

    iconTheme: IconThemeData(
      color: Colors.white,
    ),


//------------------------Divider data---------------------------//


    dividerColor: Colors.white,

//------------------------IDialog theme---------------------------//

    dialogTheme: DialogTheme(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.white)),      

      contentTextStyle: TextStyle(color: Colors.white),
    ),

//------------------------Elevated button---------------------------//

    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: LinearBorder())),

//------------------------Text Button---------------------------//

    textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.white),
            foregroundColor: WidgetStatePropertyAll(Colors.black),
            shape: WidgetStatePropertyAll(LinearBorder()))),

//------------------------Icons Button---------------------------//

    iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(iconColor: WidgetStatePropertyAll(Colors.white))),
  );
    
