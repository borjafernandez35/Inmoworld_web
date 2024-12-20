import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inmoworld_web/models/propertyModel.dart';
import 'package:inmoworld_web/services/user.dart';

class PropertyController {
  final UserService _userService = UserService();

  Future<List<PropertyModel>> fetchProperties(int page, int limit) async {
    print('Fetching properties from backend...');
    final properties = await _userService.getProperties(page, limit);
    print('Properties received: ${properties.map((p) => p.toJson()).toList()}');
    return properties;
  }

   final String apiKey = 'AIzaSyDr6kIiCCTq-jp2JeIzaxDpJgtQBlaUPYI';

  Future<LatLng> getCoordinatesFromAddress(String address) async {
    print('Getting coordinates for address: $address');
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          final lat = location['lat'];
          final lng = location['lng'];
          print('Coordinates for $address: $lat, $lng');
          return LatLng(lat, lng);
        } else {
          throw Exception('No coordinates found for address: $address');
        }
      } else {
        throw Exception('Failed to fetch coordinates: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Failed to get coordinates for $address: $e');
      throw e;
    }
  }
}

