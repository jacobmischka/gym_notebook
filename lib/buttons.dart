import 'package:flutter/material.dart';

class ShowNotesButton extends StatelessWidget {
  final String title;
  final String notes;
  ShowNotesButton(this.notes, [this.title]);

  @override
  Widget build(BuildContext context) {
    if (notes == null || notes.isEmpty) {
      return Container(width: 0, height: 0);
    }

    return IconButton(
        icon: Icon(Icons.event_note),
        tooltip: 'Show notes',
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                    title: title != null ? Text(title) : null,
                    content: Text(notes));
              });
        });
  }
}
