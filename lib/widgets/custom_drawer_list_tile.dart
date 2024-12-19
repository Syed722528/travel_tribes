import 'package:flutter/material.dart';

class CustomDrawerListTile extends StatelessWidget {
  const CustomDrawerListTile({
    this.onTap,
    this.onLongPress,
    required this.title,
    required this.icon,
    super.key,
  });

  final String title;
  final Icon icon;
  final void Function()? onTap;
 final void Function()? onLongPress;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child: ListTile(
        leading: icon,
        title: Text(title),
      ),
    );
  }
}