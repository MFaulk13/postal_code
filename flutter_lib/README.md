# Postal code

Simple auto-complete field for postal codes in any country around the world.

    PostalCodeField(
        countryCode: "cz",
        onSelected: (postalCode) {
            ...
        },
    ),

<img src="https://raw.githubusercontent.com/Lamorak/postal_code/master/flutter_lib/doc/screenshot.png" alt="Screenshot" />

## Installation

Add `postal_code` to your `pubspec.yaml` file:

    dependencies:
        postal_code: ^0.0.3

or call 

    flutter pub add postal_code

## TODO
- [x] Use stable API
- [ ] Implement caching of results
- [ ] Improve style customization
- [ ] Custom improved backend service?
- [ ] Fully offline version?

Feel free to open an issue [here](https://github.com/Lamorak/postal_code/issues) if you have any problems. More features are unlikely to be implemented though to keep the app minimalistic.

## Acknowledgements
This library uses the incredible [ZIPAPI](https://zip-api.eu/en/)