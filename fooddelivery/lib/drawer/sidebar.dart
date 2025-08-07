import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fooddelivery/page/cart.dart';
import 'package:fooddelivery/page/profil.dart';

class Sidebar extends StatelessWidget {
  final String? name, bio;
  const Sidebar({super.key, this.name, this.bio});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.48,
      backgroundColor: Colors.deepOrange[600],
      child: ListView(
        
        children: [
          
          UserAccountsDrawerHeader(
            
            decoration: const BoxDecoration(
              color: Colors.transparent
            
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: NetworkImage("https://pics.craiyon.com/2023-11-26/oMNPpACzTtO5OVERUZwh3Q.webp"),
            ),
            
            accountName: Text(name!, style: const TextStyle(fontFamily: "Sen", fontSize: 18, fontWeight: FontWeight.w600),),
            accountEmail: Text(bio!, style: const TextStyle(fontFamily: "Sen", fontSize: 14, fontWeight: FontWeight.w300)),
          ),
          ListTile(
            title: const Text('Profile', style: TextStyle(fontFamily: "Sen", fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white)),
            leading: const Icon(Icons.people, color: Colors.white),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilPage()));
            },
          ),
          ListTile(
            title: const Text('Transactions', style: TextStyle(fontFamily: "Sen", fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white)),
            leading: const Icon(FontAwesomeIcons.bagShopping, color: Colors.white),
            onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CartPage()));
            },
          ),
          ListTile(
            title: const Text('Logout', style: TextStyle(fontFamily: "Sen", fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white)),
            leading: const Icon(Icons.logout, color: Colors.white),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ]
      )
    );
  }
}