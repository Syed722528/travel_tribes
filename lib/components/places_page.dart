import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PlacesPage extends StatefulWidget {
  final String placeId;

  const PlacesPage({super.key, required this.placeId});

  @override
  State<PlacesPage> createState() => _PlacesPageState();
}

class _PlacesPageState extends State<PlacesPage> {
  late Future<DocumentSnapshot> placeData;

  @override
  void initState() {
    super.initState();
    placeData = FirebaseFirestore.instance
        .collection('top_places')
        .doc(widget.placeId)
        .get(); // Fetch the document using placeId
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: placeData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Error loading place details.')),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('Place not found.')),
          );
        }

        // Extract data from the document
        final place = snapshot.data!;
        final title = place['title'] ?? 'No Title';
        final imageUrl = place['image'] ?? '';
        final history = place['history'] ?? 'No history available.';
        final latitude = place['latitude'] ?? 0.0;
        final longitude = place['longitude'] ?? 0.0;

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [
              IconButton(
                  onPressed: () {
                    
                  },
                  icon: Icon(Icons.location_on_outlined)),
              IconButton(
                  onPressed: () {}, icon: Icon(Icons.image_search_rounded))
            ], // Display title in the AppBar
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageUrl.isNotEmpty)
                    Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                              imageUrl,
                            ),
                          )),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'History',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    history,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
