import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class PostalCodeField extends StatelessWidget {
  final String countryCode;
  final Function(PostalCode)? onSelected;
  final String? hint;
  final Widget? suffixIcon;

  PostalCodeField({
    Key? key,
    required this.countryCode,
    required this.onSelected,
    this.hint,
    this.suffixIcon,
  }) : super(key: key);

  final service = PostalCodeService();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Autocomplete<PostalCode>(
        optionsBuilder: (textEditingValue) async {
          final query = textEditingValue.text;
          return query.isNotEmpty
              ? await service.getpostalCodes(query, countryCode)
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

class PostalCodeService {
  late final client = HttpClient();

  Future<List<PostalCode>> getpostalCodes(
      String query, String countryCode) async {
    final url = Uri.https(
      'public.opendatasoft.com',
      '/api/records/1.0/search/',
      {
        'dataset': 'geonames-postal-code',
        'rows': '100',
        'refine.country_code': countryCode.toUpperCase(),
        'q': query,
      },
    );

    final response = await http.get(url);
    final data = jsonDecode(response.body);
    final List records = data['records'];

    return records
        .map((record) {
          final fields = record['fields'];
          return PostalCode(
            postalCode: fields['postal_code'],
            city: fields['place_name'],
            countryCode: fields['country_code'],
            latitude: fields['latitude'],
            longitude: fields['longitude'],
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
  final String postalCode;
  final String city;
  final String countryCode;
  final double latitude;
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
