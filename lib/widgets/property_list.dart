import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:inmoworld_web/models/property_model.dart';
import 'property_card.dart';

class PropertyList extends StatelessWidget {
  final PagingController<int, PropertyModel> pagingController;

  const PropertyList({required this.pagingController, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, PropertyModel>(
      pagingController: pagingController,
      builderDelegate: PagedChildBuilderDelegate<PropertyModel>(
        itemBuilder: (_, property, __) => PropertyCard(property: property),
        noItemsFoundIndicatorBuilder: (_) => const Center(
          child: Text('No properties found.'),
        ),
        firstPageProgressIndicatorBuilder: (_) =>
            const Center(child: CircularProgressIndicator()),
        newPageProgressIndicatorBuilder: (_) =>
            const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

