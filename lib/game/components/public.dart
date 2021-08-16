import 'package:bankroll/game/components/property.dart';
import 'package:bankroll/game/enums/property_type_enum.dart';
import 'package:flutter/material.dart';

class PublicProperty extends Property {
  PublicProperty(
    String name,
    int price,
    int rentPrice,
  ) : super(
          name: name,
          price: price,
          rentPrice: rentPrice,
          type: SpaceType.PUBLIC,
          color: Colors.grey[200]!,
        );
}
