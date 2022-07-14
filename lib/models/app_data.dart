class AppDataModel {
  final List<Station> stations;
  final List<Fuel> fuels;
  final List<Provider> providers;
  final List<Option> options;
  final List<TypeOfTheDay> typesOfTheDay;
  final List<FuelType> fuelTypes;
  final List<FuelKind> fuelKinds;
  final List<County> counties;
  final List<District> districts;
  final List<Habitat> places;

  AppDataModel({
    required this.stations,
    required this.fuels,
    required this.providers,
    required this.options,
    required this.typesOfTheDay,
    required this.fuelTypes,
    required this.fuelKinds,
    required this.counties,
    required this.districts,
    required this.places,
  });

  factory AppDataModel.fromJson(Map<String, dynamic> json) {
    return AppDataModel(
      stations: List.from(json['postajas']).map((e) => Station.fromJson(e)).toList(),
      fuels: List.from(json['gorivos']).map((e) => Fuel.fromJson(e)).toList(),
      providers: List.from(json['obvezniks']).map((e) => Provider.fromJson(e)).toList(),
      options: List.from(json['opcijas']).map((e) => Option.fromJson(e)).toList(),
      typesOfTheDay: List.from(json['vrsta_danas']).map((e) => TypeOfTheDay.fromJson(e)).toList(),
      fuelTypes: List.from(json['vrsta_gorivas']).map((e) => FuelType.fromJson(e)).toList(),
      fuelKinds: List.from(json['tip_gorivas']).map((e) => FuelKind.fromJson(e)).toList(),
      counties: List.from(json['zupanijas']).map((e) => County.fromJson(e)).toList(),
      districts: List.from(json['opcina_grads']).map((e) => District.fromJson(e)).toList(),
      places: List.from(json['naseljes']).map((e) => Habitat.fromJson(e)).toList(),
    );
  }
}

class Station {
  final String name;
  final String url;
  final List<dynamic> updates;
  final List<WorkTimes> workTimes;
  final int providerId;
  final int id;
  final List<Price> priceList;
  final String address;
  final String? lat;
  final String? lng;
  final String place;
  final List<StationOption> options;

  Station({
    required this.name,
    required this.url,
    required this.updates,
    required this.workTimes,
    required this.providerId,
    required this.id,
    required this.priceList,
    required this.address,
    required this.lat,
    required this.lng,
    required this.place,
    required this.options,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      name: json['naziv'],
      url: json['url'],
      updates: List.castFrom<dynamic, dynamic>(json['obavijesti']),
      workTimes: List.from(json['radnaVremena']).map((e) => WorkTimes.fromJson(e)).toList(),
      providerId: json['obveznik_id'],
      id: json['id'],
      priceList: List.from(json['cjenici']).map((e) => Price.fromJson(e)).toList(),
      address: json['adresa'],
      lat: json['long'],
      lng: json['lat'],
      place: json['mjesto'],
      options: List.from(json['opcije']).map((e) => StationOption.fromJson(e)).toList(),
    );
  }
}

class WorkTimes {
  final int dayTypeId;
  final String opening;
  final String close;
  final int id;

  WorkTimes({
    required this.dayTypeId,
    required this.opening,
    required this.close,
    required this.id,
  });

  factory WorkTimes.fromJson(Map<String, dynamic> json) {
    return WorkTimes(
      dayTypeId: json['vrsta_dana_id'],
      opening: json['pocetak'],
      close: json['kraj'],
      id: json['id'],
    );
  }
}

class Price {
  final int fuelId;
  final double? price;
  final int id;

  Price({
    required this.fuelId,
    required this.price,
    required this.id,
  });

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      fuelId: json['gorivo_id'],
      price: json['cijena'],
      id: json['id'],
    );
  }

  double get priceInEur => price! / 7.5345;
}

class StationOption {
  final int optionId;
  final int id;

  StationOption({
    required this.optionId,
    required this.id,
  });

  factory StationOption.fromJson(Map<String, dynamic> json) {
    return StationOption(
      optionId: json['opcija_id'],
      id: json['id'],
    );
  }
}

class Fuel {
  final int id;
  final String? name, mark;
  final int? providerId, fuelKindId;

  Fuel({
    required this.name,
    this.mark,
    required this.providerId,
    required this.id,
    required this.fuelKindId,
  });

  factory Fuel.fromJson(Map<String, dynamic> json) {
    return Fuel(
      id: json['id'],
      providerId: json['obveznik_id'],
      fuelKindId: json['vrsta_goriva_id'],
      name: json['naziv'],
      mark: json['oznaka'],
    );
  }
}

class Provider {
  final String? logo;
  final String name;
  final int id;

  Provider({
    this.logo,
    required this.name,
    required this.id,
  });

  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      logo: json['logo'],
      name: json['naziv'],
      id: json['id'],
    );
  }
}

class Option {
  final String name;
  final int id;

  Option({
    required this.name,
    required this.id,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      name: json['naziv'],
      id: json['id'],
    );
  }
}

class TypeOfTheDay {
  final String typeName;
  final int id;

  TypeOfTheDay({
    required this.typeName,
    required this.id,
  });

  factory TypeOfTheDay.fromJson(Map<String, dynamic> json) {
    return TypeOfTheDay(
      typeName: json['vrsta'],
      id: json['id'],
    );
  }
}

class FuelType {
  final int fuelKindId;
  final String name;
  final int id;

  FuelType({
    required this.fuelKindId,
    required this.name,
    required this.id,
  });

  factory FuelType.fromJson(Map<String, dynamic> json) {
    return FuelType(
      fuelKindId: json['tip_goriva_id'],
      name: json['vrsta_goriva'],
      id: json['id'],
    );
  }
}

class FuelKind {
  final String fuelKind;
  final int id;

  FuelKind({
    required this.fuelKind,
    required this.id,
  });

  factory FuelKind.fromJson(Map<String, dynamic> json) {
    return FuelKind(
      fuelKind: json['tip_goriva'],
      id: json['id'],
    );
  }
}

class County {
  final String name;
  final int id;

  County({
    required this.name,
    required this.id,
  });

  factory County.fromJson(Map<String, dynamic> json) {
    return County(
      name: json['naziv'],
      id: json['id'],
    );
  }
}

class District {
  final int districtId;
  final String name;
  final int id;

  District({
    required this.districtId,
    required this.name,
    required this.id,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      districtId: json['zupanija_id'],
      name: json['ime_jedinice'],
      id: json['id'],
    );
  }
}

class Habitat {
  final String name;
  final String url;
  final int districtId;
  final int id;
  final String? lat;
  final String? lng;

  Habitat({
    required this.name,
    required this.url,
    required this.districtId,
    required this.id,
    this.lat,
    this.lng,
  });

  factory Habitat.fromJson(Map<String, dynamic> json) {
    return Habitat(
      name: json['ime'],
      url: json['url'],
      districtId: json['opcina_grad_id'],
      id: json['id'],
      lat: json['lat'],
      lng: json['lng'],
    );
  }
}
