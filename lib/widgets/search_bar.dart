import 'package:flutter/material.dart';
import 'package:inmoworld_web/generated/l10n.dart';

class SearchBar extends StatelessWidget {
  final Function(String) onSearchChanged;

  const SearchBar({required this.onSearchChanged, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: S.current.SearchProperties,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              onSearchChanged('');
            },
          ),
        ),
      ),
    );
  }
}
