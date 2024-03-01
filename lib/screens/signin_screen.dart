import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sleepwell/screens/home_screen.dart';
import 'package:sleepwell/screens/signup_screen.dart';
import 'package:sleepwell/widget/regsterbutton.dart';


class SignInScreen extends StatefulWidget {
  static String RouteScreen ='signin_screen';
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    Color myColor =  Color.fromARGB(255, 0, 74, 173);
    return Scaffold(
      backgroundColor:  Colors.white,
      
       appBar: AppBar(
        backgroundColor: myColor,
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
                height: 220,
                width: double.infinity,
                 child: Image(image: AssetImage('assets/logo2.png'),
                 ),
               ),
              
               const Center(
                 child:  Text( 
                  'Sign in  to your account',
                  style: TextStyle(
                   color: Colors.white,
                   fontSize: 20,
                   fontWeight: FontWeight.bold
                    ),),
               ),
               
               const SizedBox(height: 25) ,
               TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                   fillColor: Colors.white,
                   filled: true,
                   suffixIcon:const  Icon(Icons.email),
                   label:const  Text ('Email') , 
                   border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(10),
                   
                    //border:OutlineInputBorder(borderRadius:BorderRadius.circular(10),
                   ), ),
               ),
               SizedBox( height: 15,),
              
              TextField(
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                suffixIcon: const Icon(Icons.key, ),
                 label: const Text ('Password') ,  
                 border: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(10),
                   
                 ),),
                 ),
                 const SizedBox( height: 30,),
                 regsterbutton(
                    color:Color(0xffd5defe),
                    title:'Sign In',
                    onPressed: (){
                       Navigator.pushNamed(context,MyHomePage.RouteScreen);
                    },),
                       const SizedBox( height: 15,), 
                        
                         Row( 
                        mainAxisAlignment: MainAxisAlignment.center,
                       children:[ 
                          const Text(
                        'New user ?  ',
                        style: TextStyle(color: Colors.white,fontSize:22)),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                            MaterialPageRoute(builder:(context )=> SignUpScreen()));
                          },
                          child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Color.fromARGB(241, 230, 158, 3),
                            fontSize: 20,
                          fontWeight: FontWeight.bold
                          )),
                        ),
                      ],
                     ),
                        
               ],
           ),
         ),
       ), 
    
    );
  }
}