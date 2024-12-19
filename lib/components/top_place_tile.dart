import 'package:flutter/material.dart';

class TopPlacesTile extends StatelessWidget {
  const TopPlacesTile({
    required this.imagePath,
    required this.onTap,
    required this.title,
    super.key,
  });

  final String imagePath;
  final void Function()? onTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Container(
          height: 400,
          width: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23),
            image: DecorationImage(
              image: NetworkImage(imagePath),
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
          alignment: const Alignment(-0.55, 0.7),
          child: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 25),
          ),
        ),
      ),
    );
  }
}