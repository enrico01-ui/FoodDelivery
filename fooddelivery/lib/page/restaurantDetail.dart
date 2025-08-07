import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fooddelivery/util/storage.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:fooddelivery/entity/restaurant.dart';
import 'dart:async';
import 'package:fooddelivery/page/foodDetail.dart';
import 'package:fooddelivery/entity/menu.dart';
import 'package:fooddelivery/client/menuClient.dart';

final menuProvider = FutureProvider<List<Menu>>((ref) async {
  final token = await Storage.readSecureData('personalToken');
  return await Menuclient.getMenus(token!);
});

class RestaurantDetail extends ConsumerStatefulWidget {
  final Restaurant resto;
  const RestaurantDetail({super.key, required this.resto});

  @override
  ConsumerState<RestaurantDetail> createState() => _RestaurantDetailState();
}

class _RestaurantDetailState extends ConsumerState<RestaurantDetail> {
  final currentPageNotifier = ValueNotifier<int>(0);
  final int _active = 0;
  final PageController _pageController = PageController(initialPage: 0);
  Timer? _timer;
  late List<Widget> _pages;
  int selectedIndex = 0;
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

  

  final List<String> images = [
    "https://lh3.googleusercontent.com/p/AF1QipNNR2bTSHtmUVwJAU-X8BSzJmjVnhpPOayADwfU=s680-w680-h510",
    "https://lh3.googleusercontent.com/p/AF1QipNrWi3OCWQUePkZt9iAMxMwTfRIH1Fb5O7-llOA=s680-w680-h510",
    "https://lh3.googleusercontent.com/p/AF1QipOyXC8U8DSM-bcyovAf-JWxEFVrKbpe0lI5newn=s680-w680-h510",
    "https://lh3.googleusercontent.com/p/AF1QipOwDH3nQUTPpNq3jvE_fjCof4RCp6KolY3abNnp=s680-w680-h510",
    "https://lh3.googleusercontent.com/p/AF1QipPC3DLsZ-kIPG0H42gtklyxcLm43ExiDXKZAeAK=s680-w680-h510"
  ];

  @override
  void initState(){
    super.initState();
    _pages = List.generate(images.length, (index) => Image(image: NetworkImage(images[index]), fit: BoxFit.fill,));
  }

  @override
  Widget build(BuildContext context) {
    final menus = ref.watch(menuProvider);

    final List<String> categories = menus.when(
      loading: () => [],
      error: (error, stack) => [],
      data: (menu) {
        
        return menu.where((element) => element.restaurant.id == widget.resto.id).map((e) => e.type).toSet().toList();
      }
    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: menus.when(
        loading: () => const Center(child: CircularProgressIndicator(),),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (menu) {
          
          
          return Stack(
          children: [
            Padding(
              padding:const EdgeInsets.only(bottom: 10),
              child: SingleChildScrollView(
                
                scrollDirection: Axis.vertical,
                child:  Column(
                  
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)), 
                          child: SizedBox(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.35,
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(image: NetworkImage(widget.resto.logo_url), fit: BoxFit.cover),
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                              ),
                            )
                          ),
                        ),
                        
                      ],
                    ),
                    const SizedBox(height: 20,),
                    Row(
                      
                      children: [
                        const SizedBox(width: 18,),
                        const Icon(
                          FontAwesomeIcons.star,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 10,),
                        const Text(
                          "4.7",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: "Sen",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 30,),
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
                        const SizedBox(width: 30,),
                        const Icon(
                          FontAwesomeIcons.clock,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 10,),
                        Text(
                          '${widget.resto.openTime} - ${widget.resto.closeTime}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: "Sen",
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15, left: 18, right: 15, bottom: 5),
                      child: Text(
                        widget.resto.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontFamily: "Sen",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 15,),
                    Padding(
                      padding: const EdgeInsets.only(left: 18, right: 18, bottom: 5),
                      child: Text(
                        widget.resto.description,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Sen",
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20,),
                    Padding(
                      padding: const EdgeInsets.only(left: 18, right: 18, bottom: 5),
                      child: SizedBox(
                        
                        height: 50, // Height for the category selector
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final isSelected = index == selectedIndex;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIndex = index; // Update the selected category
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 10), // Space between categories
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.orange : Colors.white, // Highlight selected
                                  borderRadius: BorderRadius.circular(20), // Rounded corners
                                  border: Border.all(
                                    color: Colors.grey.shade300, // Border for unselected items
                                    width: 1.0,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    categories[index],
                                    style: TextStyle(
                                      fontFamily: 'Sen',
                                      fontSize: 14,
                                      color: isSelected ? Colors.white : Colors.black, // Adjust text color
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: Column(
                        children: categories.map(
                          
                          (categori) {
                            //sesuai categry
                            return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 18, right: 18, bottom: 5, top: 20),
                                    child: Text(
                                      categori,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontFamily: "Sen",
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    child: menus.when(
                                      loading: () => const Center(child: CircularProgressIndicator()),
                                      error: (error, stack) => Center(child: Text('Error: $error')),
                                      data: (menu) {
                                        
                                        final filteredMenu = menu
                                            .where((element) =>
                                                element.restaurant_id == widget.resto.id &&
                                                element.type == categori)
                                            .toList();
                                        print("Filtered menu for $categori: ${filteredMenu.length}");
                                        
                                        if (filteredMenu.isEmpty) {
                                          return const Center(child: Text('No items found'));
                                        }

                                        return GridView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 40,
                                            childAspectRatio: 0.6,
                                            mainAxisSpacing: 20,
                                          ),
                                          itemCount: filteredMenu.length,
                                          itemBuilder: (context, index) {
                                            final food = filteredMenu[index]; // Access food safely
                                            return GestureDetector(
                                              onTap: () {
                                                // Navigate to FoodDetail or perform any action
                                              },
                                              child: Container(
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
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      height: 110,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(20),
                                                        image: DecorationImage(
                                                          image: NetworkImage(food.image_url),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                      child: Text(
                                                        food.name,
                                                        style: const TextStyle(
                                                          fontFamily: "Sen",
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                      child: Text(
                                                        food.restaurant.name,
                                                        style: const TextStyle(
                                                          fontFamily: "Sen",
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            "Rp ${food.price}",
                                                            style: const TextStyle(
                                                              fontFamily: "Sen",
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                          IconButton(
                                                            onPressed: () {
                                                              Navigator.push(context, MaterialPageRoute(builder: (context) => FoodDetail(menu: food)));
                                                            },
                                                            icon: const Icon(
                                                              FontAwesomeIcons.circlePlus,
                                                              color: Colors.orange,
                                                              size: 20,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),

                                ],
                              );
                            
                          }
                        ).toList(),
                      ),
                    ),
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
                        icon: const Icon(FontAwesomeIcons.ellipsis, color: Colors.white,),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              )
            ),
          ],
        );
        }
      ),
    );
  }
}