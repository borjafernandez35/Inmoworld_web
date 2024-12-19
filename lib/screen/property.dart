import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:inmoworld_web/models/propertyModel.dart';
import 'package:inmoworld_web/services/user.dart';

class PropertyScreen extends StatefulWidget {
  const PropertyScreen({Key? key}) : super(key: key);

  @override
  _PropertyScreenState createState() => _PropertyScreenState();
}

class _PropertyScreenState extends State<PropertyScreen> {
  final PagingController<int, PropertyModel> _pagingController =
      PagingController(firstPageKey: 1);
  final UserService _userService = UserService();
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(_fetchProperties);
  }

  Future<void> _fetchProperties(int pageKey) async {
    try {
      final properties = await _userService.getProperties(pageKey, _pageSize);
      print(
          "Propiedades obtenidas: ${properties.map((e) => e.toJson()).toList()}");
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Imagen
                          if (property.picture != null && property.picture!.isNotEmpty)
                            Image.network(
                              property.picture!,
                              height: 100, // Altura fija para la imagen
                              width: 100,  // Anchura fija para la imagen
                              fit: BoxFit.cover,
                            )
                          else
                            Image.asset(
                              'assets/placeholder.jpg', // Imagen de marcador de posición
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          const SizedBox(width: 16.0), // Espaciado entre la imagen y el texto
                          // Textos
                          Expanded(
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  } catch (e) {
                    print("Error al renderizar propiedad: $e");
                    return const Center(
                      child: Text('Error al mostrar propiedad.'),
                    );
                  }
                },
                noItemsFoundIndicatorBuilder: (context) => const Center(
                  child: Text(
                    'No properties found',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                firstPageErrorIndicatorBuilder: (context) => const Center(
                  child: Text(
                    'Error al cargar propiedades.',
                    style: TextStyle(color: Colors.white),
                  ),
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
