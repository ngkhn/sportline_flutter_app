import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';

import '../models/item.dart';
import '../screens/view_detail_item_screen.dart';

class ItemListTile extends StatelessWidget {
  final Item item;
  final VoidCallback onDelete;
  final Function(Item) onSave;

  const ItemListTile({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: item.avatar.path.isNotEmpty
            ? FileImage(item.avatar)
            : AssetImage('assets/images/default_avatar.png') as ImageProvider,
        radius: 26,
      ),
      title: Text(
        item.name,
        style: Theme.of(context).textTheme.headlineMedium,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.address,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        item.phoneNumber,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                    child: VerticalDivider(
                      color: Theme.of(context).colorScheme.primary,
                      thickness: 1,
                    ),
                  ),
                  SizedBox(
                    height: 36,
                    width: 36,
                    child: IconButton(
                      icon: Icon(Icons.copy_rounded),
                      iconSize: 20,
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () {
                        FlutterClipboard.copy(item.phoneNumber).then((value) =>
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                content: Text(
                                  'Phone number copied to clipboard.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                ))));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      trailing: Icon(
        Icons.keyboard_arrow_right,
        size: 36,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewDetailItemScreen(
              name: item.name,
              phoneNumber: item.phoneNumber,
              address: item.address,
              pricingTable: item.pricingTable,
              avatar: item.avatar,
              onDelete: onDelete,
              onSave: onSave,
            ),
          ),
        );
      },
    );
  }
}
