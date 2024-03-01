import 'package:flutter/material.dart';
class regsterbutton extends StatelessWidget {
 regsterbutton({required this.color, required this.title,required this.onPressed});
 final Color color;
 final String title;
 final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Material(
        elevation: 5,
        color: color,
        borderRadius: BorderRadius.circular(10),
        child: MaterialButton (
          onPressed: onPressed,
          minWidth: 220,
          height: 42,
          child: Text( 
            title, 
            style: TextStyle(color: Colors.black ,fontSize:20 ,),
            
            ),
      
        ),
        ),
    );
  }
}