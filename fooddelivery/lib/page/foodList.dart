import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fooddelivery/page/foodDetail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fooddelivery/entity/menu.dart';
import 'package:fooddelivery/client/menuClient.dart';
import 'package:fooddelivery/page/searchPage.dart';
import 'package:fooddelivery/util/storage.dart';
import 'package:fooddelivery/page/restaurantDetail.dart';
import 'package:fooddelivery/entity/restaurant.dart';
import 'package:fooddelivery/client/restaurantClient.dart';

final menuProvider = FutureProvider<List<Menu>>((ref) async {
  final token = await Storage.readSecureData('personalToken');
  return await Menuclient.getMenus(token!);
});

final restaurantProvider = FutureProvider<List<Restaurant>>((ref) async {
  final token = await Storage.readSecureData('personalToken');
  return await Restaurantclient.getRestaurant(token!);
});


class FoodList extends ConsumerWidget {
  final String categori;

  const FoodList({super.key, required this.categori});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menus = ref.watch(menuProvider);
    final restaurants = ref.watch(restaurantProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: IconButton(
                icon: const Icon(FontAwesomeIcons.angleLeft),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Wrap(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: IconButton(
                    icon: const Icon(FontAwesomeIcons.magnifyingGlass),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchPage(isFocused: true,)));
                    },
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: IconButton(
                    icon: const Icon(FontAwesomeIcons.sliders),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: menus.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (menus) => SingleChildScrollView(
         padding: const EdgeInsets.only(left: 5, right: 5),
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: const EdgeInsets.only(left: 20, right: 20),child: Text("Popular $categori", style: const TextStyle(fontFamily: "Sen", fontSize: 20, fontWeight: FontWeight.bold),)),
              const SizedBox(height: 2,),
              SizedBox(
                
                child: GridView.builder(
                  
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    
                    crossAxisSpacing: 40,
                    childAspectRatio: 0.6,
                    mainAxisSpacing: 20
                  ),
                  itemCount: categori == 'all' ? 4 : menus.where((element) => element.type == categori).toList().length,
                  itemBuilder: (context, index) {
                     final Menu menu;
                    if(categori == 'all'){
                      menu = menus[index];
                    }else{
                      menu = menus.where((element) => element.type == categori).toList()[index];
                    }
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FoodDetail(menu: menu,))),
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
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                                color: Colors.white,
                                image: DecorationImage(image: NetworkImage(menu.image_url), fit: BoxFit.cover),
                              ),
                            ),
                            
                            Text(menu.name, style: const TextStyle(fontFamily: "Sen", fontWeight: FontWeight.bold, fontSize: 20),),
                            Text(menu.restaurant.name, style: const TextStyle(fontFamily: "Sen", fontSize: 15),),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                               Text('Rp ${menu.price}', style: const TextStyle(fontFamily: "Sen", fontWeight: FontWeight.bold, fontSize: 18),),
                                
                                IconButton(
                                  onPressed: () {
                                    
                                  }, 
                                  icon: const Icon(FontAwesomeIcons.circlePlus, color: Colors.orange, size: 20),)
                              ],
                            ),
                            
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20,),
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
                child: restaurants.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                  data: (restaurant) => ListView.builder(
                    shrinkWrap: true, // Allows the ListView to take up only necessary space
                    physics: const NeverScrollableScrollPhysics(), // Prevent independent scrolling
                    itemCount: restaurant.length,
                    itemBuilder: (context, index) {
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height * 0.25,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(resto.logo_url),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: const BorderRadius.all(Radius.circular(18)),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                resto.name,
                                style: const TextStyle(
                                  fontFamily: "Sen",
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                "Burger - Chicken - Riche - Wings",
                                style: TextStyle(
                                  fontFamily: "Sen",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(FontAwesomeIcons.star, color: Colors.orange),
                                  const SizedBox(width: 10),
                                  Text(
                                    '${resto.rating}/10',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontFamily: "Sen",
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 30),
                                  const Icon(FontAwesomeIcons.clock, color: Colors.orange),
                                  const SizedBox(width: 10),
                                  Text(
                                    '${resto.openTime} - ${resto.closeTime}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontFamily: "Sen",
                                    ),
                                  ),
                                  const SizedBox(width: 30),
                                  const Icon(FontAwesomeIcons.clock, color: Colors.orange),
                                  const SizedBox(width: 10),
                                  const Text(
                                    "30 min",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: "Sen",
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 25),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
        
            ],
          ),
        ),
      ),  
    );
  }
}