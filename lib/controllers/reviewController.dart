import 'package:get/get.dart';
import 'package:inmoworld_web/models/reviewModel.dart';
import 'package:inmoworld_web/services/review.dart';

class ReviewController extends GetxController {
  var reviews = <ReviewModel>[].obs;
  var isLoading = false.obs;
  var statusMessage = ''.obs;

  final ReviewService _reviewService = ReviewService();

  Future<List<ReviewModel>> fetchReviews(String propertyId) async {
    try {
      isLoading(true);
      statusMessage('');
      var reviewList = await _reviewService.getReviews();
      var filteredReviews = reviewList.where((review) => review.property == propertyId).toList();
      reviews.assignAll(filteredReviews);
      return filteredReviews; // Retornar la lista de reseñas filtradas
    } catch (e) {
      statusMessage('Error fetching reviews: $e');
      return []; // Retornar una lista vacía en caso de error
    } finally {
      isLoading(false);
    }
  }

  Future<void> createReview(ReviewModel review) async {
    try {
      isLoading(true);
      statusMessage('');
      var newReview = await _reviewService.createReview(review);
      reviews.add(newReview);
    } catch (e) {
      statusMessage('Error creating review: $e');
    } finally {
      isLoading(false);
    }
  }
}

