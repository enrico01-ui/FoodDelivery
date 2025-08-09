import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fooddelivery/entity/menu.dart';
import 'package:fooddelivery/page/mapPage.dart';
import 'package:fooddelivery/entity/orderItem.dart';
import 'package:fooddelivery/entity/order.dart';
import 'package:fooddelivery/client/orderClient.dart';
import 'package:fooddelivery/util/storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final orderProvider = FutureProvider<List<Order>>((ref) async {
  final token = await Storage.readSecureData('personalToken');
  final id = await Storage.readSecureData('id');

  return await Orderclient.fetchOrderByUserId(token!, id!);
});

final orderItemProvider = FutureProvider.family<List<OrderItem>, String>((ref, orderId) async {
        final token = await Storage.readSecureData('personalToken');

        return await Orderclient.fetchOrderItem(token!, orderId);
      }); 
                                                                                                                                                            

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(orderProvider);
    });

  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(orderProvider);
    });
  }
  @override 
  Widget build(BuildContext context) {

    final orders = ref.watch(orderProvider);
    return DefaultTabController(
      
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
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
                  const Padding(padding: EdgeInsets.only(top: 5),child: Text("My Orders", style: TextStyle(color: Colors.black, fontSize: 20, fontFamily: "Sen", fontWeight: FontWeight.bold),textAlign: TextAlign.center,)),
                  
                ]
              ),
              GestureDetector(
                onTap: (){

                },
                child: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: const Icon(
                    FontAwesomeIcons.ellipsis,
                    color: Colors.black,
                  ),
                ),
              )

            ],
          ),
          bottom: const TabBar(
            indicatorColor: Colors.orange,
            unselectedLabelColor: Colors.grey,
            labelColor: Colors.orange,
            labelStyle: TextStyle(fontFamily: "Sen", fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: "Ongoing",),
              Tab(text: "History"),
            ]
          ),
        ),
        body: orders.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
          data: (order) {
            
            return TabBarView(
             
            children: [
              // Content for the "Ongoing" tab
              ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: order.where((order) => order.status == "Pending").length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final isiOrder = order.where((order) => order.status == "Pending").toList()[index];
                  final orderItems = ref.watch(orderItemProvider(isiOrder.id!.toString()));
                  return Container(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    height: 233,
                    width: double.infinity,
                    child: orderItems.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Center(child: Text('Error: $error')),
                      data: (item) {

                        List<OrderItem> oItem = item.where((order) => order.order_id == isiOrder.id ).toList();
                        return  Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              "food",
                              style: TextStyle(
                                  fontFamily: "Sen",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          const Divider(height: 2, color: Colors.grey),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      oItem.first.menus?.restaurant.logo_url == null ? "Null Logo" : oItem.first.menus!.restaurant.logo_url,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(oItem[0].menus?.restaurant.name == null ? "Null Name" : oItem.first.menus!.restaurant.name,
                                        style: const TextStyle(
                                            fontFamily: "Sen",
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Text(
                                          "Rp. ${oItem.first.orders?.total_price == null ? "Null Price" : oItem.first.orders!.total_price}",
                                          style: const TextStyle(
                                              fontFamily: "Sen",
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 15),
                                        const Text("|"),
                                        const SizedBox(width: 15),
                                        Text(
                                          oItem.length.toString(),
                                          style: const TextStyle(
                                              fontFamily: "Sen",
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 15),
                                    
                                  ],
                                ),
                              ),
                              
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () async{
                                  final List<Menu> menu = oItem.map((element) {
                                    return element.menus!;
                                  }).toList();
                                  await Navigator.push(context, MaterialPageRoute(builder: (context) => MapPage(menu: menu, order: oItem.first.orders!)));
                                  ref.invalidate(orderProvider); 
                                  
                                },
                                style: ElevatedButton.styleFrom(
                                  fixedSize: const Size(153, 20),
                                  backgroundColor: Colors.orange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  "Track Order",
                                  style: TextStyle(
                                      fontFamily: "Sen",
                                      fontSize: 16,
                                      color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 50),
                              ElevatedButton(
                                
                                onPressed: () async{
                                  final token = await Storage.readSecureData('personalToken');

                                  final result = await Orderclient.deleteOrder(token!, oItem.first.order_id.toString());

                                  if(result == "Order deleted successfully"){
                                    ref.refresh(orderProvider);
                                    final snackBar = SnackBar(
                                      /// need to set following properties for best effect of awesome_snackbar_content
                                      elevation: 0,
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.transparent,
                                      content: AwesomeSnackbarContent(
                                        title: 'Successfully Cancel Order',
                                        message:
                                            'Order has been cancelled',

                                        /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                                        contentType: ContentType.success,
                                      ),
                                    );

                                    ScaffoldMessenger.of(context)
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(snackBar);
                                    
                                    return;
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  fixedSize: const Size(153, 20),
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.orange),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(
                                      fontFamily: "Sen",
                                      fontSize: 18,
                                      color: Colors.orange),
                                ),
                              ),
                            ],
                          )
                        ],
                      );
                    },
                    ),
                  );
                },
              ),
          
              // Content for the "History" tab
              ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: order.where((order) => order.status == "Delivered").length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final isiOrder = order.where((order) => order.status == "Delivered").toList()[index];
                  final orderItems = ref.watch(orderItemProvider(isiOrder.id!.toString()));
                  return Container(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    height: 233,
                    width: double.infinity,
                    child: orderItems.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Center(child: Text('Error: $error')),
                      data: (item) { 
                        final oItem = item.where((order) => order.order_id == isiOrder.id).toList();

                        return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              "Food",
                              style: TextStyle(
                                  fontFamily: "Sen",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          const Divider(height: 2, color: Colors.grey),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      oItem.first.menus?.restaurant.logo_url == null ? "Null Logo" : oItem.first.menus!.restaurant.logo_url,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(oItem[0].menus?.restaurant.name == null ? "Null Name" : oItem.first.menus!.restaurant.name,
                                        style: const TextStyle(
                                            fontFamily: "Sen",
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Text(
                                          "Rp. ${oItem.first.orders?.total_price == null ? "Null Price" : oItem.first.orders!.total_price}",
                                          style: const TextStyle(
                                              fontFamily: "Sen",
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 15),
                                        const Text("|"),
                                        const SizedBox(width: 15),
                                        Text(
                                          oItem.length.toString(),
                                          style: const TextStyle(
                                              fontFamily: "Sen",
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 15),
                                    
                                  ],
                                ),
                              ),
                              
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  fixedSize: const Size(153, 20),
                                  backgroundColor: Colors.orange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  "Track Order",
                                  style: TextStyle(
                                      fontFamily: "Sen",
                                      fontSize: 16,
                                      color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 50),
                              ElevatedButton(
                                
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  fixedSize: const Size(153, 20),
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.orange),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(
                                      fontFamily: "Sen",
                                      fontSize: 18,
                                      color: Colors.orange),
                                ),
                              ),
                            ],
                          )
                        ],
                      );
                      }
                    ),
                  );
                },
              ),
            ],
          );
          },
        ),

      ),
    );
  }
}