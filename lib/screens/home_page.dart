import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../components/custom_app_bar.dart';
import '../components/custom_search_bar.dart';
import '../components/item_list_tile.dart';

import 'add_new_item_screen.dart';

import '../models/item.dart';
import '../models/pricing_table.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Item> items = [];

  final TextEditingController _searchController = TextEditingController();
  List<Item> _filteredItems = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchItemsFromFirestore();
  }

  Future<void> _fetchItemsFromFirestore() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('items').get();
    final List<Item> fetchedItems = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Item(
        name: data['name'],
        phoneNumber: data['phoneNumber'],
        address: data['address'],
        pricingTable: (data['pricingTable'] as List<dynamic>)
            .map((e) => PricingTable.fromMap(e as Map<String, dynamic>))
            .toList(),
        avatar: File(data['avatar']),
      );
    }).toList();

    setState(() {
      items.addAll(fetchedItems);
      _filteredItems = items;
    });
  }

  Future<void> _addItem(String name, String phoneNumber, String address,
      List<PricingTable> pricingTable, File avatar) async {
    final newItem = Item(
      name: name,
      phoneNumber: phoneNumber,
      address: address,
      pricingTable: pricingTable,
      avatar: avatar,
    );

    await FirebaseFirestore.instance.collection('items').add(newItem.toMap());

    setState(() {
      items.add(newItem);
      _filteredItems = items;
    });
  }

  Future<void> _deleteItem(int index) async {
    final item = items[index];
    /* final snapshot = await FirebaseFirestore.instance
        .collection('items')
        .where('name', isEqualTo: item.name)
        .where('phoneNumber', isEqualTo: item.phoneNumber)
        .where('address', isEqualTo: item.address)
        .get();

    for (final doc in snapshot.docs) {
      await FirebaseFirestore.instance.collection('items').doc(doc.id).delete();
    } */

    setState(() {
      items.removeAt(index);
      _filteredItems = items;
    });
  }

  Future<void> _updateItem(int index, Item newItem) async {
    final item = items[index];
    /* final snapshot = await FirebaseFirestore.instance
        .collection('items')
        .where('name', isEqualTo: item.name)
        .where('phoneNumber', isEqualTo: item.phoneNumber)
        .where('address', isEqualTo: item.address)
        .get();

    for (final doc in snapshot.docs) {
      await FirebaseFirestore.instance
          .collection('items')
          .doc(doc.id)
          .update(newItem.toMap());
    } */

    setState(() {
      items[index] = newItem;
      _filteredItems = items;
    });
  }

  void _filterItems(String query) {
    setState(() {
      _filteredItems = items
          .where((item) =>
              item.name.toLowerCase().contains(query.toLowerCase()) ||
              item.address.toLowerCase().contains(query.toLowerCase()))
          .toList();
      _sortItems();
    });
  }

  void _sortItems() {
    if (_selectedIndex == 0) {
      _filteredItems.sort((a, b) => a.name.compareTo(b.name));
    } else if (_selectedIndex == 1) {
      _filteredItems.sort((a, b) => b.name.compareTo(a.name));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: CustomAppBar(),
        ),
        floatingActionButton: SizedBox(
          width: 70,
          height: 70,
          child: FloatingActionButton(
            shape: CircleBorder(),
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(
              Icons.add,
              size: 36,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddNewItemScreen(onSave: _addItem),
                ),
              );
            },
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
              child: CustomSearchBar(
                controller: _searchController,
                onChanged: _filterItems,
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    TabBar(
                      tabs: [
                        Tab(text: 'A-Z'),
                        Tab(text: 'Z-A'),
                      ],
                      indicatorColor: Colors.green,
                      labelColor: Theme.of(context).colorScheme.primary,
                      unselectedLabelColor: Colors.grey,
                      onTap: (index) {
                        setState(() {
                          _selectedIndex = index;
                          _sortItems();
                        });
                      },
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          ListView.separated(
                            itemCount: _filteredItems.length,
                            separatorBuilder: (context, index) =>
                                Divider(color: Colors.green, thickness: 1),
                            itemBuilder: (context, index) {
                              return ItemListTile(
                                item: _filteredItems[index],
                                onDelete: () => _deleteItem(index),
                                onSave: (updatedItem) =>
                                    _updateItem(index, updatedItem),
                              );
                            },
                          ),
                          ListView.separated(
                            itemCount: _filteredItems.length,
                            separatorBuilder: (context, index) =>
                                Divider(color: Colors.green, thickness: 1),
                            itemBuilder: (context, index) {
                              return ItemListTile(
                                item: _filteredItems[index],
                                onDelete: () => _deleteItem(index),
                                onSave: (updatedItem) =>
                                    _updateItem(index, updatedItem),
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
          ],
        ),
      ),
    );
  }
}
