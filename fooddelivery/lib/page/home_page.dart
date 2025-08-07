import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fooddelivery/client/orderClient.dart';
import 'package:fooddelivery/entity/order.dart';
import 'package:fooddelivery/entity/profil.dart';
import 'package:fooddelivery/page/foodList.dart';
import 'package:fooddelivery/page/restaurantDetail.dart';
import 'package:fooddelivery/page/searchPage.dart';
import 'package:fooddelivery/drawer/sidebar.dart';
import 'package:fooddelivery/page/cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fooddelivery/entity/menu.dart';
import 'package:fooddelivery/client/menuClient.dart';
import 'package:fooddelivery/client/restaurantClient.dart';
import 'package:fooddelivery/entity/restaurant.dart';
import 'package:fooddelivery/util/constant.dart'; 
import 'package:fooddelivery/util/storage.dart';

final restaurantProvider = FutureProvider<List<Restaurant>>((ref) async {
  final token = await Storage.readSecureData('personalToken');
  return await Restaurantclient.getRestaurant(token!);
});

final menuProvider = FutureProvider<List<Menu>>((ref) async {
  final token = await Storage.readSecureData('personalToken');
  return await Menuclient.getMenus(token!);
});

final orderProvider = FutureProvider<List<Order>>((ref) async {
  final token = await Storage.readSecureData('personalToken');
  final id = await Storage.readSecureData('id');
  return await Orderclient.fetchOrderByUserId(token!, id!);
});

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String? token;
  Profil? profil;


  getEmail(String token, String? name) async {
    var url = Uri.http(baseIp, 'api/getDataUser');
    var data = jsonEncode({'name': name});
    var response = await http.post(
      url,
      body: data,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print(response.body);
    return jsonDecode(response.body);
  }
  void _loadprofil() async {
    try {
      String? username = await Storage.readSecureData('name');
      token = await Storage.readSecureData('personalToken') ?? 'empty';
      
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
      var data =
          await getEmail(token!, username).timeout(const Duration(seconds: 30));
      String email = data['email'];

      final profilData = await getProfil(token, email).timeout(const Duration(seconds: 30));
      profil = Profil.fromJson(profilData);
    } on TimeoutException catch (_) {
      token = null;
      
    } catch (e) {
      token = null;
      String? testUsername = await Storage.readSecureData('name');
      print("name : $testUsername");

      throw Exception("error: $e");
    }
  }

  Future<Map<String, dynamic>> getProfil(String token, String email) async{
    var endpoint = 'api/profil';
    var url = Uri.http(baseIp, endpoint);
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

  String selectedLocation = 'Halal Lab Office';
  final List<String> location = [
    'Halal Lab Office',
    'Jakarta',
    'Bosa',
    'AtmaJaya',
    'Legion Cell',
  ];

  
  // final List<Map<String, dynamic>> images = [
  //   {
  //     "image": "https://lh3.googleusercontent.com/p/AF1QipNNR2bTSHtmUVwJAU-X8BSzJmjVnhpPOayADwfU=s680-w680-h510",
  //     "Restaurant": "Rose Garden Restaurant"
  //   },
  //   {
  //     "image": "https://lh3.googleusercontent.com/p/AF1QipNrWi3OCWQUePkZt9iAMxMwTfRIH1Fb5O7-llOA=s680-w680-h510",
  //     "Restaurant": "Tasty Treat Gallery"
  //   },
  //   {
  //     "image": "https://lh3.googleusercontent.com/p/AF1QipOyXC8U8DSM-bcyovAf-JWxEFVrKbpe0lI5newn=s680-w680-h510",
  //     "Restaurant": "Spicy Restaurant"
  //   },
  //   {
  //     "image": "https://lh3.googleusercontent.com/p/AF1QipOwDH3nQUTPpNq3jvE_fjCof4RCp6KolY3abNnp=s680-w680-h510",
  //     "Restaurant": "Junk Junk Wings"
  //   },
  //   {
  //     "image": "https://lh3.googleusercontent.com/p/AF1QipPC3DLsZ-kIPG0H42gtklyxcLm43ExiDXKZAeAK=s680-w680-h510",
  //     "Restaurant": "The Rock Burger"
  //   }
  //   ,

  // ];
  TextEditingController searchController = TextEditingController();

  @override
  void initState(){
    super.initState();
    _loadprofil();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(orderProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = ref.watch(restaurantProvider);
    final menus = ref.watch(menuProvider);
    final orders = ref.watch(orderProvider);
    final List<String> categories = menus.when(
      loading: () => [],
      error: (error, stack) => [],
      data: (menu) {
        
        return menu.map((e) => e.type).toSet().toList();
      }
    );
    
    return Scaffold(
      drawer: Sidebar(name: profil == null 
      ? "not set"
      : profil?.user.name, bio: profil?.bio),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Wrap(
              children: [
                Builder(
                  builder: (context) {
                    return GestureDetector(
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        child: const Icon(
                          FontAwesomeIcons.barsStaggered,
                          color: Colors.black,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivery to',
                      style: TextStyle(
                        fontFamily: "Sen",
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 15,
                      ),
                    ),
                    Row(
                      children: [Text(
                        selectedLocation,
                        style: const TextStyle(
                          fontFamily: "Sen",
                          fontSize: 15,
                          color: Colors.grey
                        ),
                      ),
                      const Icon(FontAwesomeIcons.caretDown)
                      ],
                    ),
                    
                  ],
                ),
                
              ]
            ),
            
            GestureDetector(
              onTap: () async{
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CartPage()));
                // Simulate a network call/ Refresh the page
  
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: Stack(
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.black,
                    ),
                    Positioned(
                      right: 0,
                      child: orders.when(
                        loading: () => const SizedBox(),
                        error: (error, stack) => const SizedBox(),
                        data: (order) => order.where((order) => order.status == "Pending").isNotEmpty ? Container(
                          
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            
                          ),
                          child: Text(
                            order.where((order) => order.status == "Pending").length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ) : const SizedBox()
                      ),
                    ),
                  ],
                ),
              ),
            )
            
          ],
        ),
      ),
      body: profil != null? restaurant.when(
        
        loading: () {
          
          debugPrint("Loading restaurants...");
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stack) {
          debugPrint("Error loading restaurants: $error");
          return Center(child: Text('Error: $error'));
        },
        data: (restaurant) { 
          String name = profil?.user.name.split(" ")[0] ?? "User";
          return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          scrollDirection: Axis.vertical,
          child: Column(
            
            children: [
              Row(
                children: [
                  Text(
                    "Hey $name, ",
                    style: const TextStyle(
                      fontSize: 25,
                      fontFamily: "Sen",
                      color: Colors.black,
                    ),
                  ),
                  const Text(
                    'Good Morning',
                    style: TextStyle(
                      fontSize: 25,
                      fontFamily: "Sen",
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchPage(isFocused: true,)));
                },
                controller: searchController,
                readOnly: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: 'Search',
                  hintStyle: const TextStyle(
                    fontFamily: 'Sen',
                    color: Colors.black,
                  ),
                  
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none
                  ),
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'All Categories',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: "Sen",
                      color: Colors.black,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FoodList(categori: "all",))),
                      child: const Row(
                        
                        children: [
                          Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: "Sen",
                              color: Colors.orange,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    ),
                  )
          
                ],
              ),
              const SizedBox(height: 10,),
              Container(
                height: 210,
                color: Colors.white,
                child: menus.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                  data: (menu) {
                    // Filter menu berdasarkan kategori
                    final foodsByCategory = categories.map((category) {
                      return menu.where((item) => item.type == category).toList();
                    }).toList();

                    // Pastikan categories dan foodsByCategory memiliki data
                    if (categories.isEmpty || foodsByCategory.isEmpty) {
                      return const Center(child: Text("No categories or menu items available"));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(5),
                      scrollDirection: Axis.horizontal,
                      itemCount: foodsByCategory.length,
                      itemBuilder: (context, index) {
                        // Mendapatkan data makanan berdasarkan kategori
                        final foodList = foodsByCategory[index];
                        
                        // Jika kategori tidak memiliki makanan, tampilkan placeholder
                        if (foodList.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.35,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 0,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  "No items",
                                  style: TextStyle(
                                    fontFamily: "Sen",
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        // Mengambil makanan pertama dalam kategori untuk ditampilkan
                        final food = foodList.first;

                        return Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => FoodList(categori: food.type,)));
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.35,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 0,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Gambar Makanan
                                  Container(
                                    height: 110, // Atur tinggi gambar
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                      image: DecorationImage(
                                        image: NetworkImage(food.image_url),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  // Nama Kategori
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10, top: 8),
                                    child: Text(
                                      food.type,
                                      style: const TextStyle(
                                        fontFamily: "Sen",
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // Informasi Harga
                                  Row(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Text(
                                          "Starting",
                                          style: TextStyle(
                                            fontFamily: "Sen",
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        "\$${food.price}",
                                        style: const TextStyle(
                                          fontFamily: "Sen",
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 25,),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Open Restaurant',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: "Sen",
                      color: Colors.black,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Row(
                      children: [
                        Text(
                          'View All',
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: "Sen",
                            color: Colors.orange,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  )
          
                ],
              ),
              const SizedBox(height: 20,),
              SizedBox(
                
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: restaurant.length,
                  itemBuilder: (context, index){
                    final resto = restaurant[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => RestaurantDetail(resto: resto,)));
                      },
                      child: Container(

                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          color: Colors.white,
                        ),
                        
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.25,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(image: NetworkImage(resto.logo_url), fit: BoxFit.cover),
                                borderRadius: const BorderRadius.all(Radius.circular(18))
                                ,
                              ),
                            ),
                            const SizedBox(height: 15,),
                            Text(resto.name, style: const TextStyle(fontFamily: "Sen", fontSize: 22, fontWeight: FontWeight.bold, ),),
                            const SizedBox(height: 15,),
                            const Text("Burger - Chicken - Riche - Wings", style: TextStyle(fontFamily: "Sen", fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),),
                            const SizedBox(height: 18,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  FontAwesomeIcons.star,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 10,),
                                Text(
                                  '${resto.rating}/10',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: "Sen",
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 30,),
                                const Icon(
                                  FontAwesomeIcons.clock,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 10,),
                                Text(
                                  '${resto.openTime} - ${resto.closeTime}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: "Sen",
                                  ),
                                ),
                                const SizedBox(width: 15,),
                                const Icon(
                                  FontAwesomeIcons.truckFast,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 10,),
                                const Text(
                                  "Free",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: "Sen",
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 25,)
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        );
        }
      ) : const Center(child: CircularProgressIndicator()),
    );
  }

  
}

// class CustomSearchDelegate extends SearchDelegate {
//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: const Icon(Icons.clear),
//         onPressed: () {
//           query = '';
//         },
//       )
//     ];
//   }

//   @override
//   Widget buildLeading(BuildContext context) {
//     return IconButton(
//       icon: const Icon(Icons.arrow_back),
//       onPressed: () {
//         close(context, null);
//       },
//     );
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     return Container();
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     return Container();
//   }
// }