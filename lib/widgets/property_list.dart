import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:inmoworld_web/models/property_model.dart';
import 'package:inmoworld_web/generated/l10n.dart';
import 'package:inmoworld_web/widgets/property_card.dart';
import 'package:get/get.dart';

class PropertyList extends StatelessWidget {
  final PagingController<int, PropertyModel> pagingController;

  const PropertyList({
    Key? key,
    required this.pagingController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, PropertyModel>(
      pagingController: pagingController,
      builderDelegate: PagedChildBuilderDelegate<PropertyModel>(
        // Construcción del elemento
        itemBuilder: (context, property, index) {
          return GestureDetector(
            onTap: () {
              // Navega al detalle de la propiedad al hacer clic
              Get.toNamed(
                '/details',
                arguments: property, // Pasa el modelo de la propiedad
              );
            },
            child: PropertyCard(property: property),
          );
        },
        // Indicador de no encontrar elementos
        noItemsFoundIndicatorBuilder: (_) => Center(
          child: Text(S.current.NoPropertiesFound),
        ),
        // Indicador de progreso en la primera página
        firstPageProgressIndicatorBuilder: (_) =>
            const Center(child: CircularProgressIndicator()),
        // Indicador de progreso al cargar una nueva página
        newPageProgressIndicatorBuilder: (_) =>
            const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}



