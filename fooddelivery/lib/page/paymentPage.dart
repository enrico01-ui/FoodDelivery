import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fooddelivery/client/orderClient.dart';
import 'package:fooddelivery/entity/menu.dart';
import 'package:fooddelivery/entity/order.dart';
import 'package:fooddelivery/entity/orderItem.dart';
import 'package:fooddelivery/page/congratsPage.dart';
import 'package:fooddelivery/util/storage.dart';

class PaymentPage extends StatefulWidget {
  final List<Menu> menuList;
  const PaymentPage({super.key, required this.menuList});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}


class _PaymentPageState extends State<PaymentPage> {
  bool isLoading = false;

  // List<String> paymentMethods = [
  //   'Cash',
  //   'Credit Card',
  //   'Debit Card',
  //   'Net Banking',
  //   'UPI',
  //   'Wallets',
  // ];

  List<Map<String, dynamic>> paymentMethods = [
    {
      "icon": FontAwesomeIcons.moneyBillWave,
      "name": "Cash",
    },
    {
      "icon": FontAwesomeIcons.creditCard,
      "name": "Credit Card",
    },
    {
      "icon": FontAwesomeIcons.creditCard,
      "name": "Debit Card",
    },
    {
      "icon": FontAwesomeIcons.internetExplorer,
      "name": "Net Banking",
    },
    {
      "icon": FontAwesomeIcons.wallet,
      "name": "Wallets",
    },

  ];
  void showCustomSnackBar(BuildContext context, String title, String message, ContentType type) {
    
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      backgroundColor: Colors.transparent,// Ensure snackbar is displayed
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20), 
          child: Row(
            children: [
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  child: const Icon(FontAwesomeIcons.angleLeft),
                ),
              ),
              const SizedBox(width: 20),
              const Text("Payment", style: TextStyle(fontSize: 20, fontFamily: "Sen", fontWeight: FontWeight.bold)),
            ],
          )),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: paymentMethods.length,
              itemBuilder: (context, index) {
                return Material(
                  color: Colors.white, // Background color of the chip
                  borderRadius: BorderRadius.circular(20),
                  child: Ink(
                    
                    color: Colors.white,
                    child: InkWell(
                      splashColor: Colors.grey[200],

                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            const SizedBox(width: 20),
                            Container(
                              width: 115,
                              height: 75,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(paymentMethods[index]['icon'], color: Colors.orange, size: 50.0,),
                            ),
                            const SizedBox(width: 20),
                            Text(paymentMethods[index]['name'], style: const TextStyle(fontSize: 20, fontFamily: "Sen", fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                            
                          ],
                        ),
                      ),
                    )
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child:Text(
              "Total: Rp.${widget.menuList.map((e) => e.totalPrice!).reduce((value, element) => value + element)}",
              style: const TextStyle(fontSize: 20, fontFamily: "Sen", fontWeight: FontWeight.bold),
            )
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: ElevatedButton(
              
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                minimumSize: Size(MediaQuery.of(context).size.width, 50),
              ),
              onPressed: () async{
                try {
                  final price = widget.menuList.map((e) => e.totalPrice!).reduce((value, element) => value + element);
                  final count = widget.menuList.map((e) => e.totalCount!).reduce((value, element) => value + element);
                  final token = await Storage.readSecureData("personalToken");
                  final id = await Storage.readSecureData("id");
                  OrderItem? orderI;
                  if (token == null || id == null) {
                    print("Error: Missing token or user ID");
                    return;
                  }

                  Order order = Order(
                    user_id: int.parse(id),
                    restaurant_id: widget.menuList.first.restaurant_id,
                    total_price: price,
                    status: "Pending",
                  );
                  
                  setState(() {
                    isLoading = true;
                  });
                  
                  final data = await Orderclient.createOrder(order, token);
                  
                  if (data.id == null) {
                    print("Error: Order creation failed, order ID is null");
                    return;
                  }

                  for (var menu in widget.menuList) {
                    if (menu.totalPrice == null) {
                      print("Error: Menu item total price is null for item ${menu.item_id}");
                      continue;
                    }

                    OrderItem item = OrderItem(
                      order_id: data.id!,
                      item_id: menu.item_id,
                      quantity: menu.totalCount!,
                      price: menu.totalPrice!,
                    );

                    try {
                      orderI = await Orderclient.createItem(item, token);
                    } catch (e) {
                      print("Error creating order item for item ${menu.item_id}: $e");
                    }
                  }
                  setState(() {
                    isLoading = false;
                  });
                  if (orderI?.orders != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Congratspage(
                          menuList: widget.menuList,
                          order: orderI!.orders!,
                        ),
                      ),
                    );
                  } else {
                    print("Error: orderI.orders is null");
}
                } catch (e) {
                  print("Error: $e");
                }
                
              },
              child: !isLoading ? const Text("Proceed to Payment", style: TextStyle(fontSize: 20, fontFamily: "Sen", fontWeight: FontWeight.bold)) : const CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}
