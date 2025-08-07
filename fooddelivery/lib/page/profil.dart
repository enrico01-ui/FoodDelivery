import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fooddelivery/entity/profil.dart';
import 'package:fooddelivery/page/addressPage.dart';
import 'package:fooddelivery/page/personalInfo.dart';
import 'package:fooddelivery/util/storage.dart';
import 'package:fooddelivery/util/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class ProfilPage extends ConsumerStatefulWidget {
  const ProfilPage({super.key});

  @override
  ConsumerState<ProfilPage> createState() => _ProfilPageState();
}


class _ProfilPageState extends ConsumerState<ProfilPage> with WidgetsBindingObserver{
  String? token;
  Profil? profil;
  late bool loading;

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

      throw Exception(e);
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

  @override
  void initState() {
    // TODO: implement initState
    super.didChangeDependencies();
    
    setState(() {
      loading = false;
    });
    _loadprofil();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(width: 10),
            const Text('Profile', style: TextStyle(fontFamily: "Sen", fontSize: 22, fontWeight: FontWeight.bold),),
          ],
        ),
      ),
      body: profil != null ? Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(profil!.image),
                ),
                const SizedBox(width: 20,),
                Expanded(
                  child: Column(
                    children: [
                      Text('Nama: ${profil?.user.name}', style: const TextStyle(fontFamily: "Sen", fontSize: 22, fontWeight: FontWeight.bold),overflow: TextOverflow.visible, // Ensures text wraps instead of ellipsis
              softWrap: true, ),
                      const SizedBox(height: 10),
                      Text('${profil?.bio}', style: const TextStyle(fontFamily: "Sen", fontSize: 14, color: Colors.grey),),
                      
                    ],
                  ),
                ),
                
              ],
              
            ),
          ),
          const SizedBox(height: 40,),
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10)
            ),
            child: Column(
              children: [
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    splashColor: Colors.grey.withOpacity(0.3), 
                    onTap: () {
                      // Navigator.pushNamed(context, '/editprofil');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: GestureDetector(
                        onTap: () async {
                          bool refresh = await Navigator.push(context, MaterialPageRoute(builder: (context) => PersonalInfo(profil: profil!)));

                          if(refresh){
                            _loadprofil();
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Wrap(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.grey[200],
                                  child: const Icon(Icons.people, color: Colors.orange,),
                                ),
                                const SizedBox(width: 20),
                                const Text("Personal Info", style: TextStyle(fontFamily: "Sen", fontSize: 18)),
                              ],
                            ),
                            const Icon(
                              FontAwesomeIcons.angleRight,
                            )
                            
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AddressPage(profil: profil!)));
                    },
                    splashColor: Colors.grey.withOpacity(0.3), 
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Wrap(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey[200],
                                child: const Icon(Icons.map, color: Colors.orange,),
                              ),
                              const SizedBox(width: 20),
                              const Text("Addresses", style: TextStyle(fontFamily: "Sen", fontSize: 18),),
                            ],
                          ),
                          const Icon(
                            FontAwesomeIcons.angleRight,
                          )
                          
                        ],
                      ),
                    ),
                  ),
                )
              ]
            )
          )
        ]
      ) : const Center(child: CircularProgressIndicator(),),
    );
  }
}