import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fooddelivery/entity/profil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fooddelivery/util/storage.dart';
import 'package:http/http.dart' as http;
import 'package:fooddelivery/util/constant.dart';



class PersonalInfo extends StatefulWidget {
  final Profil profil;
  const PersonalInfo({super.key, required this.profil});

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {

  Future<Profil> updateProfil(String token, Profil profil, String name) async {
    const String endpoint = 'api/profil/update';
    try{
      final response = await http.put(Uri.http(baseIp, endpoint), 
      headers:
      {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'email': profil.email,
        'no_telp': profil.no_telp,
        'bio': profil.bio,
        'image': profil.image,
        'address': profil.address
      })
    ).timeout(const Duration(seconds: 20), onTimeout: () {
      return http.Response('Error', 408);
    });

    if(response.statusCode == 200){
      var data = jsonDecode(response.body)['profil'];
      print('Response Data: $data');
      return Profil.fromJson(data);
    }else{
      print('Error ${response.statusCode}: ${response.body}');
      return Future.error('Error updating profil');
    }
    }catch(e){
      print('Exception: $e');
      return Future.error('Error Updateing Profil: $e');
    }
  }
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
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController bioController;

  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    
    // Inisialisasi controller dengan referensi data awal
    nameController = TextEditingController(text: widget.profil.user.name);
    emailController = TextEditingController(text: widget.profil.email);
    phoneController = TextEditingController(text: widget.profil.no_telp);
    bioController = TextEditingController(text: widget.profil.bio);

    // Tambahkan listener agar setiap perubahan tersinkronisasi
    nameController.addListener(() {
      setState(() {}); // Memaksa UI diperbarui saat nilai berubah
    });
    phoneController.addListener(() {
      setState(() {});
    });
    bioController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: !isEdit ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Wrap(
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
            
            GestureDetector(
              onTap: () {
                setState(() {
                  isEdit = true;
                });
              },
              child: const Text(
                'Edit', style: TextStyle(fontFamily: "Sen", fontSize: 16, color: Colors.orange, decoration: TextDecoration.underline,decorationColor: Colors.orange),
              
              ),
            )
          ],
        ) : Row(
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
            const Text('Edit Profile', style: TextStyle(fontFamily: "Sen", fontSize: 22, fontWeight: FontWeight.bold),),
          ],
        )
      ),
      body: widget.profil != null ? !isEdit ? Column(
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
                  backgroundImage: NetworkImage(widget.profil.image),
                ),
                const SizedBox(width: 20,),
                Expanded(
                  child: Column(
                    children: [
                      Text('Nama: ${widget.profil.user.name}', style: const TextStyle(fontFamily: "Sen", fontSize: 22, fontWeight: FontWeight.bold),overflow: TextOverflow.visible, // Ensures text wraps instead of ellipsis
              softWrap: true, ),
                      const SizedBox(height: 10),
                      Text(widget.profil.bio, style: const TextStyle(fontFamily: "Sen", fontSize: 14, color: Colors.grey),),
                      
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
                              const Text("Full Name", style: TextStyle(fontFamily: "Sen", fontSize: 20),),
                              Text(widget.profil.user.name, style: const TextStyle(fontFamily: "Sen", fontSize: 16, color: Colors.grey),),
                            ],
                          ),
                          
                        ],
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () {
                      // Navigator.pushNamed(context, '/editprofil');
                    },
                    splashColor: Colors.grey.withOpacity(0.3), 
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            child: const Icon(Icons.mail, color: Colors.orange,),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Email", style: TextStyle(fontFamily: "Sen", fontSize: 20),),
                              Text(widget.profil.email ?? "not set", style: const TextStyle(fontFamily: "Sen", fontSize: 16, color: Colors.grey),),
                            ],
                          )
                          
                        ],
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () {
                      // Navigator.pushNamed(context, '/editprofil');
                    },
                    splashColor: Colors.grey.withOpacity(0.3), 
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            child: const Icon(Icons.mail, color: Colors.orange,),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Phone Number", style: TextStyle(fontFamily: "Sen", fontSize: 20),),
                              Text(widget.profil.no_telp ?? "not set", style: const TextStyle(fontFamily: "Sen", fontSize: 16, color: Colors.grey),),
                            ],
                          )
                          
                        ],
                      ),
                    ),
                  ),
                ),
              ]
            )
          )
        ]
      ) : Column(
        
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Center(

            child: CircleAvatar(
              backgroundImage: NetworkImage(widget.profil.image),
              radius: 50,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 22,),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    labelStyle: const TextStyle(fontFamily: "Sen", fontSize: 20, fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    )
                  ),
                ),
                const SizedBox(height: 22,),
                TextFormField(
                  controller: emailController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(fontFamily: "Sen", fontSize: 20, fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    )
                  ),
                ),
                const SizedBox(height: 22,),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: const TextStyle(fontFamily: "Sen", fontSize: 20, fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    )
                  ),
                ),
                const SizedBox(height:22,),
                TextFormField(
                  controller: bioController,
                  maxLines: 7,
                  decoration: InputDecoration(
                    
                    labelText: 'Biodata',
                    labelStyle: const TextStyle(fontFamily: "Sen", fontSize: 20, fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    )
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                ElevatedButton(
                  
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(MediaQuery.of(context).size.width, 50),
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    )
                  ),
                  onPressed: () async {
                    var profil = Profil(
                      user: widget.profil.user,
                      email: emailController.text,
                      no_telp: phoneController.text,
                      bio: bioController.text,
                      image: widget.profil.image,
                      address: widget.profil.address ?? "not set"
                    );
                    var token = await Storage.readSecureData("personalToken");
                    var profile = await updateProfil(token!, profil, nameController.text);
                    await Storage.deleteSecureData('name');
                    await Storage.writeSecureData('name', nameController.text);
                    String name = await Storage.readSecureData('name') ?? "not set";
                    print("nama : $name");
                    showCustomSnackBar(context, "Profile Successfully Updated", "Profile has been changed", ContentType.success);
                    if(name != "not set"){
                      Navigator.pop(context, true);
                    }
                  }, 
                  child: const Text("Save", style: TextStyle(fontFamily: "Sen", fontSize: 20, fontWeight: FontWeight.bold),),
                )
              ],
            ),
          )
        ],
      ) : const Center(child: CircularProgressIndicator(),),
    );
  }
}