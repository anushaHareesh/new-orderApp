import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orderapp/components/commoncolor.dart';
import 'package:orderapp/components/customSnackbar.dart';
import 'package:orderapp/components/showMoadal.dart';
import 'package:orderapp/db_helper.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/controller.dart';

class FilteredProduct extends StatefulWidget {
  String? type;
  String? os;
  List<String>? s;
  String? customerId;
  String? value;
  // List<Map<String, dynamic>> list;
  FilteredProduct({required this.type, this.customerId, this.os, this.s,this.value});

  @override
  State<FilteredProduct> createState() => _FilteredProductState();
}

class _FilteredProductState extends State<FilteredProduct> {
  String rate1 = "1";
  // List<String> s = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  CustomSnackbar snackbar = CustomSnackbar();
  ShowModal showModal = ShowModal();

  void _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cid = prefs.getString("cid");
    // Provider.of<Controller>(context, listen: false).adminDashboard(cid!);

    // monitor network fetch
    // await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<Controller>(context, listen: false)
                          .filterwithCompany(widget.customerId!, widget.value!);
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Consumer<Controller>(
        builder: (context, value, child) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: value.filteredProductList.length,
            itemBuilder: (BuildContext context, index) {
              return Padding(
                padding: const EdgeInsets.only(left: 0.4, right: 0.4),
                child: Dismissible(
                  key: ObjectKey(index),
                  child: ListTile(
                    title: Text(
                      '${value.filteredProductList[index]["code"]}' +
                          '-' +
                          '${value.filteredProductList[index]["item"]}',
                      style: TextStyle(
                          color: widget.type == "sales"
                              ? value.filteredProductList[index]["cartrowno"] ==
                                      null
                                  ? value.filterComselected[index]
                                      ? Colors.green
                                      : Colors.grey[700]
                                  : Colors.green
                              : value.filterComselected[index]
                                  ? Color.fromARGB(255, 224, 61, 11)
                                  : Colors.grey[700],
                          fontSize: 16),
                    ),
                    subtitle: Text(
                      '\u{20B9}${value.filteredProductList[index]["rate1"]}',
                      style: TextStyle(
                        color: P_Settings.ratecolor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            width: size.width * 0.06,
                            child: TextFormField(
                              controller: value.qty[index],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  border: InputBorder.none, hintText: "1"),
                            )),
                        SizedBox(
                          width: 10,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.add,
                          ),
                          onPressed: () async {
                            setState(() {
                              if (value.filterComselected[index] == false) {
                                value.filterComselected[index] =
                                    !value.filterComselected[index];
                                // selected = index;
                              }

                              if (value.qty[index].text == null ||
                                  value.qty[index].text.isEmpty) {
                                value.qty[index].text = "1";
                              }
                            });
                            if (widget.type == "sales") {
                              int max = await OrderAppDB.instance.getMaxCommonQuery(
                                  'orderBagTable',
                                  'cartrowno',
                                  "os='${value.ordernum[0]["os"]}' AND customerid='${widget.customerId}'");

                              print("max----$max");
                              // print("value.qty[index].text---${value.qty[index].text}");

                              rate1 = value.filteredProductList[index]["rate1"];
                              var total = int.parse(rate1) *
                                  int.parse(value.qty[index].text);
                              print("total rate $total");

                              var res = await OrderAppDB.instance
                                  .insertorderBagTable(
                                      value.filteredProductList[index]["item"],
                                      widget.s![0],
                                      widget.s![1],
                                      value.ordernum[0]["os"],
                                      widget.customerId!,
                                      max,
                                      value.filteredProductList[index]["code"],
                                      int.parse(value.qty[index].text),
                                      rate1,
                                      total.toString(),
                                      0);

                              snackbar.showSnackbar(context,
                                  "${value.filteredProductList[index]["code"] + value.filteredProductList[index]['item']} - Added to cart");
                              Provider.of<Controller>(context, listen: false)
                                  .countFromTable(
                                "orderBagTable",
                                widget.os!,
                                widget.customerId!,
                              );
                            }
                            if (widget.type == "return") {
                              rate1 = value.filteredProductList[index]["rate1"];
                              var total = int.parse(rate1) *
                                  int.parse(value.qty[index].text);
                              Provider.of<Controller>(context, listen: false)
                                  .addToreturnList({
                                "item": value.filteredProductList[index]
                                    ["item"],
                                "date": widget.s![0],
                                "time": widget.s![1],
                                "os": value.ordernum[0]["os"],
                                "customer_id": widget.customerId,
                                "code": value.filteredProductList[index]
                                    ["code"],
                                "qty": int.parse(value.qty[index].text),
                                "rate": rate1,
                                "total": total.toString(),
                                "status": 0
                              });
                            }

                            /////////////////////////
                            (widget.customerId!.isNotEmpty ||
                                        widget.customerId != null) &&
                                    (value.filteredProductList[index]["code"]
                                            .isNotEmpty ||
                                        value.filteredProductList[index]
                                                ["code"] !=
                                            null)
                                ? Provider.of<Controller>(context,
                                        listen: false)
                                    .calculateTotal(value.ordernum[0]['os'],
                                        widget.customerId!)
                                : Text("No data");
                          },
                          color: Colors.black,
                        ),
                        IconButton(
                            icon: Icon(
                              Icons.delete,
                              size: 18,
                              // color: Colors.redAccent,
                            ),
                            onPressed: widget.type == "sales"
                                ? value.filteredProductList[index]
                                            ["cartrowno"] ==
                                        null
                                    ? value.filterComselected[index]
                                        ? () async {
                                            String item =
                                                value.filteredProductList[index]
                                                        ["code"] +
                                                    value.filteredProductList[
                                                        index]["item"];
                                            showModal.showMoadlBottomsheet(
                                                widget.os!,
                                                widget.customerId!,
                                                item,
                                                size,
                                                context,
                                                "just added",
                                                value.filteredProductList[index]
                                                    ["code"],
                                                index,
                                                "with company",
                                                Provider.of<Controller>(context,
                                                        listen: false)
                                                    .filteredeValue!,
                                                value.qty[index]);
                                          }
                                        : null
                                    : () async {
                                        String item =
                                            value.filteredProductList[index]
                                                    ["code"] +
                                                value.filteredProductList[index]
                                                    ["item"];
                                        showModal.showMoadlBottomsheet(
                                            widget.os!,
                                            widget.customerId!,
                                            item,
                                            size,
                                            context,
                                            "already in cart",
                                            value.filteredProductList[index]
                                                ["code"],
                                            index,
                                            "with company",
                                            Provider.of<Controller>(context,
                                                    listen: false)
                                                .filteredeValue!,
                                            value.qty[index]);
                                      }
                                : value.filterComselected[index]
                                    ? () async {
                                        String item =
                                            value.filteredProductList[index]
                                                    ["code"] +
                                                value.filteredProductList[index]
                                                    ["item"];
                                        showModal.showMoadlBottomsheet(
                                          widget.os!,
                                          widget.customerId!,
                                          item,
                                          size,
                                          context,
                                          "return",
                                          value.filteredProductList[index]
                                              ["code"],
                                          index,
                                          "with company",
                                          Provider.of<Controller>(context,
                                                  listen: false)
                                              .filteredeValue!,
                                          value.qty[index],
                                        );
                                      }
                                    : null)
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}