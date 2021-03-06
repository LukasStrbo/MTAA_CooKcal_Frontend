import 'package:cookcal/HTTP/login_register.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cookcal/Utils/constants.dart';
import 'package:flutter/services.dart';
import 'dart:math';

import '../model/foodlist.dart';
import '../model/weight.dart';

int last_x_graph = 10;

Widget addVerticalSpace(double height){
  return SizedBox(
      height:height
  );
}

Widget addHorizontalSpace(double width){
  return SizedBox(
      width:width
  );
}

int random(min, max) {
  return min + Random().nextInt(max - min);
}

double calculate_eaten(List<FoodListOut> foodList){
  double sum = 0;
  for (FoodListOut food in foodList){
    sum = sum + food.amount * food.kcal_100g / 100;
  }

  return sum;
}

double calculate_howmucheat(UserIdExample user){
  int weight = 69;
  double toEat = 0;
  if (user.gender == 1) {
    toEat = 9.99 * weight + 6.25 * user.height - 4.92 * user.age + 5;
  } else {
    toEat = 9.99 * weight + 6.25 * user.height - 4.92 * user.age - 161;
  }

  return toEat;
}

List<FlSpot> make_plot(List<WeightOut> weights){
  List<FlSpot> spots = [];
  double x = 0;
  double y = 0;

  if (weights.length == 1){
    for (WeightOut weight in weights){
      spots.add(FlSpot(
          x,weight.weight
      ));
      x++;
    }
  }

  if (weights.length > last_x_graph){
    weights = weights.sublist(weights.length-last_x_graph, weights.length);
  }

  for (WeightOut weight in weights){
    spots.add(FlSpot(
      x,weight.weight
    ));
    y++;
    x++;
  }

  return spots;
}

double get_max_weight(List<WeightOut> weights){

  if (weights.length > last_x_graph){
    weights = weights.sublist(weights.length-last_x_graph, weights.length);
  }

  double max = 0;
  for (WeightOut weight in weights){
    if (max < weight.weight){
      max = weight.weight;
    }
  }
  return max;
}

int calculate_max(int weight, UserOneOut user){
  double max_to_eat = 2000;

  if (user.gender == 0){
    /*BMR = 10W + 6.25H - 5A + 5
    BMR = 13.397W + 4.799H - 5.677A + 88.362*/
    max_to_eat = (23.397 * weight + 11.019 * user.height - 10.667 * user.age + 93.362) / 2;

  } else if (user.gender == 1) {
    /* BMR = 10W + 6.25H - 5A - 161
     BMR = 9.247W + 3.098H - 4.330A + 447.593*/

    max_to_eat = (19.247 * weight + 9.348 * user.height - 9.330 * user.age + 286.593) / 2;

  }else{
    max_to_eat = ((23.397 * weight + 11.019 * user.height - 0.667 * user.age + 93.362) + (22.644 * weight + 7.897 * user.height - 9.007 * user.age + 535.955))/8;
  }

  if (user.state == 0){
    max_to_eat = max_to_eat + 250;
  } else if (user.state == 2) {
    max_to_eat = max_to_eat + 500;
  }

  return max_to_eat.toInt();
}

Widget assert_to_image(BuildContext context, String path) {

  return Image(image: AssetImage(path));
}

Color getColor(Set<MaterialState> states) {
  const Set<MaterialState> interactiveStates = <MaterialState>{
    MaterialState.pressed,
    MaterialState.hovered,
    MaterialState.focused,
  };
  if (states.any(interactiveStates.contains)) {
    return COLOR_MINT;
  }
  return COLOR_DARKPURPLE;
}

class MyClipper extends CustomClipper<Rect>{
  @override
  Rect getClip(Size size) {
    final epicenter = new Offset(size.width, size.height);

    // Calculate distance from epicenter to the top left corner to make sure clip the image into circle.

    final distanceToCorner = epicenter.dy;

    final radius = distanceToCorner;
    final diameter = radius;

    return new Rect.fromLTWH(
        epicenter.dx - radius, epicenter.dy - radius, diameter, diameter);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return true;
  }
  
}