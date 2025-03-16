import 'dart:io';
import 'pricing_table.dart';

class Item {
  final File avatar;
  final String name;
  final String phoneNumber;
  final String address;
  final List<PricingTable> pricingTable;

  Item({
    required this.avatar,
    required this.name,
    required this.phoneNumber,
    required this.address,
    required this.pricingTable,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'address': address,
      'pricingTable': pricingTable.map((e) => e.toMap()).toList(),
      'avatar': avatar.path,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      address: map['address'],
      pricingTable: List<PricingTable>.from(
          map['pricingTable']?.map((x) => PricingTable.fromMap(x))),
      avatar: File(map['avatar']),
    );
  }
}
