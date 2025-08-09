
import 'dart:async';
import 'dart:convert';
import 'package:fooddelivery/theme.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fooddelivery/entity/menu.dart';
import 'package:fooddelivery/page/orderPage.dart';
import 'package:fooddelivery/util/storage.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hive/hive.dart';
//riverpod
import 'package:fooddelivery/entity/profil.dart';
import 'package:fooddelivery/util/constant.dart';
import 'package:http/http.dart' as http;

Future<void> saveMenuToCart(Menu menu, int count, int price) async {

  var box = Hive.box<Menu>('cart');
  //clear the box
  // await box.clear();
  List<Menu> menus = box.values.toList();
  
  for (var m in menus){
    if (menu.item_id == m.item_id){
      menu.totalCount = m.totalCount! + count;
      menu.totalPrice = m.totalPrice! + price;

      int index = menus.indexOf(m); // Find the index of the existing menu
      await box.putAt(index, menu); // Update the existing menu in the box

      print("Updated cart: ${box.values}");
      return;
    }
  }
  menu.totalCount = count;
  menu.totalPrice = price;
  await box.add(menu);
  print("After adding to cart: ${box.values}");
}

class FoodDetail extends StatefulWidget {
  final Menu menu;
  const FoodDetail({super.key, required this.menu});

  @override
  State<FoodDetail> createState() => _FoodDetailState();
}

class _FoodDetailState extends State<FoodDetail> {
  void addToCart(Menu menu, int count, int price) async {
    await saveMenuToCart(menu, count, price);
  }
  Color color = AppPallete.buttonColor;
  late int count;
  late int price;

  Profil? profil;
  String? token;
  void _loadprofil() async {
    try {
      String? username = await Storage.readSecureData('name');
      token = await Storage.readSecureData('personalToken');
      
      if (token != "empty") {
        await _fetchUserProfile(token, username);
        setState(() {}); // Trigger a UI update
      } else {
        token = null;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _fetchUserProfile(String? token, String? username) async {
  try {
    final email = await Storage.readSecureData('email');

    if (email != null) {
      final profilData = await getProfil(token!, email).timeout(const Duration(seconds: 30));
      setState(() {
        profil = Profil.fromJson(profilData);
      });

    } else {
      throw Exception('Email not found');
    }
  } on TimeoutException catch (_) {
    token = null;
  } catch (e) {
    token = null;
    print("Error fetching profile: $e");
  }
}


  Future<Map<String, dynamic>> getProfil(String token, String email) async{
    var endpoint = 'api/profil';
    var url = Uri.https(baseIp, endpoint);
    var data = jsonEncode({'email': email});
    final response = await http.post(
      url, 
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: data  
    );

    print(response.body);
    return jsonDecode(response.body);
  }

  @override
  void initState() {
    super.initState();
    _loadprofil();
    count = 1;
    price = widget.menu.price * count;

  }
  final List<Map<String, dynamic>> icons = [
    {
      'icon': FontAwesomeIcons.drumstickBite,
      'text': "Chicken"
    },
    {
      'icon': HugeIcons.strokeRoundedMilkBottle,
      'text': "Salt"
    },
    {
      'icon': HugeIcons.strokeRoundedVegetarianFood,
      'text': "Sauce"
    },
    {
      'icon': HugeIcons.strokeRoundedOrganicFood,
      'text': "lettuce"
    },
    {
      'icon': FontAwesomeIcons.breadSlice,
      'text': "Bread"
    }
  ];
  void showCustomSnackBar(String title, String message, ContentType type) {
    
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      backgroundColor: Colors.transparent,
      duration: const Duration(seconds: 10), // Ensure snackbar is displayed
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: type,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding:const EdgeInsets.only(bottom: 175),
            child: SingleChildScrollView(
              
              scrollDirection: Axis.vertical,
              child:  Column(
                
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.35,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(widget.menu.image_url),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15, left: 18, right: 15, bottom: 5),
                    child: Text(
                      widget.menu.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontFamily: "Sen",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),  
                  Row(
                
                    children: [
                      const SizedBox(width: 18,),
                      const Icon(
                        FontAwesomeIcons.utensils,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 15,),
                      Text(
                        widget.menu.restaurant.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: "Sen",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                    ],
                  ),
                  const SizedBox(height: 20,),
                  const Row(
                    
                    children: [
                      SizedBox(width: 18,),
                      Icon(
                        FontAwesomeIcons.star,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 10,),
                      Text(
                        "4.7",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Sen",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 30,),
                      Icon(
                        FontAwesomeIcons.truckFast,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 10,),
                      Text(
                        "Free",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Sen",
                        ),
                      ),
                      SizedBox(width: 30,),
                      Icon(
                        FontAwesomeIcons.clock,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 10,),
                      Text(
                        "30 min",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Sen",
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.only(left: 18, right: 18, bottom: 5),
                    child: Text(
                      widget.menu.description,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: "Sen",
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      const SizedBox(width: 18,),
                      Text("Size: ", style: TextStyle(fontFamily: "Sen", fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[600]),),
                      CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        child: const Text(
                          "10",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: "Sen",
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10,),
                      CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        child: const Text(
                          "14",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: "Sen",
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10,),
                      CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        child: const Text(
                          "16",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: "Sen",
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  const Padding(padding: EdgeInsets.only(left: 18),child: Text("Ingredients", style: TextStyle(fontFamily: "Sen", fontSize: 18),)),
                  const SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: icons.map((icon) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  child: Icon(icon['icon'], color: Colors.orange, size: 24),
                                ),
                                const SizedBox(height: 10,),
                                SizedBox(
                                  width: 70,
                                  child: Text(
                                    icon['text'],
                                    style: const TextStyle(
                                      fontFamily: "Sen",
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center
                                  ),
                                )
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 50, left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border, color: Colors.white,),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            )
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              height: 175,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                color: Color.fromARGB(255, 238, 237, 237)
              ),
              child: Column(
                
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Rp $price", style: const TextStyle(fontFamily: "Sen", fontWeight: FontWeight.w600, fontSize: 33),),
                      Container(
                        width: 165,
                        height: 60,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          color: Colors.black,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                              width: 35,
                              height: 35,
                              
                              child: Center(
                                child: CircleAvatar(
                                  
                                  backgroundColor: const Color.fromARGB(255, 56, 56, 56),
                                  child: IconButton(
                                    onPressed: (){
                                      setState(() {
                                        if(count > 0){
                                          count -= 1;
                                          price = widget.menu.price * count;

                                        }
                                      });
                                    }, 
                                    icon: const Icon(
                                      
                                      FontAwesomeIcons.minus,
                                      color: Colors.white,
                                      size: 20,
                                    )
                                  ),
                                ),
                              ),
                            ),
                            Text(count.toString(), style: const TextStyle(fontFamily: "Sen", fontSize: 22, color: Colors.white),),
                            SizedBox(
                              width: 35,
                              height: 35,
                              child: Center(
                                child: CircleAvatar(
                                  backgroundColor: const Color.fromARGB(255, 56, 56, 56),
                                  child: IconButton(
                                    onPressed: (){
                                      setState(() {
                                        count += 1;
                                        price = widget.menu.price * count;

                                      });
                                    }, 
                                    icon: const Icon(
                                      FontAwesomeIcons.plus,
                                      color: Colors.white,
                                      size: 20,
                                    )
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10,),
                  SizedBox(
                    width: double.infinity,
                    height: 65,
                    child: MouseRegion(
                      onEnter: (_) => setState(() => color = AppPallete.buttonHoverColor),
                      onExit: (_) => setState(() => color = AppPallete.buttonColor),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255,248,124,52),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          
                        ),
                        onPressed: () async{
                          if(profil!.address! == "not set" || profil == null){
                            showCustomSnackBar("Daftar alamat dulu", "Daftarkan di profil", ContentType.warning);
                            return;
                          }
                          if(count > 0){
                            // final token = await Storage.readSecureData("personalToken");
                            // final id = await Storage.readSecureData("id");
                            // Order order = Order(user_id: int.parse(id!), restaurant_id: widget.menu.restaurant_id, total_price: price, status: "Pending");
                            // OrderItem item = OrderItem(order_id: 9, item_id: widget.menu.item_id, quantity: count, price: widget.menu.price);
                            // final data = Orderclient.createOrder(order, item, token!);
                            // print(data);
                            addToCart(widget.menu, count, price);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderPage()));
                                                  }
                        }, 
                        
                        child: const Text("ADD TO CART", style: TextStyle(fontFamily: "Sen", fontSize: 20, color: Colors.white), textAlign: TextAlign.center,)
                      ),
                    ),
                  ),
                  
                  
                ],
              ),
            ),
          )
              
            
          
        ],
      ),
    );
  }
}