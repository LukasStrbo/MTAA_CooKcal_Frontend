import 'package:cookcal/Screens/Recipes/recipeProfile_screen.dart';
import 'package:cookcal/Utils/constants.dart';
import 'package:cookcal/Utils/custom_functions.dart';
import 'package:flutter/material.dart';
import 'package:cookcal/Widgets/searchBar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../HTTP/food_operations.dart';
import '../../HTTP/foodlist_operations.dart';
import '../../Widgets/neomoprishm_box.dart';
import '../../model/food.dart';
import '../../model/foodlist.dart';


class FoodEatListScreen extends StatefulWidget {
  const FoodEatListScreen({Key? key}) : super(key: key);

  @override
  _FoodEatListScreenState createState() => _FoodEatListScreenState();
}

class _FoodEatListScreenState extends State<FoodEatListScreen> {

  final gramsControler = TextEditingController();
  final searchControler = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  FoodListOperations foodListOperations = FoodListOperations();
  List<FoodOut> foods = [];
  late int curr_id = 0;



  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    searchControler.dispose();
    gramsControler.dispose();
    super.dispose();
  }


  load_data() async {
    var tmp = await FoodOperations().get_all_food(gramsControler.text);
    print(tmp);
    print(tmp.runtimeType);
    foods.clear();
    tmp?.forEach((element) {
      foods.add(element);
      print(element.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: COLOR_WHITE,
      body: LayoutBuilder(builder: (context, constraints){
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: RoundedSearchInput(
                hintText: 'Search here',
                textController: searchControler,
              ),
            ),
            addVerticalSpace(constraints.maxHeight * 0.02),
            ButtonTheme(
              minWidth: 500,
              height: 200,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    fixedSize: const Size(300,40),
                    primary: COLOR_DARKPURPLE,
                    shadowColor: Colors.grey.shade50,
                    textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)
                    )
                ),
                onPressed: () async {
                  await load_data();
                  setState(() {});
                  searchControler.text = "";
                },
                child: const Text('Search Food'),
              ),
            ),
            addVerticalSpace(constraints.maxHeight * 0.02),
            const Divider(
              color: COLOR_DARKPURPLE,
              thickness: 2,
            ),
            Expanded(
                child: ListView.builder(
                  itemCount: foods.length,
                  itemBuilder: (context, index){
                    final food = foods[index];
                    return Padding(
                        padding: EdgeInsets.all(5),
                      child:  Container(
                          decoration: neumorphism(COLOR_WHITE, Colors.grey[500]!, Colors.white, 4, 15),
                          child: ListTile(
                            tileColor: COLOR_WHITE,
                            trailing: const Icon(Icons.arrow_forward_ios_rounded),
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context){
                                    return AlertDialog(
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(20.0))),
                                      backgroundColor: COLOR_WHITE,
                                      content: Container(
                                        width: 300,
                                        height: 210,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  const Text(
                                                    "Adding:  ",
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: COLOR_BLACK,
                                                      fontSize: 17,
                                                    ),
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                      "${food.title}",
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(
                                                          color: COLOR_BLACK,
                                                          fontSize: 17,
                                                          fontWeight: FontWeight.bold
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              addVerticalSpace(15),
                                              Form(
                                                key: _formKey,
                                                child: Container(
                                                  margin: const EdgeInsets.all(10),
                                                  child: TextFormField(
                                                    controller: gramsControler,
                                                    validator: (value) {
                                                      if (value == null || value.isEmpty) {
                                                        return 'Enter food measurement';
                                                      }
                                                      else if (!RegExp(r'^[1-9]+[0-9]*([.]{1}[0-9]+|)$').hasMatch(value)){
                                                        return 'Please enter a valid number';
                                                      }
                                                      return null;
                                                    },
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.grey.shade200,
                                                      icon: const Icon(
                                                        Icons.set_meal_sharp,
                                                        color: COLOR_DARKPURPLE,
                                                      ),
                                                      hintText: 'Amount in grams',
                                                      focusedBorder: formBorder,
                                                      errorBorder: formBorder,
                                                      focusedErrorBorder: formBorder,
                                                      enabledBorder: formBorder,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              addVerticalSpace(constraints.maxHeight * 0.02),
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
                                                        if (!_formKey.currentState!.validate()){
                                                          return;
                                                        }
                                                        FoodlistIn data = FoodlistIn(
                                                          id_food: food.id,
                                                          amount: double.parse(gramsControler.text),
                                                        );
                                                        var response = foodListOperations.AddFood(data);
                                                        gramsControler.text = "";

                                                        Navigator.pop(context);

                                                        final snackBar = SnackBar(backgroundColor: COLOR_DARKMINT,
                                                            content: Row(
                                                              children: const [
                                                                Icon(Icons.check_circle, color: COLOR_WHITE),
                                                                SizedBox(width: 20),
                                                                Expanded(child: Text('Food added successfully',
                                                                    style: TextStyle(color: COLOR_WHITE)))
                                                              ],
                                                            ));
                                                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                      },
                                                      child: const Icon(Icons.add),
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
                                                      child: const Icon(Icons.arrow_back),
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
                              );
                            },
                            leading: CircleAvatar(
                              backgroundColor: COLOR_WHITE,
                              backgroundImage: AssetImage(food_icons[random(0,4)]), // no matter how big it is, it won't overflow
                            ),
                            title: Text(food.title),
                            subtitle: Text("${food.kcal_100g} Kcal / 100g"),

                          )
                      ),
                    );
                  },
                )
              )
            ],
          );
        }
      ),
    );
  }
}
