import 'dart:io';
import 'package:flutter/material.dart';

class CustomAppBar extends StatefulWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        'Home',
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
      ),
      centerTitle: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }
}
