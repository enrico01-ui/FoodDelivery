import 'package:flutter/material.dart';
import 'package:fooddelivery/page/loginPage.dart';

class OpenPage extends StatefulWidget {
  const OpenPage({super.key});

  @override
  State<OpenPage> createState() => _OpenPageState();
}

class _OpenPageState extends State<OpenPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(

      child: DecoratedBox(
        decoration: const BoxDecoration(
          //gradient color background
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            stops: [0.0, 0.7, 1.0],
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color.fromARGB(255, 240, 212, 171),
              Colors.orange,
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Padding(padding: EdgeInsets.only(top: 90),child:  Image(image: AssetImage('images/logo.png'))),
                const SizedBox(height: 30),
                
                const SizedBox(height: 30,),
                Padding(
                  padding: const EdgeInsets.only(bottom: 80),
                  
                  child: Column(
                    children: [
                      const Text(
                        'Welcome to Food Delivery',
                        style: TextStyle(
                          fontSize: 25,
                          fontFamily: "Sen",
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Order the best meals in Lagos and have them delivered to your doorstep in little or no time. Doesn't that sound delicious???",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          
                          fontSize: 15,
                          fontFamily: "Sen",
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: ElevatedButton(
                          //extend the width of the button
                        
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                        
                            shadowColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              
                              borderRadius: BorderRadius.circular(30),
                              
                            ),
                          ),
                          
                          child: const Icon(Icons.arrow_forward, color: Colors.orange,),
                        ),
                      ),
                    ],
                  ),)
              ],
            ),
          ),
        ),
      ),
    );
  }
}