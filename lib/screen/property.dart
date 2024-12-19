import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:inmoworld_web/controllers/reviewController.dart';
import 'package:inmoworld_web/controllers/userModelController.dart';
import 'package:inmoworld_web/models/propertyModel.dart';
import 'package:inmoworld_web/models/reviewModel.dart';
import 'package:inmoworld_web/services/user.dart';

class PropertyScreen extends StatefulWidget {
  const PropertyScreen({Key? key}) : super(key: key);

  @override
  _PropertyScreenState createState() => _PropertyScreenState();
}

class _PropertyScreenState extends State<PropertyScreen> {
  final PagingController<int, PropertyModel> _pagingController = PagingController(firstPageKey: 1);
  final UserService _userService = UserService();
  static const int _pageSize = 10;
  final reviewController = Get.put(ReviewController());
  final userController = Get.find<UserModelController>(); // Añadir UserModelController

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(_fetchProperties);
    userController.fetchUser(); // Cargar usuario al abrir la pantalla
  }

  Future<void> _fetchProperties(int pageKey) async {
    try {
      final properties = await _userService.getProperties(pageKey, _pageSize);
      print("Propiedades obtenidas: ${properties.map((e) => e.toJson()).toList()}");
      final isLastPage = properties.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(properties);
      } else {
        _pagingController.appendPage(properties, pageKey + 1);
      }
    } catch (error) {
      print("Error al obtener propiedades: $error");
      _pagingController.error = error;
    }
  }

  Future<void> _showCreateReviewDialog(String propertyId) async {
    final TextEditingController _descriptionController = TextEditingController();
    final TextEditingController _ratingController = TextEditingController();
    final user = userController.user.value; // Obtener el usuario actual

    if (user == null || user.id == null) {
      Get.snackbar("Error", "No se ha encontrado el usuario.");
      return;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Agregar Reseña'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Descripción'),
              ),
              TextField(
                controller: _ratingController,
                decoration: InputDecoration(labelText: 'Rating'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final newReview = ReviewModel(
                  id: '', // Se generará en el backend
                  owner: user.id!, // Usar el ID del usuario actual (no nulo)
                  property: propertyId,
                  date: DateTime.now(),
                  rating: double.parse(_ratingController.text),
                  description: _descriptionController.text,
                );
                await reviewController.createReview(newReview);
                Navigator.of(context).pop();
                setState(() {}); // Refresca la pantalla después de crear una reseña
              },
              child: Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Logo con tamaño duplicado
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset(
              'assets/logo.png',
              height: 110,
            ),
          ),
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Nº de huéspedes | Ubicación | Precio | Check in | Check out ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          // Lista de propiedades
          Expanded(
            child: PagedListView<int, PropertyModel>(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<PropertyModel>(
                itemBuilder: (context, property, index) {
                  try {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            property.address,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            property.description,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14.0,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          FutureBuilder<List<ReviewModel>>(
                            future: reviewController.fetchReviews(property.id),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white));
                              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return Text('No reviews found', style: TextStyle(color: Colors.white70));
                              } else {
                                final reviews = snapshot.data!;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: reviews.map((review) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          review.description,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Text(
                                          'Rating: ${review.rating}',
                                          style: TextStyle(color: Colors.amber),
                                        ),
                                        const Divider(color: Colors.white70),
                                      ],
                                    );
                                  }).toList(),
                                );
                              }
                            },
                          ),
                          ElevatedButton(
                            onPressed: () => _showCreateReviewDialog(property.id),
                            child: Text('Agregar Reseña'),
                          ),
                        ],
                      ),
                    );
                  } catch (e) {
                    print("Error al renderizar propiedad: $e");
                    return const Center(child: Text('Error al mostrar propiedad.'));
                  }
                },
                noItemsFoundIndicatorBuilder: (context) => const Center(
                  child: Text('No properties found', style: TextStyle(color: Colors.white)),
                ),
                firstPageErrorIndicatorBuilder: (context) => const Center(
                  child: Text('Error al cargar propiedades.', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}



