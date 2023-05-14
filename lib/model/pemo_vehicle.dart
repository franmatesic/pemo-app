class PemoVehicle {
  static const keyId = "id";
  static const keyUserId = "userId";
  static const keyBrand = "brand";
  static const keyModel = "model";
  static const keyColor = "color";
  static const keyMaxPassengers = "maxPassengers";

  final String id;
  final String userId;
  String brand;
  String? model;
  String color;
  int maxPassengers;

  PemoVehicle(this.id, this.userId, this.brand, this.color, this.maxPassengers);

  PemoVehicle.all(this.id, this.userId, this.brand, this.model, this.color, this.maxPassengers);
}
