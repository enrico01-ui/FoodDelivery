import 'dart:async';
import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fooddelivery/entity/menu.dart';
import 'package:fooddelivery/entity/profil.dart';
import 'package:fooddelivery/util/storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fooddelivery/util/constant.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:fooddelivery/entity/order.dart';
import 'package:fooddelivery/client/orderClient.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  final List<Menu>? menu;
  final Order order;
  const MapPage({super.key, required this.menu, required this.order});
  
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Profil? profil;
  final Completer<GoogleMapController> _controller = Completer();
  String? token;
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
    final email = await Storage.readSecureData('email');

    if (email != null) {
      final profilData = await getProfil(token!, email).timeout(const Duration(seconds: 30));
      setState(() {
        profil = Profil.fromJson(profilData);
      });

      if (profil?.address != null) {
        convertToLatLng(profil!.address!);
      }
    } else {
      throw Exception('Email not found');
    }
  } on TimeoutException catch (_) {
    token = null;
  } catch (e) {
    token = null;
    print("Error fetching profile: $e");
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

  final sheet = GlobalKey();
  List<Marker> markers = [];
  final LatLng source = const LatLng(-7.7918, 110.3931);
  LatLng? destination;
  late BitmapDescriptor carIcon;
  LocationData? currentLocation;
  LocationData? destinationLocation;
  List<LatLng> polylineCoordinates = [];
  String estimatedTime = 'calculating...';

  Future<BitmapDescriptor> getCustomIcon() async {
    return await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'images/car.png',
      
    );
  }

  @override
  void initState() {
    super.initState();
    initializeCustomIcon();
    getLocation();
    _loadprofil();
  }

  void initializeCustomIcon() async {
    carIcon = await getCustomIcon();
    setState(() {});
  }

  void getLocation() async {
    Location location = Location();
  
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    location.getLocation().then((LocationData value) {
      checkArrival(value.latitude!, value.longitude!);
      setState(() {
        currentLocation = value;
      });
      updateMap();
    });
    
    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen((LocationData cLoc) {
      checkArrival(cLoc.latitude!, cLoc.longitude!);
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
    });
  }
  void checkArrival(double lat, double lng) async{
    double distance = Geolocator.distanceBetween(
      lat,
      lng,
      destination!.latitude,
      destination!.longitude,
    );

    if (distance < 25) {
      showCustomSnackBar("Pengemudi sudah sampai!", "Silahkan ambil makanan", ContentType.success);
      try{
        final token = await Storage.readSecureData('personalToken');

        await Orderclient.updateOrderStatus(token!, widget.order.id.toString(), "Delivered");
        print("Order status updated to Delivered");
      }catch(e){
        print(e);
      }
    }
  }
  void showCustomSnackBar(String title, String message, ContentType type) {
    
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      backgroundColor: Colors.transparent,
      duration: const Duration(seconds: 10), // Ensure snackbar is displayed
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
  void convertToLatLng(String input) async {
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
          destination = LatLng(lat, lng);
          // Update the map marker

        });
      } else {
        throw Exception("No results found for the address.");
      }
    } else {
      throw Exception('Failed to fetch location data');
    }
  }
  void updateMap() {
    if (currentLocation == null) return;
    
    setState(() {
      markers.clear();
      markers.addAll([
        Marker(
          markerId: const MarkerId('1'),
          position: destination!,
          infoWindow: const InfoWindow(title: 'House'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        ),
        Marker(
          markerId: const MarkerId('2'),
          position: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          infoWindow: const InfoWindow(title: 'Driver'),
          icon: carIcon,
        ),
      ]);
    });
    getPolyLine(LatLng(currentLocation!.latitude!, currentLocation!.longitude!), destination!);
  }

  void getPolyLine(LatLng source, LatLng destination) async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: googleApiKey,
      request: PolylineRequest(
        origin: PointLatLng(source.latitude, source.longitude),
        destination: PointLatLng(destination.latitude, destination.longitude),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      setState(() {
        polylineCoordinates.clear();
        polylineCoordinates.addAll(result.points.map((point) => LatLng(point.latitude, point.longitude)));
        estimatedTime = result.durationTexts!.isNotEmpty ? result.durationTexts![0] : 'Calculating...';
      });
    }
  }

  final _cameraPosition = const CameraPosition(
    target: LatLng(-7.798596806613469, 110.38889052848012),
    zoom: 15.4,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body: currentLocation == null && profil == null? const Center(
          child: CircularProgressIndicator(),
        ) : Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _cameraPosition,
              markers: Set<Marker>.from(markers),
              polylines: {
                Polyline(
                  polylineId: const PolylineId('route'),
                  color: Colors.red,
                  width: 5, // Ensure a visible width
                  points: polylineCoordinates,
                  startCap: Cap.roundCap,
                  endCap: Cap.roundCap,
                  geodesic: true,
                ),
              },
              onMapCreated: (controller) {
                _controller.complete(controller);
              },
            ),
            DraggableScrollableSheet(
              key: sheet,
              initialChildSize: 0.25,
              minChildSize: 0.25,
              maxChildSize: 0.5,
              builder: (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0)
                    )
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    scrollDirection: Axis.vertical,
                    child: Column(
                          children: [
                            const SizedBox(height: 30.0),
                            Row(
                              children: [
                                const SizedBox(width: 20.0),
                                Container(
                                  height: 70.0,
                                  width: 70.0,
                                  
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(5.0),
                                    image: DecorationImage(
                                      image: NetworkImage(widget.menu!.first.restaurant.logo_url),
                                      fit: BoxFit.cover
                                    )
                                  ),
                                ),
                                const SizedBox(width: 10.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.menu!.first.restaurant.name, style: const TextStyle(fontSize: 18.0, fontFamily: "Sen", fontWeight: FontWeight.bold)),
                                    Text(widget.menu!.first.restaurant.address, style: const TextStyle(fontSize: 16.0, fontFamily: "Sen", fontWeight: FontWeight.w400)),
                                    Text('${widget.menu!.length} items', style: const TextStyle(fontSize: 16.0, fontFamily: "Sen", fontWeight: FontWeight.w400)),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 25.0),
                            Center(
                              child: Column(
                                children: [
                                  Text(estimatedTime, style: const TextStyle(fontSize: 25, fontFamily: "Sen", fontWeight: FontWeight.bold)),
                                  const Text('Estimated Delivery Time', style: TextStyle(fontSize: 16.0, fontFamily: "Sen", fontWeight: FontWeight.w400)),
                                ],
                              ),
                            )
                          ],
                        ),
                  )
                );
              },
            ),

            Align(
              
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 40.0, left: 10.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  
                  child: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),
              ),
            )
          ],
        )
      );
    
  }
}