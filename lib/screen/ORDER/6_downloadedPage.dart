import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orderapp/components/commoncolor.dart';
import 'package:orderapp/controller/controller.dart';
import 'package:orderapp/screen/ORDER/background_download.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadedPage extends StatefulWidget {
  String? type;
  String? title;
  DownloadedPage({this.type, this.title});

  @override
  State<DownloadedPage> createState() => _DownloadedPageState();
}

class _DownloadedPageState extends State<DownloadedPage> {
  String? cid;
  String? sid;
  String? userType;
  String? formattedDate;
  List s = [];
  DateTime date = DateTime.now();
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  List<String> downloadItems = [
    "Account Heads",
    "Product Details",
    "Product category",
    "Company",
    "Wallet",
    // "Images"
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
    s = formattedDate!.split(" ");
    getCid();
  }

  getCid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    cid = prefs.getString("cid");
    userType = prefs.getString("userType");
    sid = prefs.getString("sid");
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _key,
      appBar: widget.type == ""
          ? AppBar(
              backgroundColor: P_Settings.wavecolor,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(6.0),
                child: Consumer<Controller>(
                  builder: (context, value, child) {
                    if (value.isLoading) {
                      return LinearProgressIndicator(
                        backgroundColor: Colors.white,
                        color: P_Settings.wavecolor,

                        // valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
                        // value: 0.25,
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
              // title: Text("Company Details",style: TextStyle(fontSize: 20),),
            )
          : null,
      body: Consumer<Controller>(
        builder: (context, value, child) {
          print("value.sof-----${value.sof}");
          return Column(
            children: [
              Flexible(
                child: Container(
                  height: size.height * 0.9,
                  child: ListView.builder(
                    itemCount: downloadItems.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Ink(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: P_Settings.wavecolor),
                          child: ListTile(
                            trailing: IconButton(
                              onPressed: value.versof == "0"
                                  ? null
                                  : value.isAccount
                                      ? null
                                      : () async {
                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          prefs.setBool("isautodownload", true);
                                          // Provider.of<Controller>(context,
                                          //         listen: false)
                                          //     .isautodownload = true;
                                          print("time delay inside");

                                          if (downloadItems[index] ==
                                              "Account Heads") {
                                            Provider.of<Controller>(context,
                                                    listen: false)
                                                .getaccountHeadsDetails(
                                                    context, s[0], cid!);
                                          }
                                          if (downloadItems[index] ==
                                              "Product category") {
                                            Provider.of<Controller>(context,
                                                    listen: false)
                                                .getProductCategory(cid!);
                                          }
                                          if (downloadItems[index] ==
                                              "Company") {
                                            Provider.of<Controller>(context,
                                                    listen: false)
                                                .getProductCompany(cid!);
                                          }
                                          if (downloadItems[index] ==
                                              "Product Details") {
                                            Provider.of<Controller>(context,
                                                    listen: false)
                                                .getProductDetails(cid!);
                                          }
                                          if (downloadItems[index] ==
                                              "Wallet") {
                                            Provider.of<Controller>(context,
                                                    listen: false)
                                                .getWallet(context);
                                          }
                                        },
                              icon: Icon(Icons.download),
                              color: Colors.white,
                            ),
                            title: Center(
                                child: Text(
                              downloadItems[index],
                              style: TextStyle(color: Colors.white),
                            )),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              value.versof=="0"?Container(
                height: size.height*0.2,
                child: Text("Invalid Registration!!!",style: TextStyle(fontSize: 18,color: Colors.red),),
              ):Container()
            ],
          );
        },
      ),
    );
  }
}
