import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/item.dart';
import '../models/pricing_table.dart';

class EditItemScreen extends StatefulWidget {
  final Item item;
  final Function(String, String, String, List<PricingTable>, File) onSave;
  final VoidCallback onDelete;

  const EditItemScreen(
      {super.key,
      required this.item,
      required this.onSave,
      required this.onDelete});

  @override
  _EditItemScreenState createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _addressController;
  late List<PricingTable> _pricingTable;
  File? _image;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _phoneNumberController =
        TextEditingController(text: widget.item.phoneNumber);
    _addressController = TextEditingController(text: widget.item.address);
    _pricingTable = widget.item.pricingTable;
    _image = widget.item.avatar;
  }

  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _chooseFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _addPricingTable() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController _dayController = TextEditingController();
        final TextEditingController _hourController = TextEditingController();
        final TextEditingController _priceController = TextEditingController();

        return AlertDialog(
          title: Text('Add Pricing Table',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: Theme.of(context).colorScheme.primary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _dayController,
                decoration: InputDecoration(labelText: 'Day'),
              ),
              TextField(
                controller: _hourController,
                decoration: InputDecoration(labelText: 'Hour'),
              ),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Theme.of(context).colorScheme.primary)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _pricingTable.add(PricingTable(
                    day: _dayController.text,
                    hour: _hourController.text,
                    price: int.parse(_priceController.text),
                  ));
                });
                Navigator.of(context).pop();
              },
              child: Text('Add',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary)),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.primary)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveItem() async {
    final updatedItem = Item(
      name: _nameController.text,
      phoneNumber: _phoneNumberController.text,
      address: _addressController.text,
      pricingTable: _pricingTable,
      avatar: _image ?? File('assets/images/default_avatar.png'),
    );

    final snapshot = await FirebaseFirestore.instance
        .collection('items')
        .where('name', isEqualTo: widget.item.name)
        .where('phoneNumber', isEqualTo: widget.item.phoneNumber)
        .where('address', isEqualTo: widget.item.address)
        .get();

    for (final doc in snapshot.docs) {
      await FirebaseFirestore.instance
          .collection('items')
          .doc(doc.id)
          .update(updatedItem.toMap());
    }

    widget.onSave(
      _nameController.text,
      _phoneNumberController.text,
      _addressController.text,
      _pricingTable,
      _image ?? File('assets/images/default_avatar.png'),
    );

    Navigator.pop(context);
  }

  Future<void> _deleteItem() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('items')
        .where('name', isEqualTo: widget.item.name)
        .where('phoneNumber', isEqualTo: widget.item.phoneNumber)
        .where('address', isEqualTo: widget.item.address)
        .get();

    for (final doc in snapshot.docs) {
      await FirebaseFirestore.instance.collection('items').doc(doc.id).delete();
    }

    widget.onDelete();
    Navigator.pop(context);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: Theme.of(context).colorScheme.primary)),
          content: Text('Do you want to delete?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Theme.of(context).colorScheme.primary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteItem();
              },
              child: Text('Delete',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary)),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 24),
          color: Theme.of(context).colorScheme.onPrimary,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Edit Court',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      floatingActionButton: Container(
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              offset: const Offset(0.5, -1.5),
              blurRadius: 2.5,
              spreadRadius: 1.5,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  height: 45,
                  child: FloatingActionButton(
                    heroTag: 'deleteButton',
                    onPressed: _confirmDelete,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    backgroundColor: Colors.red,
                    child: Text(
                      'Delete',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  height: 45,
                  child: FloatingActionButton(
                    heroTag: 'saveButton',
                    onPressed: _saveItem,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      'Save',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  //child: _image == null ? Icon(Icons.person, size: 60) : null,
                ),
                SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _takePhoto,
                          child: Text("Take a photo"),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _chooseFromGallery,
                          child: Text("Choose from gallery"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Text(
                        "Information",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    Divider(
                      color: Theme.of(context).colorScheme.primary,
                      thickness: 3,
                      indent: 150,
                      endIndent: 150,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              "Name",
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              "Phone Number",
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          TextField(
                            controller: _phoneNumberController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              "Address",
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          TextField(
                            controller: _addressController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40),
                    Row(
                      children: [
                        Text(
                          'Pricing Table',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(
                            Icons.add,
                            color: Theme.of(context).colorScheme.primary,
                            size: 26,
                          ),
                          onPressed: _addPricingTable,
                        ),
                      ],
                    ),
                    Divider(
                      color: Theme.of(context).colorScheme.primary,
                      thickness: 3,
                      indent: 0,
                      endIndent: 10,
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _pricingTable.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            '${_pricingTable[index].day}  |  ${_pricingTable[index].hour}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight:
                                      FontWeight.bold, // Make title bold
                                ),
                          ),
                          subtitle: Text(
                            '${_pricingTable[index].price}k',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            onPressed: () {
                              setState(() {
                                _pricingTable.removeAt(index);
                              });
                            },
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
