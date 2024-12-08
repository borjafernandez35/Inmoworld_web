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

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/logo.png',
          height: 40,
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: PagedListView<int, PropertyModel>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<PropertyModel>(
          itemBuilder: (context, property, index) {
            try {
              return Card(
                child: ListTile(
                  title: Text(property.address),
                  subtitle: Text(property.description),
                ),
              );
            } catch (e) {
              print("Error al renderizar propiedad: $e");
              return const Center(child: Text('Error al mostrar propiedad.'));
            }
          },
          noItemsFoundIndicatorBuilder: (context) => const Center(
            child: Text('No properties found'),
          ),
          firstPageErrorIndicatorBuilder: (context) => const Center(
            child: Text('Error al cargar propiedades.'),
          ),
        ),
      )
    );
  }
}
