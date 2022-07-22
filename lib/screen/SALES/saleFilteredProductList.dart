import 'package:flutter/material.dart';
import 'package:orderapp/components/commoncolor.dart';
import 'package:orderapp/components/customSnackbar.dart';
import 'package:orderapp/components/showMoadal.dart';
import 'package:orderapp/controller/controller.dart';
import 'package:orderapp/db_helper.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaleFilteredProduct extends StatefulWidget {
  String? type;
  String? os;
  List<String>? s;
  String? customerId;
  String? value;

  SaleFilteredProduct({
    required this.type,
    this.customerId,
    this.os,
    this.s,
    this.value,
  });

  @override
  State<SaleFilteredProduct> createState() => _SaleFilteredProductState();
}

class _SaleFilteredProductState extends State<SaleFilteredProduct> {
  String rate1 = "1";

  CustomSnackbar snackbar = CustomSnackbar();
  ShowModal showModal = ShowModal();

  // void _onRefresh() async {
  //   await Future.delayed(Duration(milliseconds: 1000));
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? cid = prefs.getString("cid");
  //   _refreshController.refreshCompleted();
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<Controller>(context, listen: false)
        .filterwithCompany(widget.customerId!, widget.value!,"sale");
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Consumer<Controller>(
        builder: (context, value, child) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: value.salefilteredProductList.length,
            itemBuilder: (BuildContext context, index) {
              return Padding(
                padding: const EdgeInsets.only(left: 0.4, right: 0.4),
                child: Dismissible(
                  key: ObjectKey(index),
                  child: ListTile(
                    title: Text(
                      '${value.salefilteredProductList[index]["code"]}' +
                          '-' +
                          '${value.salefilteredProductList[index]["item"]}',
                      style: TextStyle(
                          color: value.salefilteredProductList[index]
                                      ["cartrowno"] ==
                                  null
                              ? value.filterComselected[index]
                                  ? Colors.green
                                  : Colors.grey[700]
                              : Colors.green,
                          fontSize: 16),
                    ),
                    subtitle: Row(
                      children: [
                        Text(
                          '\u{20B9}${value.salefilteredProductList[index]["rate1"]}',
                          style: TextStyle(
                            color: P_Settings.ratecolor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.055,
                        ),
                        Text(
                          '(tax: \u{20B9}${value.salefilteredProductList[index]["tax"]})',
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
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
                              }

                              if (value.qty[index].text == null ||
                                  value.qty[index].text.isEmpty) {
                                value.qty[index].text = "1";
                              }
                            });

                            int max = await OrderAppDB.instance.getMaxCommonQuery(
                                'salesBagTable',
                                'cartrowno',
                                "os='${value.ordernum[0]["os"]}' AND customerid='${widget.customerId}'");
                            print("max----$max");
                            rate1 = value.salefilteredProductList[index]["rate1"];
                            var total = int.parse(rate1) *
                                int.parse(value.qty[index].text);
                            print("total rate $total");

                            var res =
                                await OrderAppDB.instance.insertsalesBagTable(
                                    value.salefilteredProductList[index]["item"],
                                    widget.s![0],
                                    widget.s![1],
                                    value.ordernum[0]["os"],
                                    widget.customerId!,
                                    max,
                                    value.salefilteredProductList[index]["code"],
                                    int.parse(value.qty[index].text),
                                    rate1,
                                    total.toString(),
                                    "0",
                                    value.salefilteredProductList[index]["hsn"],
                                    // value.salefilteredProductList[index]["tax"],
                                    0.0,
                                    0.0,
                                    0.0,
                                    0);

                            snackbar.showSnackbar(context,
                                "${value.salefilteredProductList[index]["code"] + value.salefilteredProductList[index]['item']} - Added to cart");
                            Provider.of<Controller>(context, listen: false)
                                .countFromTable(
                              "salesBagTable",
                              widget.os!,
                              widget.customerId!,
                            );

                            /////////////////////////////////////////////////////////////
                            (widget.customerId!.isNotEmpty ||
                                        widget.customerId != null) &&
                                    (value.salefilteredProductList[index]["code"]
                                            .isNotEmpty ||
                                        value.salefilteredProductList[index]
                                                ["code"] !=
                                            null)
                                ? Provider.of<Controller>(context,
                                        listen: false)
                                    .calculateorderTotal(value.ordernum[0]['os'],
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
                            onPressed: value.salefilteredProductList[index]
                                        ["cartrowno"] ==
                                    null
                                ? value.filterComselected[index]
                                    ? () async {
                                        String item =
                                            value.salefilteredProductList[index]
                                                    ["code"] +
                                                value.salefilteredProductList[index]
                                                    ["item"];
                                        showModal.showMoadlBottomsheet(
                                            widget.os!,
                                            widget.customerId!,
                                            item,
                                            size,
                                            context,
                                            "just added",
                                            value.salefilteredProductList[index]
                                                ["code"],
                                            index,
                                            "with company",
                                            Provider.of<Controller>(context,
                                                    listen: false)
                                                .salefilteredeValue!,
                                            value.qty[index],
                                            "sales");
                                      }
                                    : null
                                : () async {
                                    String item =
                                        value.salefilteredProductList[index]
                                                ["code"] +
                                            value.salefilteredProductList[index]
                                                ["item"];
                                    showModal.showMoadlBottomsheet(
                                        widget.os!,
                                        widget.customerId!,
                                        item,
                                        size,
                                        context,
                                        "already in cart",
                                        value.salefilteredProductList[index]
                                            ["code"],
                                        index,
                                        "with company",
                                        Provider.of<Controller>(context,
                                                listen: false)
                                            .salefilteredeValue!,
                                        value.qty[index],
                                        "sales");
                                  })
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