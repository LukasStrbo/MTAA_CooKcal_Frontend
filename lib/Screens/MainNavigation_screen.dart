import 'dart:convert';

import 'package:api_cache_manager/api_cache_manager.dart';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:cookcal/HTTP/foodlist_operations.dart';
import 'package:cookcal/HTTP/users_operations.dart';
import 'package:cookcal/HTTP/login_register.dart';
import 'package:cookcal/HTTP/weight_operations.dart';
import 'package:cookcal/Screens/Food/foodEatlist_screen.dart';
import 'package:cookcal/Screens/FoodList/foodlist_screen.dart';
import 'package:cookcal/Screens/Recipes/addRecipe_screen.dart';
import 'package:cookcal/Screens/Users/userSettings_screen.dart';
import 'package:cookcal/Screens/Utils_screens/Welcome_screen.dart';
import 'package:cookcal/Utils/constants.dart';
import 'package:cookcal/Widgets/myProgressbar.dart';
import 'package:cookcal/model/foodlist.dart';
import 'package:cookcal/model/weight.dart';
import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cookcal/Screens/home_screen.dart';
import 'package:cookcal/Screens/Recipes/recipeslist_screen.dart';
import 'package:cookcal/Screens/Users/userslist_screen.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Status_code_handling/status_code_handling.dart';
import '../Utils/api_const.dart';
import '../Utils/custom_functions.dart';
import '../WebRTC/call_sample/call_sample.dart';
import '../Widgets/mySnackBar.dart';
import '../model/users.dart';


class MainNavigationScreen extends StatefulWidget {
  MainNavigationScreen({Key? key}) : super(key: key);

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentTab= -5;
  final isDialOpen = ValueNotifier(false);

  bool isLoading = false;

  UsersOperations UserOp = UsersOperations();
  FoodListOperations FoodListOp = FoodListOperations();
  WeightOperations WeightOp = WeightOperations();

  List<FoodListOut> foods = [];
  List<WeightOut> weights = [];
  List<FlSpot> spots = [];


  Widget currentScreen = WelcomeScreen();

  load_food_data() async {

    var response = await FoodListOp.get_user_foodlist();
    if (response == null || response.statusCode != 200){
      return response;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? uId = prefs.getInt('user_id');

    APICacheDBModel cacheDBModel = new APICacheDBModel(key: "User${uId}_Food", syncData: json.encode(response.data));
    await APICacheManager().addCacheData(cacheDBModel);

    List<FoodListOut> food_data = List<FoodListOut>.from(
        response.data.map((x) => FoodListOut.fromJson(x)));

    print("this -> ${foods}");
    foods.clear();
    food_data.forEach((element) {
      foods.add(element);
      print(element.id);
    });

    return response;
  }

  load_weight_data() async {
    var response = await WeightOp.get_all_weight("");

    if (response == null || response.statusCode != 200){
      return response;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? uId = prefs.getInt('user_id');

    APICacheDBModel cacheDBModel = new APICacheDBModel(key: "User${uId}_Weight", syncData: json.encode(response.data));
    await APICacheManager().addCacheData(cacheDBModel);

    List<WeightOut> weight_data = List<WeightOut>.from(
        response.data.map((x) => WeightOut.fromJson(x)));

    print(weight_data);
    print(weight_data.runtimeType);
    weights.clear();
    weight_data.forEach((element) {
      weights.add(element);
      print(element.weight);
    });

    return response;
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
        onWillPop: () async {
          await failedAPICallsQueue.execute_all_pending();
          if (isDialOpen.value) {
            isDialOpen.value = false;
            return false;
          }
          if (currentTab == 4 || currentTab == -5){
          showDialog(
              context: context,
              builder: (context){
                return AlertDialog(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  backgroundColor: COLOR_WHITE,
                  content: Container(
                    width: 300,
                    height: 125,
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          const Text(
                            "You are about to logout.",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: COLOR_BLACK,
                                fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "Do you wish to proceed?",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: COLOR_BLACK,
                                fontSize: 20
                            ),
                          ),
                          addVerticalSpace(20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: FloatingActionButton(
                                  backgroundColor: COLOR_DARKPURPLE,
                                  onPressed: () async{
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    prefs.clear();
                                    Navigator.pop(context);
                                    Navigator.pop(context);

                                  },
                                  child: const Icon(Icons.check),
                                ),
                              ),
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: FloatingActionButton(
                                  backgroundColor: COLOR_MINT,
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Icon(Icons.close),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  ),
                );
              }
          );} else {
            setState(() {
              isLoading = true;
            });
            var response_food = await load_food_data();
            var response_weight = await load_weight_data();
            var response_user = await UserOp.get_current_user_info();
            SharedPreferences prefs = await SharedPreferences.getInstance();
            int? uId = prefs.getInt('user_id');
            setState(() {
              isLoading = false;
            });

            if (food_weight_curruser_handle(context, response_food, response_weight, response_user)){

              APICacheDBModel cacheDBModeluser = new APICacheDBModel(key: "User${uId}", syncData: json.encode(response_user.data));
              await APICacheManager().addCacheData(cacheDBModeluser);

              UserOneOut user  = UserOneOut.fromJson(response_user.data);
              spots = make_plot(weights);
              double max_weight = get_max_weight(weights);
              setState(()  {

                currentScreen = HomeScreen(foods: foods, weights: spots, curr_weight: weights.last.weight.toInt(), max_weight: max_weight, user: user);
                currentTab = 4;
              });
            } else if(response_food == null && response_user == null && response_weight == null) {

              var CacheUser = await APICacheManager().isAPICacheKeyExist("User${uId}");
              var CacheFood = await APICacheManager().isAPICacheKeyExist("User${uId}_Food");
              var CacheWeight = await APICacheManager().isAPICacheKeyExist("User${uId}_Weight");

              if(CacheWeight && CacheUser && CacheFood){
                var UserCache = await APICacheManager().getCacheData("User${uId}");
                var UserFoodCache = await APICacheManager().getCacheData("User${uId}_Food");
                var UserWeightCache = await APICacheManager().getCacheData("User${uId}_Weight");
                UserOneOut user = UserOneOut.fromJson(json.decode(UserCache.syncData));

                List<FoodListOut> food_data = List<FoodListOut>.from(
                    json.decode(UserFoodCache.syncData).map((x) => FoodListOut.fromJson(x)));

                print("this -> ${foods}");
                foods.clear();
                food_data.forEach((element) {
                  foods.add(element);
                  print(element.id);
                });

                List<WeightOut> weight_data = List<WeightOut>.from(
                    json.decode(UserWeightCache.syncData).map((x) => WeightOut.fromJson(x)));

                print(weight_data);
                print(weight_data.runtimeType);
                weights.clear();
                weight_data.forEach((element) {
                  weights.add(element);
                  print(element.weight);
                });

                spots = make_plot(weights);
                double max_weight = get_max_weight(weights);
                setState(()  {
                  currentScreen = HomeScreen(foods: foods, weights: spots, curr_weight: weights.last.weight.toInt(), max_weight: max_weight, user: user);
                  currentTab = 4;
                });

              }
            } else {
              mySnackBar(context, Colors.red, COLOR_WHITE, unknowError, Icons.close);
            }
          }
          return false;
        },
        child: Scaffold(
          backgroundColor: COLOR_WHITE,
          appBar: AppBar(
            title: Text('CooKcal', style: TextStyle(color: Colors.white)),
            centerTitle: true,
            backgroundColor: COLOR_VERYDARKPURPLE,
            actions: [
              IconButton(onPressed: () async{
                  setState(() {
                    isLoading = true;
                  });
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await failedAPICallsQueue.execute_all_pending();
                  var response_user = await UserOp.get_current_user_info();
                  var response_weight = await  WeightOp.get_all_weight('');
                  setState(() {
                    isLoading = false;
                  });
                  if (weight_curruser_handle(context, response_weight, response_user)){
                    int? uId = prefs.getInt('user_id');
                    APICacheDBModel cacheDBModel = new APICacheDBModel(key: "User${uId}", syncData: json.encode(response_user.data));
                    await APICacheManager().addCacheData(cacheDBModel);

                    String? token = prefs.getString('token');
                    ImageProvider? uImage = await UserOp.get_user_image(uId);
                    UserOneOut user  = UserOneOut.fromJson(response_user.data);
                    WeightOut currWeight = WeightOp.get_last_weightMeasure(response_weight.data);



                    setState(() {
                      currentScreen = UserSettingsScreen(user: user, uImage: uImage,uId : uId, token: token, currUserWeight: currWeight);
                      currentTab = -1;
                    });
                  } else if (response_user == null && response_weight == null){
                    String? token = prefs.getString('token');
                    int? uId = prefs.getInt('user_id');
                    var CacheUser = await APICacheManager().isAPICacheKeyExist("User${uId}");
                    var CacheWeight = await APICacheManager().isAPICacheKeyExist("User${uId}_Weight");
                    if(CacheWeight && CacheUser){
                      var UserCache = await APICacheManager().getCacheData("User${uId}");
                      var UserWeightCache = await APICacheManager().getCacheData("User${uId}_Weight");

                      UserOneOut user = UserOneOut.fromJson(json.decode(UserCache.syncData));

                      WeightOut currWeight = WeightOp.get_last_weightMeasure(json.decode(UserWeightCache.syncData));

                      setState(() {
                        currentScreen = UserSettingsScreen(user: user, uImage: null ,uId : uId, token: token, currUserWeight: currWeight);
                        currentTab = -1;
                      });

                    }else{
                      mySnackBar(context, Colors.red, COLOR_WHITE, unknowError, Icons.close);
                    }
                  }

              }, icon: currentTab == -1 ? const Icon(Icons.person_sharp, color: COLOR_MINT) : const Icon(Icons.person_sharp, color: Colors.white)
              )
            ],
          ),
          body: Stack(
            alignment: Alignment.topCenter,
              children: [currentScreen,myProgressBar(isLoading)]
          ),
          floatingActionButton: SpeedDial(
            animatedIcon: AnimatedIcons.menu_close,
            backgroundColor: COLOR_DARKPURPLE,
            overlayColor: Colors.black,
            overlayOpacity: 0.4,
            openCloseDial: isDialOpen,
            spaceBetweenChildren: 15,
            children: [
              SpeedDialChild(
                  child: Icon(Icons.add),
                  label: 'Add Food',
                  onTap: () async{
                    await failedAPICallsQueue.execute_all_pending();
                    setState(() {
                      currentScreen = FoodEatListScreen();
                      currentTab = 0;
                    });
                  }
              ),
              SpeedDialChild(
                child: Icon(Icons.restaurant),
                label: 'Food I ate today',
                onTap: () async {
                  await failedAPICallsQueue.execute_all_pending();
                  setState(() {
                    isLoading = true;
                  });
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  int? uId = prefs.getInt('user_id');

                  var response_food = await load_food_data();
                  var response_weight = await load_weight_data();
                  var response_user = await UserOp.get_current_user_info();
                  setState(() {
                    isLoading = false;
                  });
                  if (food_weight_curruser_handle(context, response_food, response_weight, response_user)){

                    APICacheDBModel cacheDBModel = new APICacheDBModel(key: "User${uId}", syncData: json.encode(response_user.data));
                    await APICacheManager().addCacheData(cacheDBModel);

                    UserOneOut user  = UserOneOut.fromJson(response_user.data);
                    setState(() {
                      currentScreen = FoodListScreen(foods: foods, curr_weight: weights.last.weight.toInt(), user: user);
                      currentTab = 0;
                    });
                  } else if (response_user == null && response_weight == null && response_food == null){
                      var CacheUser = await APICacheManager().isAPICacheKeyExist("User${uId}");
                      var CacheFood = await APICacheManager().isAPICacheKeyExist("User${uId}_Food");
                      var CacheWeight = await APICacheManager().isAPICacheKeyExist("User${uId}_Weight");

                      if(CacheWeight && CacheUser && CacheFood){
                        var UserCache = await APICacheManager().getCacheData("User${uId}");
                        var UserFoodCache = await APICacheManager().getCacheData("User${uId}_Food");
                        var UserWeightCache = await APICacheManager().getCacheData("User${uId}_Weight");

                        UserOneOut user = UserOneOut.fromJson(json.decode(UserCache.syncData));

                        List<FoodListOut> food_data = List<FoodListOut>.from(
                            json.decode(UserFoodCache.syncData).map((x) => FoodListOut.fromJson(x)));

                        print("this -> ${foods}");
                        foods.clear();
                        food_data.forEach((element) {
                          foods.add(element);
                          print(element.id);
                        });

                        List<WeightOut> weight_data = List<WeightOut>.from(
                            json.decode(UserWeightCache.syncData).map((x) => WeightOut.fromJson(x)));

                        print(weight_data);
                        print(weight_data.runtimeType);
                        weights.clear();
                        weight_data.forEach((element) {
                          weights.add(element);
                          print(element.weight);
                        });
                        setState(() {
                          currentScreen = FoodListScreen(foods: foods, curr_weight: weights.last.weight.toInt(), user: user);
                          currentTab = 0;
                        });
                      }
                  } else {
                    mySnackBar(context, Colors.red, COLOR_WHITE, unknowError, Icons.close);
                  }
                }
              ),
              SpeedDialChild(
                  child: Icon(Icons.local_phone_rounded),
                  label: 'Call nutrition adviser',
                  onTap: () async{
                    setState(() {
                      isLoading = true;
                    });
                    var response_user = await UserOp.get_current_user_info();
                    setState(() {
                      isLoading = false;
                    });
                    if(user_handle(context, response_user)){
                      UserOneOut user  = UserOneOut.fromJson(response_user.data);
                      setState(() {
                        mySnackBar(context, Colors.orange, COLOR_WHITE, "Connecting to WebRTC server...", Icons.incomplete_circle_rounded);
                        currentScreen = CallSample(host: webrtc_ip, user: user);
                        currentTab = -10;
                      });
                    }
                  }
              ),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          resizeToAvoidBottomInset: false,
          bottomNavigationBar: BottomAppBar(
            color: Colors.white,
              shape: CircularNotchedRectangle(),
              notchMargin: 10,
              child: Container(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MaterialButton(
                          minWidth: 40,
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });
                            await failedAPICallsQueue.execute_all_pending();
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            int? uId = prefs.getInt('user_id');

                            var response_food = await load_food_data();
                            var response_weight = await load_weight_data();
                            var response_user = await UserOp.get_current_user_info();

                            //failedAPICallsQueue.add(UserOp.get_current_user_info());
                            //var resp = await failedAPICallsQueue.execute_first();

                            setState(() {
                              isLoading = false;
                            });

                            if (food_weight_curruser_handle(context, response_food, response_weight, response_user)){

                              APICacheDBModel cacheDBModel = new APICacheDBModel(key: "User${uId}", syncData: json.encode(response_user.data));
                              await APICacheManager().addCacheData(cacheDBModel);

                              UserOneOut user  = UserOneOut.fromJson(response_user.data);
                              spots = make_plot(weights);
                              double max_weight = get_max_weight(weights);
                              print(weights.last.weight);
                              setState(()  {
                                currentScreen = HomeScreen(foods: foods, weights: spots, curr_weight: weights.last.weight.toInt(), max_weight: max_weight, user: user);
                                currentTab = 4;
                              });
                            } else if(response_food == null && response_user == null && response_weight == null) {
                              var CacheUser = await APICacheManager().isAPICacheKeyExist("User${uId}");
                              var CacheFood = await APICacheManager().isAPICacheKeyExist("User${uId}_Food");
                              var CacheWeight = await APICacheManager().isAPICacheKeyExist("User${uId}_Weight");

                              if(CacheWeight && CacheUser && CacheFood){
                                var UserCache = await APICacheManager().getCacheData("User${uId}");
                                var UserFoodCache = await APICacheManager().getCacheData("User${uId}_Food");
                                var UserWeightCache = await APICacheManager().getCacheData("User${uId}_Weight");
                                UserOneOut user = UserOneOut.fromJson(json.decode(UserCache.syncData));

                                List<FoodListOut> food_data = List<FoodListOut>.from(
                                    json.decode(UserFoodCache.syncData).map((x) => FoodListOut.fromJson(x)));

                                print("this -> ${foods}");
                                foods.clear();
                                food_data.forEach((element) {
                                  foods.add(element);
                                  print(element.id);
                                });

                                List<WeightOut> weight_data = List<WeightOut>.from(
                                    json.decode(UserWeightCache.syncData).map((x) => WeightOut.fromJson(x)));

                                print(weight_data);
                                print(weight_data.runtimeType);
                                weights.clear();
                                weight_data.forEach((element) {
                                  weights.add(element);
                                  print(element.weight);
                                });

                                spots = make_plot(weights);
                                double max_weight = get_max_weight(weights);
                                setState(()  {
                                  currentScreen = HomeScreen(foods: foods, weights: spots, curr_weight: weights.last.weight.toInt(), max_weight: max_weight, user: user);
                                  currentTab = 4;
                                });

                              }
                            } else {
                              mySnackBar(context, Colors.red, COLOR_WHITE, unknowError, Icons.close);
                            }

                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.home,
                                color: currentTab == 4 ? COLOR_DARKMINT : COLOR_DARKPURPLE,
                              ),
                              Text(
                                "Home",
                                style: TextStyle(color: currentTab == 4 ? COLOR_DARKMINT : COLOR_DARKPURPLE),
                              )
                            ],
                          ),
                        ),
                        MaterialButton(
                          minWidth: 40,
                          onPressed:  () async {
                            final prefs = await SharedPreferences.getInstance();
                            int? id = prefs.getInt('user_id');

                            await failedAPICallsQueue.execute_all_pending();

                            setState(() {
                              currentScreen = UserListScreen(curr_id: id);
                              currentTab = 3;
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_alt_outlined,
                                color: currentTab == 3 ? COLOR_DARKMINT : COLOR_DARKPURPLE,
                              ),
                              Text(
                                "Users",
                                style: TextStyle(color: currentTab == 3 ? COLOR_DARKMINT : COLOR_DARKPURPLE),
                              )
                            ],
                          ),
                        ), //users
                        MaterialButton(
                          minWidth: 40,
                            onPressed: () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              int curr_id = prefs.getInt("user_id")!;

                              await failedAPICallsQueue.execute_all_pending();

                                setState(() {
                                  currentScreen = RecipeListScreen(curr_id: curr_id);
                                  currentTab = 1;
                                });
                        },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.list_alt,
                                color: currentTab == 1 ? COLOR_DARKMINT : COLOR_DARKPURPLE,
                              ),
                              Text(
                                "Recipes",
                                style: TextStyle(color: currentTab == 1 ? COLOR_DARKMINT : COLOR_DARKPURPLE),
                              )
                            ],
                          ),
                        ), // recipes
                        MaterialButton(
                          minWidth: 40,
                          onPressed: () async{

                            await failedAPICallsQueue.execute_all_pending();

                            setState(() {
                              currentScreen = AddRecipeScreen();
                              currentTab = 2;
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.edit,
                                color: currentTab == 2 ? COLOR_DARKMINT : COLOR_DARKPURPLE,
                              ),
                              Text(
                                "Add Recipe",
                                style: TextStyle(color: currentTab == 2 ? COLOR_DARKMINT : COLOR_DARKPURPLE),
                              )
                            ],
                          ),
                        ), // add recipe
                      ],
                    )
                  ],
                )
              )
          ),
        )
    );
  }
}