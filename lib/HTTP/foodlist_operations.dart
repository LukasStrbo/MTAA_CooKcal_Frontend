import 'package:cookcal/model/foodlist.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utils/api_const.dart';

class FoodListOperations {
  final Dio _dio = Dio();

  AddFood(FoodlistIn food, int offline_Id) async {

    Dio dio = Dio();
    dio.options.headers['content-type'] = 'application/json';

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    dio.options.headers["authorization"] = "Bearer " + token;

    try {

      Response response = await dio.post(apiURL + '/foodlist/',
          data: food.toJson());

      return response;
    }
    on DioError catch (e) {
      failedAPICallsQueue.add({
        'url': apiURL + '/foodlist/',
        "id": offline_Id,
        'token': token,
        'method': 'POST',
        'data': food.toJson()
      });
      return e.response;
    }
  }

   get_user_foodlist() async {

    DateTime dateToday =new DateTime.now();
    String date = dateToday.toString().substring(0,10);
    print(date);

    try {
      Dio dio = Dio();
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');
      dio.options.headers['authorization'] = 'Bearer ' + token!;
      Response response = await dio.get(apiURL + '/foodlist/?date=' + date);
      return response;
    }
    on DioError catch (e) {
      return e.response;
    }
  }

  delete_food(food_id) async {
    Dio d = Dio();
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');

    try{

      d.options.headers['authorization'] = 'Bearer ' + token!;
      Response response = await d.delete(apiURL + '/foodlist/' + food_id.toString());
      return response;
    } on DioError catch(e){
      failedAPICallsQueue.add({
        'url': apiURL + '/foodlist/' + food_id.toString(),
        'id': food_id,
        'token': token,
        'method': 'DELETE',
      });
      return e.response;
    }

  }

}