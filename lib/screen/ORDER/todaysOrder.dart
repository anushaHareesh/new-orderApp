import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:orderapp/components/commoncolor.dart';
import 'package:orderapp/controller/controller.dart';
import 'package:orderapp/screen/ORDER/5_mainDashboard.dart';
import 'package:orderapp/screen/historydataPopup.dart';
import 'package:provider/provider.dart';

import '5_mainDashboard.dart';
import 'orderDetailsToday.dart';

class TodaysOrder extends StatefulWidget {
  const TodaysOrder({Key? key}) : super(key: key);

  @override
  State<TodaysOrder> createState() => _TodaysOrderState();
}

class _TodaysOrderState extends State<TodaysOrder> {
  // MainDashboard dash = MainDashboard();
  DateTime now = DateTime.now();
  HistoryPopup popup = HistoryPopup();
  List<String> s = [];
  String? result;
  String? date;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    date = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);
    s = date!.split(" ");
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Consumer<Controller>(
        builder: (context, value, child) {
          if (value.isLoading) {
            return SpinKitFadingCircle(
              color: P_Settings.wavecolor,
            );
          } else {
            if (value.todayOrderList.length == 0) {
              return Container(
                height: size.height * 0.7,
                width: double.infinity,
                child: Center(
                    child: Text(
                  "No Orders!!!",
                  style: TextStyle(
                    fontSize: 19,
                  ),
                )),
              );
            } else {
              return ListView.builder(
                itemCount: value.todayOrderList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Provider.of<Controller>(context, listen: false)
                                .getHistoryData('orderDetailTable',
                                    "order_id='${value.todayOrderList[index]["order_id"]}'");
                            popup.buildPopupDialog(
                                context,
                                size,
                                value.todayOrderList[index]["Order_Num"],
                                value.todayOrderList[index]["Cus_id"],
                                "sale order");
                          },
                          child: 
                          Card(
                              child: ListTile(
                            tileColor: Colors.grey[100],
                            title: Column(
                              children: [
                                SizedBox(
                                  height: size.height * 0.01,
                                ),
                                Row(
                                  children: [
                                    // Icon(Icons),
                                    // SizedBox(
                                    //   width: size.width * 0.02,
                                    // ),
                                    Text("Ord No : "),
                                    Flexible(
                                      child: Text(
                                          value.todayOrderList[index]
                                              ["Order_Num"],
                                          style: TextStyle(
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17)),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: size.height * 0.01,
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      color: P_Settings.wavecolor,
                                    ),
                                    SizedBox(
                                      width: size.width * 0.02,
                                    ),
                                    RichText(
                                      overflow: TextOverflow.clip,
                                      maxLines: 2,
                                      text: TextSpan(
                                        text:
                                            '${value.todayOrderList[index]["cus_name"]}',
                                        style: TextStyle(
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                    ),
                                    Text(" - "),
                                    Text(
                                      value.todayOrderList[index]["Cus_id"],
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 14),
                                    ),
                                    Spacer(),
                                  ],
                                ),
                                Divider(),
                                Row(
                                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "No: of Items  :",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    Text(
                                        "${value.todayOrderList[index]["count"].toString()}",
                                        style: TextStyle(
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17)),
                                    Spacer(),
                                    Text(
                                      "Total  :",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    Text(
                                      "\u{20B9}${value.todayOrderList[index]["total_price"].toStringAsFixed(2)}",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}
