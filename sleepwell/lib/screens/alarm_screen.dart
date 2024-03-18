import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
<<<<<<< HEAD

=======
>>>>>>> a5772954afbe167ad5addf62c64194358466bcd6
=======
import 'package:flutter/widgets.dart';
import 'package:sleepwell/screens/clockview.dart';

>>>>>>> 94255b64638c81c4077e6a696c014cada68e55b3
class AlarmScreen extends StatefulWidget {
  static String RouteScreen = 'alarm_screen';

  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        color: Color(0xFF004AAD),
        child: ClockView(),
      ),
    );
  }
}

<<<<<<< HEAD
<<<<<<< HEAD
      body:  Center(child:Text("Alarms")),
=======
      body: Column(
=======

/*Column(
>>>>>>> 94255b64638c81c4077e6a696c014cada68e55b3
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Center(child:Center(child: Text("Wake Up time "))),
          DigitalClock(
            digitAnimationStyle: Curves.easeInOut,
            is24HourTimeFormat: false,
            areaDecoration: BoxDecoration(
              color: Colors.transparent,
            ),
            hourMinuteDigitTextStyle: TextStyle(
              color: Colors.blueGry,
              fontSize: 50,
            ),
          ),
        ],
      ),
<<<<<<< HEAD
>>>>>>> a5772954afbe167ad5addf62c64194358466bcd6
    );
  }
}
=======
    );*/
>>>>>>> 94255b64638c81c4077e6a696c014cada68e55b3
