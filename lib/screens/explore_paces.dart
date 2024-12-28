import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_learn/components/palce_tile.dart';
import 'package:flutter/material.dart';

@immutable
class ExplorePaces extends StatefulWidget {
   ExplorePaces({super.key,required this.placeId});
String placeId;
  @override
  State<ExplorePaces> createState() => _ExplorePacesState();
}

class _ExplorePacesState extends State<ExplorePaces> {
  // final List _data = [
  //   {'title': 'Pir Chanasi', 'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/02/Pir_Chinasi_and_shrine.jpg/800px-Pir_Chinasi_and_shrine.jpg'},
  //   {'title': 'Shounter Lake', 'image': 'https://i.pinimg.com/originals/52/d8/8a/52d88a78c628e0487d177cf37cb6e8ca.jpg'},
  //   {'title': 'Neelum Valley', 'image': 'https://pakistanroadtrips.pk/wp-content/uploads/2023/06/istockphoto-592381114-170667a.webp'},
  // ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: SizedBox(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('places')
                  .doc(widget.placeId)
                  .collection('famousPlaces')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error Loading Places'));
                }
                final data = snapshot.data?.docs ?? [];

                if (data.isEmpty) {
                  return const Center(
                    child: Text('No places available'),
                  );
                }

                return ListView.builder(
              scrollDirection: Axis.vertical,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final place = data[index];

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 15),
                    child: PlaceTile(
                        imagePath: place['image']!,
                        history: place['history'],
                        onTap: () {},
                        title: place['title']),
                  );
                });
              },
              
            ),

          ),
        ),
      ),
    );
  }
}
