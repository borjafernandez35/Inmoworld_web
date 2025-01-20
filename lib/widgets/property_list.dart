import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:inmoworld_web/models/property_model.dart';
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
        itemBuilder: (context, property, index) {
          return GestureDetector(
            onTap: () {
              Get.toNamed(
                '/details',
                arguments: property, // Pasa el modelo de la propiedad
              );
            },
            child: PropertyCard(property: property),
          );
        },
      ),
    );
  }
}


