import 'package:flutter/material.dart';
import 'package:sleepwell/screens/home_screen.dart';
import 'package:sleepwell/widget/regsterbutton.dart';


class SignUpScreen extends StatefulWidget {
  static String RouteScreen ='signup_screen';
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white ,
      appBar: AppBar(
        backgroundColor:  Color.fromARGB(255, 0, 74, 173),
        title: const Text('') ,/*const Center(
          child:Text(
            'Sign In',
            style: TextStyle(color: Color.fromARGB(228, 230, 230, 227), // pick a colore 
            fontWeight: FontWeight.bold,
            fontSize: 30,
           ), 
           ),
        ),*/
        ),
      body:  Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
           gradient: LinearGradient(
           colors: [Color(0xFF004AAD), Color(0xFF040E3B)],
           begin: Alignment.topCenter,
           end: Alignment.bottomCenter,
            ),
            ),
        child: Padding(
           padding: EdgeInsets.all(20),
           child: ListView(
            shrinkWrap: true,
            children: [ 
               const SizedBox(
                height: 200,
                width: double.infinity,
                 child: Image(image: AssetImage('assets/logo2.png'),
                 ),
               ), 
               
               const Center(
                 child:  Text( 
                  'Sign up new account',
                  style: TextStyle(
                   color: Colors.white,
                   fontSize: 20,
                   fontWeight: FontWeight.bold
                    ),),
               ),
                const SizedBox( height: 15,),
               TextField(
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                   filled: true,
                   suffixIcon:const  Icon(Icons.person),
                   label:  const Text ('Full Name ') ,  
                   border: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(10),
                   ),),
               ),  
               const SizedBox( height: 15,),
              
               TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                   filled: true,
                   suffixIcon: Icon(Icons.email),
                   label: const Text ('Email Address') ,  
                   border: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(10),
                   ),),
               ),
                const SizedBox( height: 15,),
               TextField(
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  suffixIcon:const  Icon(Icons.key),
                  label:const  Text ('Password') ,  
                  border: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(10),
                   ),),
               ),
               const SizedBox( height: 15,),
               TextField(
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  suffixIcon:const  Icon(Icons.key),
                  label:const  Text ('Confirm Password') ,  
                  border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(10),
                   ),),
               ),
                 const SizedBox( height: 30,),
                 regsterbutton(
                    color:Color(0xffd5defe),
                    title:'Sign Up',
                    onPressed: (){
                       Navigator.pushNamed(context,MyHomePage.RouteScreen);
                    },),
               ],
           ),
         ),
      ), 
    
    );
  }
}