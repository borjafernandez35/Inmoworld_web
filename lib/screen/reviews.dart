import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inmoworld_web/models/review_model.dart';
import 'package:inmoworld_web/widgets/review_card.dart';
import 'package:inmoworld_web/controllers/reviewController.dart';
import 'package:inmoworld_web/generated/l10n.dart';
import 'package:inmoworld_web/services/storage.dart';

class ReviewsScreen extends StatefulWidget {
  final String propertyId;

  ReviewsScreen({Key? key, required this.propertyId}) : super(key: key);

  @override
  _ReviewsScreenState createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final ReviewController reviewController = Get.find<ReviewController>();

  Future<void> _showCreateReviewDialog(BuildContext context) async {
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController ratingController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(S.current.AgregarResena),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration:  InputDecoration(labelText: S.current.Descripcion),
              ),
              TextField(
                controller: ratingController,
                decoration: InputDecoration(labelText: S.current.Rating),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child:  Text(S.current.Cancelar),
            ),
            TextButton(
              onPressed: () async {
                final newReview = ReviewModel(
                  id: '',
                  owner: StorageService.getId(),
                  property: widget.propertyId,
                  date: DateTime.now(),
                  rating: double.parse(ratingController.text),
                  description: descriptionController.text,
                );

                await reviewController.createReview(newReview);
                Navigator.of(context).pop();

                // Actualiza el estado para reconstruir el FutureBuilder
                setState(() {});
              },
              child:  Text(S.current.Crear),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.Resena),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<ReviewModel>>(
              future: reviewController.fetchReviews(widget.propertyId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return  Center(child: Text(S.current.NoResena));
                } else {
                  final reviews = snapshot.data!;
                  return ListView.builder(
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      return ReviewCard(review: reviews[index]);
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _showCreateReviewDialog(context),
              child: Text(S.current.AgregarResena),
            ),
          ),
        ],
      ),
    );
  }
}
