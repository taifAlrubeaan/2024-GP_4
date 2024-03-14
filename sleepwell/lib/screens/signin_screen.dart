import 'package:flutter/material.dart';
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
 // why late because i well not give  it a value new 
 late String email;
 late String password ;

  @override
  Widget build(BuildContext context) {
    Color myColor =  Color.fromARGB(255, 0, 74, 173);
    return Scaffold(
      backgroundColor:  Colors.white,
      
       appBar: AppBar(
        backgroundColor: myColor,
        title: const Text('') ,
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
                height: 150,
                width: double.infinity,
                 child: Image(image: AssetImage('assets/logo2.png'),
                 ),
               ),
              
               const Center(
                 child:  Text( 
                  'Welcome  back!',
                  style: TextStyle(
                   color: Colors.white,
                   fontSize: 25,
                   fontWeight: FontWeight.bold
                    ),),
               ),
               const Center(
                 child:  Text( 
                  '  start exploring our platform today!',
                  style: TextStyle(
                   color: Colors.white,
                   fontSize: 20,
                   fontWeight: FontWeight.bold
                    ),),
               ),
               const SizedBox(height: 25) ,
               TextField(
                keyboardType: TextInputType.emailAddress,
                onChanged:(value) {
                  // here i save the  value of email from user 
                  email=value;
                },
                decoration: InputDecoration(
                   fillColor: Colors.white,
                   filled: true,
                   suffixIcon:const  Icon(Icons.email),
                   hintText:'Email' , 
                   border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(10),
                   
                    //border:OutlineInputBorder(borderRadius:BorderRadius.circular(10),
                   ), ),
               ),
              const  SizedBox( height: 15,),
              
              TextField(
                keyboardType: TextInputType.visiblePassword,
                onChanged:(value) {
                  // here i save the  value of pssword from user 
                  password=value;
                },
                obscureText: true,
                decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                suffixIcon: const Icon(Icons.key, ),
                 hintText: 'Password',  
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
                     print(email);
                     print(password);
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