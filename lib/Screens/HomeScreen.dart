import 'dart:convert' as convert;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex_assessment/Utils/ApiConstants.dart';
import 'package:pokedex_assessment/Utils/CustomTextStyling.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CarouselController _controller = CarouselController();

  late String _valueName;
  late String _valueHeight;
  late String _valueWeight;
  late String _valueType1;
  late String _valueType2;
  late String _valueImage;
  late int _index;
  late String _detailsUrl;
  late bool _flag;

  @override
  void initState() {
    _valueName = "";
    _valueHeight = "";
    _valueWeight = "";
    _valueType1 = "";
    _valueType2 = "";
    _valueImage = "";
    _index = 0;
    _detailsUrl = "";
    _flag = true;

    super.initState();
  }

  Future getAllItemList() async {
    var queryParameters = {
      'limit': '150',
      'offset': '0',
    };

    var url = Uri.https(ItemBaseUrl, ItemEndPoint, queryParameters);
    //print("Url $url");

    var response = await http.get(url);
    var jsonResponse = convert.jsonDecode(response.body);

    setState(() {
      _detailsUrl = jsonResponse["results"][0]["url"];
      if (_flag) {
        getItemDetails(_detailsUrl);
      }
    });
    //print("convertedResponse $jsonResponse");

    return jsonResponse;
  }

  Future getItemDetails(String detailsUrl) async {
    var tempUrl = Uri.parse(detailsUrl);

    var response = await http.get(tempUrl);
    var jsonResponse = convert.jsonDecode(response.body);

    setState(() {
      _flag = false;
      _valueName = jsonResponse["name"];
      _valueHeight = jsonResponse["height"].toString();
      _valueWeight = jsonResponse["weight"].toString();
      _valueType1 = jsonResponse["types"][0]["type"]["name"];
      _valueType2 = jsonResponse["types"][1]["type"]["name"];
      _valueImage = jsonResponse["sprites"]["front_default"];
    });

     //print("ItemDetails $jsonResponse");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pokedex Assessment",
          style: titleTextStyle,
        ),
        centerTitle: true,
        backgroundColor: Colors.grey,
      ),
      body: Center(
        child: FutureBuilder(
          future: getAllItemList(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Column(
                children: [
                  CarouselSlider(
                    items: snapshot.data["results"]
                        .map<Widget>(
                          (item) => Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                            color: Colors.grey,
                            child: Container(
                              width: 180,
                              height: 120,
                              margin: const EdgeInsets.all(1.0),
                              decoration: BoxDecoration(
                                  image: DecorationImage(image: NetworkImage(_valueImage),
                                      fit: BoxFit.cover)
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '# ${snapshot.data["results"].indexOf(item) + 1}',
                                      style: nameTextStyle,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    options: CarouselOptions(
                      height: 300,
                      aspectRatio: 16 / 9,
                      viewportFraction: 0.5,
                      initialPage: 0,
                      enableInfiniteScroll: true,
                      reverse: false,
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                      onPageChanged: (position, reason) {
                        setState(() {
                          _index = position;
                          _detailsUrl = snapshot.data["results"][_index]["url"];
                          getItemDetails(_detailsUrl);
                        });
                      },
                      scrollDirection: Axis.horizontal,
                    ),
                    carouselController: _controller,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Text(
                    _valueName,
                    style: nameTextStyle,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          "Height: $_valueHeight",
                          style: normalTextStyle,
                        ),
                        flex: 1,
                      ),
                      Flexible(
                        child: Text(
                          "Weight: $_valueWeight",
                          style: normalTextStyle,
                        ),
                        flex: 1,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Type: $_valueType1 / $_valueType2",
                    style: normalTextStyle,
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
