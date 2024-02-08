import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class PostalCodeField extends StatelessWidget {
  /// ISO-3166 country code
  final String countryCode;

  /// Will be called when a [PostalCode] is selected
  final Function(PostalCode)? onSelected;

  /// Initial value for the text field
  final TextEditingValue? initialValue;

  /// Label for the text field
  final Text? label;

  /// Hint for the text field
  final String? hint;

  /// Suffix icon in the text field
  final Widget? suffixIcon;

  PostalCodeField({
    Key? key,
    required this.countryCode,
    required this.onSelected,
    this.initialValue,
    this.label,
    this.hint,
    this.suffixIcon,
  }) : super(key: key);

  final _service = _PostalCodeService();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Autocomplete<PostalCode>(
        initialValue: initialValue,
        optionsBuilder: (textEditingValue) async {
          final query = textEditingValue.text;
          return query.length > 1
              ? await _service.getpostalCodes(query, countryCode)
              : [];
        },
        displayStringForOption: (option) =>
            "${option.postalCode} ${option.city}",
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: 200,
                  maxWidth: constraints.maxWidth,
                ),
                color: Theme.of(context).colorScheme.surface,
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options.elementAt(index);
                    return ListTile(
                      title: Text("${option.postalCode} ${option.city}"),
                      onTap: () => onSelected(option),
                    );
                  },
                ),
              ),
            ),
          );
        },
        fieldViewBuilder: (
          context,
          textEditingController,
          focusNode,
          onFieldSubmitted,
        ) {
          return TextField(
            controller: textEditingController,
            focusNode: focusNode,
            decoration: InputDecoration(
              label: label,
              hintText: hint,
              counter: const SizedBox(),
              suffixIcon: suffixIcon,
            ),
            maxLength: 5,
            onSubmitted: (_) => onFieldSubmitted,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          );
        },
        onSelected: onSelected,
      ),
    );
  }
}

class _PostalCodeService {
  Future<List<PostalCode>> getpostalCodes(
    String query,
    String countryCode,
  ) async {
    final url = Uri.https(
      'zip-api.eu',
      '/api/v1/codes/postal_code=${countryCode.toUpperCase()}-$query*',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      return [];
    }

    dynamic parsedResponse = jsonDecode(response.body);
    List items = [];
    if (parsedResponse is List) {
      items.addAll(parsedResponse);
    } else if (parsedResponse is Map) {
      items.add(parsedResponse);
    }

    return items
        .map((item) {
          return PostalCode(
            postalCode: item['postal_code'],
            city: item['place_name'],
            countryCode: item['country_code'],
            latitude: double.parse(item['lat']),
            longitude: double.parse(item['lng']),
          );
        })
        .where(
          (postalCode) =>
              postalCode.postalCode.removeSpaces().startsWith(query),
        )
        .toList(growable: false)
      ..sort((a, b) => a.city.compareTo(b.city))
      ..sort((a, b) => a.postalCode.compareTo(b.postalCode));
  }
}

class PostalCode {
  /// Suggested postal code
  /// Formatting varies country to country
  final String postalCode;

  /// Name of the city or area represented by the postal code
  final String city;

  /// ISO 3166 code of the country where postal codes were queried
  final String countryCode;

  /// Latitude part of coordinates in the center of area represented by the postal code
  final double latitude;

  /// Longitude part of coordinates in the center of area represented by the postal code
  final double longitude;

  const PostalCode({
    required this.postalCode,
    required this.city,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostalCode &&
          runtimeType == other.runtimeType &&
          postalCode == other.postalCode &&
          city == other.city &&
          countryCode == other.countryCode &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode =>
      postalCode.hashCode ^
      city.hashCode ^
      countryCode.hashCode ^
      latitude.hashCode ^
      longitude.hashCode;

  @override
  String toString() {
    return 'PostalCode{postalCode: $postalCode, city: $city, countryCode: $countryCode, latitude: $latitude, longitude: $longitude}';
  }
}

extension on String {
  String removeSpaces() => this.replaceAll(" ", "");
}
