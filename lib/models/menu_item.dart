import 'package:flutter/material.dart';

class MenuItem {
  final String image;
  final String label;
  final IconData icon;

  final Widget trailing;
  final Function() onPress;

  MenuItem(this.image, this.label, this.icon, {this.trailing, this.onPress});
}
