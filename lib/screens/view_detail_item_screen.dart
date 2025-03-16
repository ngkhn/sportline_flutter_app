import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/item.dart';
import '../models/pricing_table.dart';
import 'edit_item_screen.dart';

class ViewDetailItemScreen extends StatefulWidget {
  final String name;
  final String phoneNumber;
  final String address;
  final List<PricingTable> pricingTable;
  final File avatar;
  final VoidCallback onDelete;
  final Function(Item) onSave;

  const ViewDetailItemScreen({
    super.key,
    required this.name,
    required this.phoneNumber,
    required this.address,
    required this.pricingTable,
    required this.avatar,
    required this.onDelete,
    required this.onSave,
  });

  @override
  _ViewDetailItemScreenState createState() => _ViewDetailItemScreenState();
}

class _ViewDetailItemScreenState extends State<ViewDetailItemScreen> {
  late String name;
  late String phoneNumber;
  late String address;
  late List<PricingTable> pricingTable;
  late File avatar;

  @override
  void initState() {
    super.initState();
    name = widget.name;
    phoneNumber = widget.phoneNumber;
    address = widget.address;
    pricingTable = widget.pricingTable;
    avatar = widget.avatar;
  }

  void _handleSave(String newName, String newPhoneNumber, String newAddress,
      List<PricingTable> newPricingTable, File newAvatar) async {
    final updatedItem = Item(
      name: newName,
      phoneNumber: newPhoneNumber,
      address: newAddress,
      pricingTable: newPricingTable,
      avatar: newAvatar,
    );

    /* final snapshot = await FirebaseFirestore.instance
        .collection('items')
        .where('name', isEqualTo: widget.name)
        .where('phoneNumber', isEqualTo: widget.phoneNumber)
        .where('address', isEqualTo: widget.address)
        .get();

    for (final doc in snapshot.docs) {
      await FirebaseFirestore.instance
          .collection('items')
          .doc(doc.id)
          .update(updatedItem.toMap());
    } */

    setState(() {
      name = newName;
      phoneNumber = newPhoneNumber;
      address = newAddress;
      pricingTable = newPricingTable;
      avatar = newAvatar;
    });

    widget.onSave(updatedItem);
  }

  void _handleDelete() {
    widget.onDelete();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, size: 24),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text('Court Details'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditItemScreen(
                        item: Item(
                          name: name,
                          phoneNumber: phoneNumber,
                          address: address,
                          pricingTable: pricingTable,
                          avatar: avatar,
                        ),
                        onSave: _handleSave,
                        onDelete: _handleDelete,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: avatar.path.isNotEmpty
                    ? FileImage(avatar)
                    : AssetImage('assets/images/default_avatar.png')
                        as ImageProvider,
              ),
              SizedBox(height: 10),
              Text(
                name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 10),
              TabBar(
                tabs: [
                  Tab(text: 'Info'),
                  Tab(text: 'Prices'),
                ],
                indicatorColor: Theme.of(context).colorScheme.primary,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Colors.grey,
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Phone Number',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onPrimary,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.3),
                                  offset: const Offset(0.5, 1.5),
                                  blurRadius: 2.5,
                                  spreadRadius: 1.5,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(Icons.phone,
                                          size: 24,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                      SizedBox(width: 10),
                                      Text(
                                        phoneNumber,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                  child: VerticalDivider(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    thickness: 1,
                                  ),
                                ),
                                SizedBox(
                                  width: 38,
                                  height: 38,
                                  child: IconButton(
                                    icon: Icon(Icons.copy_rounded),
                                    iconSize: 24,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    onPressed: () {
                                      FlutterClipboard.copy(phoneNumber).then(
                                          (value) =>
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .primaryContainer,
                                                      content: Text(
                                                        'Phone number copied to clipboard.',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headlineSmall
                                                            ?.copyWith(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary),
                                                      ))));
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Address',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onPrimary,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.3),
                                  offset: const Offset(0.5, 1.5),
                                  blurRadius: 2.5,
                                  spreadRadius: 1.5,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(Icons.location_on,
                                          size: 24,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                      SizedBox(width: 10),
                                      Flexible(
                                        child: Text(
                                          address,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall,
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                  child: VerticalDivider(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    thickness: 1,
                                  ),
                                ),
                                SizedBox(
                                  width: 38,
                                  height: 38,
                                  child: IconButton(
                                    icon: Icon(Icons.copy_rounded),
                                    iconSize: 24,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    onPressed: () {
                                      FlutterClipboard.copy(address).then(
                                          (value) =>
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .primaryContainer,
                                                      content: Text(
                                                        'Address copied to clipboard.',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headlineSmall
                                                            ?.copyWith(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary),
                                                      ))));
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      itemCount: pricingTable.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                              '${pricingTable[index].day}  |  ${pricingTable[index].hour}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          subtitle: Text('${pricingTable[index].price}k',
                              style: Theme.of(context).textTheme.bodyMedium),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
