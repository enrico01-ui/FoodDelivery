import 'package:flutter/material.dart';
import 'package:fooddelivery/entity/profil.dart';
import 'package:fooddelivery/page/addAddress.dart';

class AddressPage extends StatefulWidget {
  final Profil profil;
  const AddressPage({super.key, required this.profil});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Address', style: TextStyle(fontFamily: "Sen", fontWeight: FontWeight.bold, fontSize: 18),),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
         
          
          const SizedBox(height: 40,),
          widget.profil.address != null ? Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10)
            ),
            child: Column(
              children: [
                widget.profil.address != null ? Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    splashColor: Colors.grey.withOpacity(0.3), 
                    onTap: () {
                      // Navigator.pushNamed(context, '/editprofil');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            child: const Icon(Icons.people, color: Colors.orange,),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Home", style: TextStyle(fontFamily: "Sen", fontSize: 20),),
                              Text(widget.profil.address!, style: const TextStyle(fontFamily: "Sen", fontSize: 16, color: Colors.grey),),
                            ],
                          ),
                          
                        ],
                      ),
                    ),
                  ),
                ) : const SizedBox(),
                
              ]
            )
          ) : const SizedBox(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                )
              ),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddAddress(profil: widget.profil)));
              }, 
              child: const Text(
                'Add Address',
                style: TextStyle(
                  fontFamily: "Sen",
                  fontSize: 18,
                  fontWeight: FontWeight.bold
                )
              )
            ),
          )
          )
        ]
      ),
    );
  }
}