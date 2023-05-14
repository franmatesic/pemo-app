class PemoRole {
  static const passenger = 'PASSENGER';
  static const driver = 'DRIVER';
  static const admin = 'ADMIN';

  PemoRole._();
}

class PemoGender {
  static const male = 'MALE';
  static const female = 'FEMALE';
  static const other = 'OTHER';

  PemoGender._();
}

class PemoPaymentMethod {
  static const cash = 'CASH';
  static const revolut = 'Revolut';
  static const aircash = 'aircash';
  static const keks = 'KEKS pay';
  static const paypal = 'PayPal';
  
  static final values = [cash, revolut, aircash, keks, paypal];

  PemoPaymentMethod._();
}
