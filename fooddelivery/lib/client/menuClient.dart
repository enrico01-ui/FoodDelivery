
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fooddelivery/entity/menu.dart';
import 'package:fooddelivery/util/constant.dart';

class Menuclient {
  static const String baseUrl = baseIp;

  static Future<List<Menu>> getMenus(String token) async{
    const String endpoint = 'api/menu';
    try{
      final response = await http.get(Uri.http(baseUrl, endpoint),
        headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization' : 'Bearer $token'
          }).timeout(const Duration(seconds: 20), onTimeout: () {
            return http.Response('Error', 408);
          },);
      if(response.statusCode == 200){
        List<Menu> menus = [];
        var data = jsonDecode(response.body);
        for(var i in data){
          menus.add(Menu.fromJson(i));
        }
        print("MenuClient getMenus: $menus");
        return menus;
      }else{
        return [];
      }

    }catch(e){
      return Future.error(e.toString());
    }

  }
}