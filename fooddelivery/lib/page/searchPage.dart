import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fooddelivery/util/storage.dart';
import 'package:fooddelivery/entity/menu.dart';
import 'package:fooddelivery/entity/restaurant.dart';
import 'package:fooddelivery/client/menuClient.dart';
import 'package:fooddelivery/client/restaurantClient.dart';

final menuProvider = FutureProvider<List<Menu>>((ref) async {
  final token = await Storage.readSecureData('personalToken');
  return await Menuclient.getMenus(token!);
});

final restaurantProvider = FutureProvider<List<Restaurant>>((ref) async {
  final token = await Storage.readSecureData('personalToken');
  return await Restaurantclient.getRestaurant(token!);
});

class SearchPage extends ConsumerStatefulWidget {
  final bool isFocused;
  const SearchPage({super.key, this.isFocused = false});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late FocusNode _focusNode;
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    TextEditingController controller = TextEditingController();
    if (widget.isFocused){
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus(); // Focus the search bar and show the keyboard
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> images = [
    {
      "image": "https://lh3.googleusercontent.com/p/AF1QipNNR2bTSHtmUVwJAU-X8BSzJmjVnhpPOayADwfU=s680-w680-h510",
      "Restaurant": "Rose Garden Restaurant"
    },
    {
      "image": "https://lh3.googleusercontent.com/p/AF1QipNrWi3OCWQUePkZt9iAMxMwTfRIH1Fb5O7-llOA=s680-w680-h510",
      "Restaurant": "Tasty Treat Gallery"
    },
    {
      "image": "https://lh3.googleusercontent.com/p/AF1QipOyXC8U8DSM-bcyovAf-JWxEFVrKbpe0lI5newn=s680-w680-h510",
      "Restaurant": "Spicy Restaurant"
    },
    {
      "image": "https://lh3.googleusercontent.com/p/AF1QipOwDH3nQUTPpNq3jvE_fjCof4RCp6KolY3abNnp=s680-w680-h510",
      "Restaurant": "Junk Junk Wings"
    },
    {
      "image": "https://lh3.googleusercontent.com/p/AF1QipPC3DLsZ-kIPG0H42gtklyxcLm43ExiDXKZAeAK=s680-w680-h510",
      "Restaurant": "The Rock Burger"
    }
    ,

  ];

  final List<Map<String, dynamic>> foods = [
    {
      "image": "https://img.pikbest.com/origin/09/16/91/01PpIkbEsTRGp.png!sw800",
      "food": "Papa John's Pizza"
    },
    {
      "image": "https://www.foodandwine.com/thmb/DI29Houjc_ccAtFKly0BbVsusHc=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/crispy-comte-cheesburgers-FT-RECIPE0921-6166c6552b7148e8a8561f7765ddf20b.jpg",
      "food": "MC Donald's Burger"
    },
    {
      "image": "https://www.southernliving.com/thmb/UW4kKKL-_M3WgP7pkL6Pb6lwcgM=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/Ham_Sandwich_011-1-49227336bc074513aaf8fdbde440eafe.jpg",
      "food": "Sandwich"
    },
    {
      "image": "https://thecozycook.com/wp-content/uploads/2022/04/Lasagna-Recipe-f.jpg",
      "food": "Lasagna"
    },
    {
      "image": "https://static01.nyt.com/images/2024/06/28/multimedia/28GRILL-HOTDOGS-REX-cqwj/01GRILL-HOTDOGS-REX-cqwj-mediumSquareAt3X.jpg",
      "food": "Hot Dogs"
    }
    ,

  ];

  @override
  Widget build(BuildContext context) {
    final menus = ref.watch(menuProvider);
    final restaurants = ref.watch(restaurantProvider);
    return  Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Wrap(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    child: const Icon(
                      FontAwesomeIcons.arrowLeft,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Padding(padding: EdgeInsets.only(top: 5),child: Text("Search", style: TextStyle(color: Colors.black, fontSize: 20, fontFamily: "Sen", fontWeight: FontWeight.bold),textAlign: TextAlign.center,)),
                
              ]
            ),
            
            CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: Stack(
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.black,
                  ),
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
            
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: restaurants.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (restaurant) => SingleChildScrollView(
          padding: const EdgeInsets.only(left: 20, right: 20),
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              TextField(
                focusNode: _focusNode,
                onChanged: (value) => setState(() {
                  searchController.text = value;
                }),
                controller: searchController,
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
              const SizedBox(height: 10),
              if (searchController.text.isEmpty) Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Keywords',
                    style: TextStyle(
                      fontFamily: 'Sen',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 40, // Adjust height for better alignment
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5, // Replace with the actual count of recent keywords
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10), // Add space between keywords
                          child: Material(
                            color: Colors.white, // Background color of the chip
                            borderRadius: BorderRadius.circular(20),
                            child: Ink(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.grey.shade300, // Border color
                                  width: 1.0, // Border width
                                ),
                                borderRadius: BorderRadius.circular(20), // Rounded corners
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                splashColor: Colors.grey.withOpacity(0.3), // Ripple effect
                                onTap: () {
                                  setState(() {
                                    searchController.text = 'Keyword $index'; // Replace with actual keyword
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  child: Center(
                                    child: Text(
                                      'Keyword $index', // Replace with actual keyword
                                      style: const TextStyle(
                                        fontFamily: 'Sen',
                                        fontSize: 14,
                                        color: Colors.black, // Adjust text color as needed
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
        
        
        
                  const SizedBox(height: 20),
                  const Text(
                    'Suggested Restaurant',
                    style: TextStyle(
                      fontFamily: 'Sen',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10,),
                  SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: ListView.builder(
                      shrinkWrap: true, // Allows the ListView to take up only necessary space
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: restaurant.length,
                      itemBuilder: (context, index){
                        final resto = restaurant[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  image: NetworkImage(resto.logo_url),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  resto.name,
                                  style: const TextStyle(
                                    fontFamily: 'Sen',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
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
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 25,),
                  const Text(
                    'Popular Food',
                    style: TextStyle(
                      fontFamily: 'Sen',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height*0.6,
                    child: menus.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Center(child: Text('Error: $error')),
                      data: (menu) => GridView.builder(
                        shrinkWrap: true, // Allows the ListView to take up only necessary space
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          
                          crossAxisSpacing: 40,
                          childAspectRatio: 0.6,
                          mainAxisSpacing: 20
                        ),
                        itemCount: menu.length,
                        itemBuilder: (context, index) {
                          final food = menu[index];
                          return GestureDetector(
                            // onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FoodDetail())),
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
                                    height: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                                      image: DecorationImage(
                                        image: NetworkImage(food.image_url),
                                        fit: BoxFit.fill,
                                    ),
                                  )),
                                  
                                  Padding(padding: const EdgeInsets.only(left: 10),child: Text(food.name, style: const TextStyle(fontFamily: "Sen", fontWeight: FontWeight.bold, fontSize: 20),)),
                                  Padding(padding: const EdgeInsets.only(left: 10),child: Text(food.restaurant.name, style: const TextStyle(fontFamily: "Sen", fontSize: 15),)),
                                  
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ) else Column(
                children: [
                  SizedBox(
                    
                    child: menus.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Center(child: Text('Error: $error')),
                      data: (menu) => ListView.builder(
                        
                        shrinkWrap: true, // Allows the ListView to take up only necessary space
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        itemCount: menu.where((element) => element.name.toLowerCase().contains(searchController.text.toLowerCase())).length,
                        itemBuilder: (context, index) {
                          final food = menu.where((element) => element.name.toLowerCase().contains(searchController.text.toLowerCase())).toList()[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: GestureDetector(
                              // onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FoodDetail())),
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
                                  
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 200,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                                        image: DecorationImage(
                                          image: NetworkImage(food.image_url),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    
                                    Padding(padding: const EdgeInsets.only(left: 10, top: 10),child: Text(food.name, style: const TextStyle(fontFamily: "Sen", fontWeight: FontWeight.bold, fontSize: 20),)),
                                    Padding(padding: const EdgeInsets.only(left: 10),child: Text(food.restaurant.name, style: const TextStyle(fontFamily: "Sen", fontSize: 15),)),
                                    const SizedBox(height: 20,),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              
            ],
          ),
        ),
      ) 
    );
  }
}

// class CustomSearchDelegate extends SearchDelegate {
//   final String search;
//   CustomSearchDelegate({this.search = ''});
//   List<String> recentSearches = ['Burger', 'Pizza', 'Pasta', 'Fried Chicken', 'Ice Cream'];

//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: const Icon(Icons.clear),
//         onPressed: () {
//           query = search;
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
//     List<String> matchQuery = [];

//     for(var recent in recentSearches){
//       if(recent.toLowerCase().contains(query.toLowerCase())){
//         matchQuery.add(recent);
//       }
//     }

//     return ListView.builder(
//       itemCount: matchQuery.length,
//       itemBuilder: (context, index){
//         return ListTile(
//           title: Text(matchQuery[index]),
//           onTap: () {
//             query = matchQuery[index];
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     List<String> matchQuery = [];

//     for(var recent in recentSearches){
//       if(recent.toLowerCase().contains(query.toLowerCase())){
//         matchQuery.add(recent);
//       }
//     }

//     return ListView.builder(
//       itemCount: matchQuery.length,
//       itemBuilder: (context, index){
//         return ListTile(
//           title: Text(matchQuery[index]),
//           onTap: () {
//             query = matchQuery[index];
//           },
//         );
//       },
//     );
//   }
// }