import 'package:bankroll/game/enums/property_type_enum.dart';

import 'property.dart';

class CityProperty extends Property {
  CityProperty(
    String name,
    int price,
    int rentPrice,
    int buildingsPrice,
    int blockId,
  ) : super(
          name: name,
          price: price,
          initRent: rentPrice,
          type: SpaceType.CITY,
          groupId: blockId,
        );
}
