

import 'package:flutter/material.dart';

class TwoPaneEmptyScreen extends StatelessWidget{
  String text;

  TwoPaneEmptyScreen(this.text);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: Text(this.text, style: Theme.of(context).textTheme.bodyLarge?..copyWith(
                color: Theme.of(context).colorScheme.primaryContainer
              ),),
          ),
        )

      ],
    );
  }

}