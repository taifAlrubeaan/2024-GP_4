import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sleepwell/screens/home_screen.dart';
import 'package:sleepwell/widget/regsterbutton.dart';

class SignUpScreen extends StatefulWidget {
  static String RouteScreen = 'signup_screen';
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
<<<<<<< HEAD
  final _auth = FirebaseAuth.instance;
// why late because i well not give  it a value new
  late String name;
  late String email;
  late String password;
  late String cpassword;
=======
final _auth=FirebaseAuth.instance;
bool  showSpinner = false;
// why late because i well not give  it a value new 
 late String name;
 late String email;
 late String password ;
 late String cpassword ;
>>>>>>> 1bb97c14de05b64236fa846ab495da87678006f7

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
<<<<<<< HEAD
        backgroundColor: Color.fromARGB(255, 0, 74, 173),
        title: const Text(
            ''), /*const Center(
          child:Text(
            'Sign In',
            style: TextStyle(color: Color.fromARGB(228, 230, 230, 227), // pick a colore 
            fontWeight: FontWeight.bold,
            fontSize: 30,
           ), 
           ),
        ),*/
      ),
      body: Container(
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
              /*const SizedBox(
                height: 200,
                width: double.infinity,
                 child: Image(image: AssetImage('assets/logo2.png'),
                 ),
               ), */
              const SizedBox(
                height: 15,
              ),
              const Center(
                child: Text(
                  'Let’s create  your account!',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                keyboardType: TextInputType.name,
                onChanged: (value) {
                  // here i save the  value of email from user
                  name = value;
                },
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  suffixIcon: const Icon(Icons.person),
                  hintText: 'Full Name ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  // here i save the  value of email from user
                  email = value;
                },
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  suffixIcon: Icon(Icons.email),
                  hintText: 'Email Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                keyboardType: TextInputType.visiblePassword,
                onChanged: (value) {
                  // here i save the  value of email from user
                  password = value;
                },
                obscureText: true,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  suffixIcon: const Icon(Icons.key),
                  hintText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                keyboardType: TextInputType.visiblePassword,
                onChanged: (value) {
                  // here i save the  value of email from user
                  cpassword = value;
                },
                obscureText: true,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  suffixIcon: const Icon(Icons.key),
                  hintText: 'Confirm Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              regsterbutton(
                color: Color(0xffd5defe),
                title: 'Create Account',
                onPressed: () async {
                  try {
                    Navigator.pushNamed(context, MyHomePage.RouteScreen);
                    final nweUser = await _auth.createUserWithEmailAndPassword(
                        email: email, password: password);
                    Navigator.pushNamed(context, MyHomePage.RouteScreen);
                  } catch (e) {
                    print(e);
                  }
                },
              ),
            ],
          ),
        ),
      ),
=======
        backgroundColor:  Color.fromARGB(255, 0, 74, 173),
        title: const Text('') ,
        ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Container(
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
                 /*const SizedBox(
                  height: 200,
                  width: double.infinity,
                   child: Image(image: AssetImage('assets/logo2.png'),
                   ),
                 ), */
                 const SizedBox( height: 15,),
                 const Center(
                   child:  Text( 
                    'Let’s create  your account!',
                    style: TextStyle(
                     color: Colors.white,
                     fontSize: 20,
                     fontWeight: FontWeight.bold
                      ),),
                 ),
                  const SizedBox( height: 15,),
                 TextField(
                  keyboardType: TextInputType.name,
                  onChanged:(value) {
                    // here i save the  value of email from user 
                    name=value;
                  },
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                     filled: true,
                     suffixIcon:const  Icon(Icons.person),
                     hintText:  'Full Name ',  
                     border: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(10),
                     ),),
                 ),  
                 const SizedBox( height: 15,),
                
                 TextField(
                  keyboardType: TextInputType.emailAddress,
                  onChanged:(value) {
                    // here i save the  value of email from user 
                    email=value;
                  },
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                     filled: true,
                     suffixIcon: Icon(Icons.email),
                     hintText: 'Email Address' ,  
                     border: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(10),
                     ),),
                 ),
                  const SizedBox( height: 15,),
                 TextField(
                  keyboardType: TextInputType.visiblePassword,
                  onChanged:(value) {
                    // here i save the  value of email from user 
                    password=value;
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    suffixIcon:const  Icon(Icons.key),
                    hintText:'Password',  
                    border: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(10),
                     ),),
                 ),
                 const SizedBox( height: 15,),
                 TextField(
                  keyboardType: TextInputType.visiblePassword,
                  onChanged:(value) {
                    // here i save the  value of email from user 
                    cpassword=value;
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    suffixIcon:const  Icon(Icons.key),
                   hintText:'Confirm Password',  
                    border: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(10),
                     ),),
                 ),
                   const SizedBox( height: 30,),
                   regsterbutton(
                      color:Color(0xffd5defe),
                      title:'Create Account',
                      onPressed: ()  async{ 
                         setState(() {
                           showSpinner =true ;
                         });
                          try {
                           final nweUser = await _auth.createUserWithEmailAndPassword(
                          email: email, password: password); 
                           Navigator.pushNamed(context,MyHomePage.RouteScreen);
                           setState(() {
                             showSpinner =false ;
                           });
                          } catch (e) {
                            print(e);
                          }
        
                      },),
                 ],
             ),
           ),
        ),
      ), 
    
>>>>>>> 1bb97c14de05b64236fa846ab495da87678006f7
    );
  }
}
