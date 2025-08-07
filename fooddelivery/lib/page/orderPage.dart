import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fooddelivery/entity/menu.dart';
import 'package:fooddelivery/page/paymentPage.dart';
import 'package:hive/hive.dart';



class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List<Menu> menu = [];
  int price = 0;

  @override
  void initState() {
    super.initState();
    _loadCart();  // Fetch cart items and update UI
  }

  Future<void> _loadCart() async {
    var box = Hive.box<Menu>('cart');
    List<Menu> fetchedMenu = box.values.toList();
    int calculatedPrice = 0;
    
    if (fetchedMenu.isNotEmpty) {
      calculatedPrice = fetchedMenu.map((e) => e.totalPrice ?? 0).reduce((value, element) => value + element);
    }

    setState(() {
      menu = fetchedMenu;
      price = calculatedPrice;
    });
    
    print("Cart items: $menu");
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController addressController = TextEditingController();
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 24, 20, 36),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Row(
            children: [
              const SizedBox(width: 15),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
                ),
              ),
              const SizedBox(width: 15),
              const Text(
                'Order',
                style: TextStyle(
                    fontFamily: "Sen",
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              )
            ],
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: menu.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )  // Show loading indicator while fetching data
          : SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 330),
                      child: Column(
                        
                        children: [
                          const SizedBox(height: 20),
                          ListView.builder(
                            itemCount: menu.length,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final food = menu[index];
                              return Padding(
                                padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 150,
                                        height: 150,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(25),
                                            image: DecorationImage(
                                                image: NetworkImage(food.image_url),
                                                fit: BoxFit.cover)),
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            food.name,
                                            style: const TextStyle(
                                                fontFamily: "Sen",
                                                fontSize: 20,
                                                color: Colors.white),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            'Rp ${food.totalPrice}',
                                            style: const TextStyle(
                                                fontFamily: "Sen",
                                                fontSize: 20,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 10),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 50, right: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      food.totalCount = max(0, food.totalCount! + 1);
                                                      food.totalPrice = food.price * food.totalCount!;
                                                      price = menu.map((e) => e.totalPrice!).reduce((value, element) => value + element);
                                                    });
                                                  }, // Add quantity increment logic
                                                  icon: const Icon(
                                                    Icons.add,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                               Text(
                                                  food.totalCount.toString(),
                                                  style: const TextStyle(
                                                      fontFamily: "Sen", fontSize: 20, color: Colors.white),
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      food.totalCount = max(0, food.totalCount! - 1);
                                                      food.totalPrice = food.price * food.totalCount!;
                                                      price = menu.map((e) => e.totalPrice!).reduce((value, element) => value + element);
                                                      if(food.totalCount == 0){
                                                        menu.removeAt(index);
                                                        var box = Hive.box<Menu>('cart');
                                                        box.deleteAt(index);
                                                        
                                                      }
                                                    }); 
                                                  }, // Add quantity decrement logic
                                                  icon: const Icon(
                                                    Icons.remove,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.36,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                          color: Color.fromARGB(255, 238, 237, 237)),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Delivery Address',
                                style: TextStyle(fontFamily: "Sen", fontSize: 20, color: Colors.grey),
                              ),
                              Text(
                                'Edit',
                                style: TextStyle(
                                    fontFamily: "Sen",
                                    fontSize: 20,
                                    color: Colors.orange,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.orange),
                              )
                            ],
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: addressController,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: 'Enter your delivery address',
                              hintStyle: const TextStyle(fontFamily: "Sen", fontSize: 20, color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total: Rp. $price',
                                style: const TextStyle(
                                    fontFamily: "Sen",
                                    fontSize: 20,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold),
                              ),
                              const Wrap(
                                children: [
                                  Text(
                                    'Breakdown',
                                    style: TextStyle(fontFamily: "Sen", fontSize: 16, color: Colors.orange),
                                  ),
                                  SizedBox(width: 5),
                                  Icon(
                                    FontAwesomeIcons.angleRight,
                                    color: Colors.orange,
                                  )
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              minimumSize: const Size(double.infinity, 60),
                            ),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentPage(menuList: menu,)));
                            },
                            child: const Text(
                              'Place Order',
                              style: TextStyle(fontFamily: "Sen", fontSize: 20, color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
