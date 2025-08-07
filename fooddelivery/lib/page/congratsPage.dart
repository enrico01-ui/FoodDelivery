import 'package:flutter/material.dart';
import 'package:fooddelivery/entity/menu.dart';
import 'package:fooddelivery/entity/order.dart';
import 'package:fooddelivery/entity/orderItem.dart';
import 'package:fooddelivery/page/mapPage.dart';

class Congratspage extends StatelessWidget {
  final List<Menu> menuList;
  final Order order;
  const Congratspage({super.key, required this.menuList, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Padding(padding: EdgeInsets.only(top: 90),child:  Image(image: AssetImage('images/logo.png'))),
          const SizedBox(height: 30),
          
          const SizedBox(height: 30,),
          const Padding(
            padding: EdgeInsets.only(bottom: 80),
            
            child: Column(
              children: [
                Text(
                  'Congratulations!!!',
                  style: TextStyle(
                    fontSize: 25,
                    fontFamily: "Sen",
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Your order has been placed successfully. You will receive a confirmation email shortly.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    
                    fontSize: 15,
                    fontFamily: "Sen",
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: Size(MediaQuery.of(context).size.width, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapPage(menu: menuList, order: order)),
                );
              },
              child: const Text('Back to Home'),
            ),
          )
        ],
      ),
    );
  }
}