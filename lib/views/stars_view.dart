import 'package:flutter/material.dart';
import '../widgets/star_widet.dart';

class StarsView extends StatelessWidget {
  const StarsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stars Screen')),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              StarWidget(),
              StarWidget(),
              StarWidget(),
            ],
          ),
           Row(mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              StarWidget(),
              StarWidget(),
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children:const [
              StarWidget(),
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children:const [
              StarWidget(),
            ],
          ),
        ],
      )),
    );
  }
}
