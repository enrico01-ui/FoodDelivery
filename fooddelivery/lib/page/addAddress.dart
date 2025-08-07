import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fooddelivery/entity/profil.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fooddelivery/entity/menu.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fooddelivery/util/constant.dart';
import 'package:fooddelivery/util/storage.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class AddAddress extends StatefulWidget {
  final Profil profil;
  const AddAddress({super.key, required this.profil});

  @override
  State<AddAddress> createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
  final Completer<GoogleMapController> _controller = Completer();
  Future<void> updateProfil(String token, String email, String telp, String address) async{
    String endpoint = 'api/profil/update';
    try{
      final response = await http.put(Uri.http(baseIp, endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(
        {
          'email': email,
          'no_telp': telp,
          'address': address,
        }
      ),
      ).timeout(const Duration(seconds: 20), onTimeout: () {
        return http.Response('Error', 408);
      });
      if(response.statusCode == 200){
        var data = jsonDecode(response.body)['profil'];
        print('Response Data: $data');
        return Future.value(Profil.fromJson(data));
      }else{
        print('Error ${response.statusCode}: ${response.body}');
        return Future.error('Error updating profil');
      }
    }catch(e){
      return Future.error(e.toString());
    }
  }
  LocationData? currentLocation;
  late Marker marker;
  TextEditingController addressController = TextEditingController();
  var uuid = const Uuid();
  String _sessionToken = '123456';
  bool isManualSelection = false;
  List<dynamic> suggestions = [];

  void getLocation() async {
    if(currentLocation != null) return;
    Location location = Location();
    
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if(!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if(permissionGranted != PermissionStatus.granted) {
      permissionGranted = await location.requestPermission();
      if(permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    location.getLocation().then((LocationData value) {
      if(!isManualSelection) {
        setState(() {
          currentLocation = value;
        });
        updateMap();
      }
    });
  
    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen((LocationData cLoc) {
      if(!isManualSelection){
        if (currentLocation == null || 
            (currentLocation!.latitude != cLoc.latitude || currentLocation!.longitude != cLoc.longitude)) {
          setState(() {
            currentLocation = cLoc;
          });

          googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
              zoom: 15.4,
            ),
          ));
          updateMap();
        }
      }
    });

  }

  void updateMap() {
    if (currentLocation == null) return;
    
    setState(() {
       marker = Marker(
          markerId: const MarkerId('1'),
          position: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          infoWindow: const InfoWindow(title: 'House'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        );
    });
  }
  @override
  void initState() {
    super.initState();
    if(currentLocation == null ) {
      getLocation();
    }
    Timer? debounce;
    addressController.addListener(() {
      if (debounce?.isActive ?? false) debounce!.cancel();
      debounce = Timer(const Duration(milliseconds: 500), () {
        setState(() {
          onChange();
        });
      });
    });
  }

  void onChange() {
    getSuggestion(addressController.text);
  }


  void getSuggestion(String input) async {
    String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request = '$baseURL?input=$input&key=$googleApiKey&sessiontoken=$_sessionToken';
    var response = await http.get(Uri.parse(request));


    if(response.statusCode == 200) {
      var data = jsonDecode(response.body.toString()) ['predictions'];
      setState(() {
        
        suggestions = data;
        if(addressController.text == suggestions[0]['description']) {
          suggestions = [];
          return;
        }
      });
    }else{
      throw Exception('Failed to get/load suggestion');
    }
  }

  void convertToLatLng(String input) async {
    isManualSelection = true;
    String baseURL = 'https://maps.googleapis.com/maps/api/geocode/json';
    String request = '$baseURL?address=$input&key=$googleApiKey';
    
    var response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data["status"] == "OK" && data["results"].isNotEmpty) {
        var location = data["results"][0]["geometry"]["location"];
        double lat = location["lat"];
        double lng = location["lng"];

        setState(() {
          currentLocation = LocationData.fromMap({
            "latitude": lat,
            "longitude": lng,
          });

          // Update the map marker
          marker = Marker(
            markerId: const MarkerId('selected_location'),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: input),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          );

          // Move the camera to the new position
          _controller.future.then((controller) {
            controller.animateCamera(
              CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15.4),
            );
          });
        });
      } else {
        throw Exception("No results found for the address.");
      }
    } else {
      throw Exception('Failed to fetch location data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentLocation != null ?Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            
            child: GoogleMap(
              zoomControlsEnabled: false,
              markers: {marker},
              initialCameraPosition: CameraPosition(
                target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
                zoom: 15.4,
              ) ,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
          Positioned(
            top: 40,
            left: 10,
            right: 10,
            child: IgnorePointer(
              ignoring: false, // Ensures it captures touch
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                color: Colors.transparent,
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.translucent, // Ensures the tap is detected
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.arrow_back, color: Colors.black),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: addressController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[200],
                              hintStyle: const TextStyle(
                                fontFamily: 'Sen',
                                color: Colors.black,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              hintText: 'Enter your address',
                            ),
                          ),
                        ),
                      ],
                    ),
                    suggestions.isNotEmpty ? Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        itemCount: suggestions.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(suggestions[index]['description']),
                            onTap: () async {
                              addressController.text = suggestions[index]['description'];
                              suggestions = [];
                              convertToLatLng(addressController.text);
                            },
                          );
                        },
                      ),
                    ) : const SizedBox(),
                  ],
                ),
              ),
            ),
          ),
           

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () async{
                  final token = await Storage.readSecureData('personalToken');
                  updateProfil(token!, widget.profil.email, widget.profil.no_telp, addressController.text);
                  Navigator.pop(context, widget.profil);
                },
                child: const Text('Save', style: TextStyle(fontFamily: "Sen", fontSize: 18, color: Colors.white),),
              )
            ),
          )
        ],
      ): const Center(child: CircularProgressIndicator(),),
    );
  }
}