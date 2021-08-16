import 'package:bankroll/game/components/property.dart';
import 'package:bankroll/game/enums/property_type_enum.dart';

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
          rentPrice: rentPrice,
          type: SpaceType.CITY,
          blockId: blockId,
        );
}
