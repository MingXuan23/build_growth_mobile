import 'package:build_growth_mobile/env.dart';
import 'package:build_growth_mobile/models/content.dart';
import 'package:http/http.dart' as http;

class ContentRepo{

  static String HOST_URL = HOST_URL;

  static String vector_prefix = 'api/vector';
  
  static Future<List<Content>> fetchVectorContent() async {
    try{
      final response = await http.post(
        Uri.parse('$HOST_URL/$vector_prefix/'),
        headers: {'Content-Type': 'application/json', 'Application-Id': appId},
       // body: jsonEncode({'rememberToken': remember_token, 'email': email}),
      );

      if(response.statusCode == 200){

      }else{

      }

      return [];

    }
    catch(e){
      return [];
    }
  }
}