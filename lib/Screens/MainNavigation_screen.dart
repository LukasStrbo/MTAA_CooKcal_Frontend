import 'dart:math';

import 'package:cookcal/HTTP/foodlist_operations.dart';
import 'package:cookcal/HTTP/users_operations.dart';
import 'package:cookcal/HTTP/login_register.dart';
import 'package:cookcal/HTTP/weight_operations.dart';
import 'package:cookcal/Screens/Food/foodEatlist_screen.dart';
import 'package:cookcal/Screens/FoodList/foodlist_screen.dart';
import 'package:cookcal/Screens/Recipes/addRecipe_screen.dart';
import 'package:cookcal/Screens/Users/userSettings_screen.dart';
import 'package:cookcal/Screens/Welcome_screen.dart';
import 'package:cookcal/Utils/constants.dart';
import 'package:cookcal/main.dart';
import 'package:cookcal/model/foodlist.dart';
import 'package:cookcal/model/weight.dart';
import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cookcal/Screens/home_screen.dart';
import 'package:cookcal/Screens/Recipes/recipeslist_screen.dart';
import 'package:cookcal/Screens/Users/userslist_screen.dart';
//import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
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
                    ),
                  ),
                );
              }
          );} else {
            var response_food = await load_food_data();
            var response_weight = await load_weight_data();
            var response_user = await UserOp.get_current_user_info();

            if (food_weight_curruser_handle(context, response_food, response_weight, response_user)){
              UserOneOut user  = UserOneOut.fromJson(response_user.data);
              spots = make_plot(weights);
              double max_weight = get_max_weight(weights);
              setState(()  {
                currentScreen = HomeScreen(foods: foods, weights: spots, curr_weight: weights.last.weight.toInt(), max_weight: max_weight, user: user);
                currentTab = 4;
              });
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
                  SharedPreferences prefs = await SharedPreferences.getInstance();

                  var response_user = await UserOp.get_current_user_info();
                  var response_weight = await  WeightOp.get_all_weight('');

                  if (weight_curruser_handle(context, response_weight, response_user)){
                    int? uId = prefs.getInt('user_id');
                    String? token = prefs.getString('token');
                    ImageProvider? uImage = await UserOp.get_user_image(uId);
                    UserOneOut user  = UserOneOut.fromJson(response_user.data);
                    WeightOut currWeight = WeightOp.get_last_weightMeasure(response_weight);


                    setState(() {
                      currentScreen = UserSettingsScreen(user: user, uImage: uImage,uId : uId, token: token, currUserWeight: currWeight);
                      currentTab = -1;
                    });
                  }

              }, icon: const Icon(Icons.person_sharp, color: Colors.white))
            ],
          ),
          body: currentScreen,
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
                  onTap: () {
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
                  var response_food = await load_food_data();
                  var response_weight = await load_weight_data();
                  var response_user = await UserOp.get_current_user_info();
                  if (food_weight_curruser_handle(context, response_food, response_weight, response_user)){
                    UserOneOut user  = UserOneOut.fromJson(response_user.data);
                    setState(() {
                      currentScreen = FoodListScreen(foods: foods, curr_weight: weights.last.weight.toInt(), user: user);
                      currentTab = 0;
                    });
                  }
                }
              ),
              SpeedDialChild(
                  child: Icon(Icons.local_phone_rounded),
                  label: 'Call nutrition adviser',
                  onTap: () async{

                    var response_user = await UserOp.get_current_user_info();

                    if(user_handle(context, response_user)){
                      UserOneOut user  = UserOneOut.fromJson(response_user.data);
                      setState(() {
                        currentScreen = CallSample(host: webrtc_ip, user: user);
                        currentTab = -1;
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
                            var response_food = await load_food_data();
                            var response_weight = await load_weight_data();
                            var response_user = await UserOp.get_current_user_info();

                            if(food_weight_curruser_handle(context, response_food, response_weight, response_user)){
                              UserOneOut user  = UserOneOut.fromJson(response_user.data);
                              spots = make_plot(weights);
                              double max_weight = get_max_weight(weights);
                              setState(()  {
                                currentScreen = HomeScreen(foods: foods, weights: spots, curr_weight: weights.last.weight.toInt(), max_weight: max_weight, user: user);
                                currentTab = 4;
                              });
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
                        ), // home
                        MaterialButton(
                          minWidth: 40,
                          onPressed:  () {
                            setState(() {
                              currentScreen = UserListScreen();
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
                            onPressed: (){
                                setState(() {
                                  currentScreen = RecipeListScreen();
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
                          onPressed: (){
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