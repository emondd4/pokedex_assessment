import 'package:flutter/material.dart';
import 'package:pokedex_assessment/Utils/ApiConstants.dart';
import 'package:pokedex_assessment/Utils/CustomTextStyling.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late String _valueName;
  late String _valueHeight;
  late String _valueWeight;
  late String _valueType;
  late int _index;
  late String _detailsUrl;

  @override
  void initState() {
    _valueName = "";
    _valueHeight = "";
    _valueWeight = "";
    _valueType = "";
    _index = 0;
    _detailsUrl = "";

    getItemDetails(_detailsUrl);

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
    // print("convertedResponse $jsonResponse");

    return jsonResponse;
  }

  getItemDetails(String givenUrl){
    print("Temp Url $givenUrl");
    // var tempUrl = Uri.parse(givenUrl);
    // //print("Url $url");
    //
    // var response = await http.get(tempUrl);
    // var jsonResponse = convert.jsonDecode(response.body);
    // print(jsonResponse);
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
                      items: snapshot.data["results"].map<Widget>((item) => Container(
                            margin: const EdgeInsets.all(1.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                          )).toList(),
                      options: CarouselOptions(
                        height: 300,
                        aspectRatio: 16 / 9,
                        viewportFraction: 0.8,
                        initialPage: 0,
                        enableInfiniteScroll: true,
                        reverse: false,
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enlargeCenterPage: true,
                        onPageChanged: (index,reason) {
                          setState(() {
                            if(_index != 0){
                              _index = _index + 1;
                              _detailsUrl = snapshot.data["results"][_index]["url"];
                            }else{
                              _detailsUrl = snapshot.data["results"][_index]["url"];
                            }

                          });
                        },
                        scrollDirection: Axis.horizontal,
                      )),
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
                          _valueHeight,
                          style: normalTextStyle,
                        ),
                        flex: 1,
                      ),
                      Flexible(
                        child: Text(
                          _valueWeight,
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
                    _valueType,
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
