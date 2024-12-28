import 'package:flutter/material.dart';

class PlaceTile extends StatelessWidget {
  const PlaceTile({
    required this.imagePath,
    required this.onTap,
    required this.title,
    this.history,
    this.useGradient = true,
    super.key,
  });

  final String imagePath;
  final void Function()? onTap;
  final String title;
  final String? history;
  final bool useGradient;
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
          child: Stack(
            children: [
              
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(23),
                      gradient: useGradient
                          ? LinearGradient(
                              colors: [Colors.black87, Colors.transparent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(colors: [
                              Colors.transparent,
                              Colors.transparent
                            ])),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (history != null)
                        SizedBox(
                          height: 80,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Text(
                              history!,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
