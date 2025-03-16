class PricingTable {
  final String day;
  final String hour;
  final int price;

  PricingTable({
    required this.day,
    required this.hour,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'hour': hour,
      'price': price,
    };
  }

  factory PricingTable.fromMap(Map<String, dynamic> map) {
    return PricingTable(
      day: map['day'],
      hour: map['hour'],
      price: map['price'],
    );
  }
}
