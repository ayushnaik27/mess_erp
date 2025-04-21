import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mess_erp/clerk/mess_bill_provider.dart';
import 'package:mess_erp/clerk/monthly_report_provider.dart';
import 'package:provider/provider.dart';

class MonthlyReportScreen extends StatefulWidget {
  static const routeName = '/monthlyReportScreen';
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  TextEditingController couponPriceController = TextEditingController();
  TextEditingController perDietCostController = TextEditingController();
  bool generating = false;
  @override
  void initState() {
    super.initState();
    getTotalExpenditure();
    getPMSB();
    getNMSB();
    getExtra();
    getAssets();
    getDiets();
  }

  void getTotalExpenditure() async {
    if (Provider.of<MonthlyReportProvider>(context, listen: false)
            .totalMonthlyExpenditure !=
        -1) return;
    await Provider.of<MonthlyReportProvider>(context, listen: false)
        .getTotalExpenditure();
  }

  void getPMSB() async {
    if (Provider.of<MonthlyReportProvider>(context, listen: false)
            .previousMonthStockBalance !=
        -1) return;
    await Provider.of<MonthlyReportProvider>(context, listen: false)
        .getPreviousMonthStockBalance();
  }

  void getNMSB() async {
    if (Provider.of<MonthlyReportProvider>(context, listen: false)
            .nextMonthStockBalance !=
        -1) return;
    await Provider.of<MonthlyReportProvider>(context, listen: false)
        .getNextMonthStockBalance();
  }

  void getAssets() async {
    if (Provider.of<MonthlyReportProvider>(context, listen: false)
            .assetsConsumedThisMonth !=
        -1) return;
    await Provider.of<MonthlyReportProvider>(context, listen: false)
        .getAssetsConsumedThisMonth();
  }

  void getExtra() async {
    if (Provider.of<MonthlyReportProvider>(context, listen: false)
            .totalExtraConsumed !=
        -1) {
      return;
    }

    await Provider.of<MonthlyReportProvider>(context, listen: false)
        .getTotalExtra();
  }

  void getDiets() async {
    await Provider.of<MonthlyReportProvider>(context, listen: false)
        .getTotalDiets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Report'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text(
                      'Total Monthly Expenditure:',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const Expanded(child: SizedBox()),
                    Consumer<MonthlyReportProvider>(
                      builder: (context, value, child) {
                        return value.totalMonthlyExpenditure != -1
                            ? Text(
                                value.totalMonthlyExpenditure.toString(),
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              )
                            : Container();
                      },
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text(
                      'Last Month Stock Balance:',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const Expanded(child: SizedBox()),
                    Consumer<MonthlyReportProvider>(
                      builder: (context, value, child) {
                        return value.previousMonthStockBalance != -1
                            ? Text(
                                value.previousMonthStockBalance.toString(),
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              )
                            : Container();
                      },
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text(
                      'Stock Balance For Next Month:',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const Expanded(child: SizedBox()),
                    Consumer<MonthlyReportProvider>(
                      builder: (context, value, child) {
                        return value.nextMonthStockBalance != -1
                            ? Text(
                                value.nextMonthStockBalance.toString(),
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              )
                            : Container();
                      },
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text(
                      'Assets Consumed This Month:',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const Expanded(child: SizedBox()),
                    Consumer<MonthlyReportProvider>(
                      builder: (context, value, child) {
                        return value.assetsConsumedThisMonth != -1
                            ? Text(
                                value.assetsConsumedThisMonth.toString(),
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              )
                            : Container();
                      },
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text(
                      'Total Extra:',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const Expanded(child: SizedBox()),
                    Consumer<MonthlyReportProvider>(
                      builder: (context, value, child) {
                        return value.totalExtraConsumed != -1
                            ? Text(
                                value.totalExtraConsumed.toString(),
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              )
                            : Container();
                      },
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text(
                      'Total Coupon Price:',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const Expanded(child: SizedBox()),
                    SizedBox(
                      height: 50,
                      width: 150,
                      child: TextField(
                        onChanged: (value) async {
                          Provider.of<MonthlyReportProvider>(context,
                                  listen: false)
                              .setCouponPrice(
                                  double.parse(couponPriceController.text));
                          await Provider.of<MonthlyReportProvider>(context,
                                  listen: false)
                              .getBalance();
                          await Provider.of<MonthlyReportProvider>(context,
                                  listen: false)
                              .getPerDietCost();
                        },
                        controller: couponPriceController,
                        onTapOutside: (event) =>
                            FocusScope.of(context).unfocus(),
                        decoration: InputDecoration(
                            labelText: 'Enter the amount',
                            labelStyle: Theme.of(context).textTheme.labelLarge,
                            border: const OutlineInputBorder(
                                borderSide: BorderSide(width: 0.1))),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text(
                      'Balance:',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const Expanded(child: SizedBox()),
                    Consumer<MonthlyReportProvider>(
                      builder: (context, value, child) {
                        return value.balance != -1
                            ? Text(
                                value.balance.toString(),
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              )
                            : Container();
                      },
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text(
                      'Total Diets:',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const Expanded(child: SizedBox()),
                    Consumer<MonthlyReportProvider>(
                      builder: (context, value, child) {
                        return Text(
                          value.totalDiets.toString(),
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        );
                      },
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text(
                      'Per Diet Cost:',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const Expanded(child: SizedBox()),
                    Consumer<MonthlyReportProvider>(
                      builder: (context, value, child) {
                        return value.perDietCost != -1
                            ? Text(
                                value.perDietCost.toStringAsFixed(2),
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              )
                            : Container();
                      },
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text(
                      'Per Diet Cost (rounded):',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const Expanded(child: SizedBox()),
                    SizedBox(
                      height: 50,
                      width: 150,
                      child: TextField(
                        onChanged: (value) async {
                          Provider.of<MonthlyReportProvider>(context,
                                  listen: false)
                              .setRoundedPerDietCost(
                                  double.parse(perDietCostController.text));
                          await Provider.of<MonthlyReportProvider>(context,
                                  listen: false)
                              .getProfit();
                        },
                        controller: perDietCostController,
                        onTapOutside: (event) =>
                            FocusScope.of(context).unfocus(),
                        decoration: InputDecoration(
                            labelText: 'Enter the amount',
                            labelStyle: Theme.of(context).textTheme.labelLarge,
                            border: const OutlineInputBorder(
                                borderSide: BorderSide(width: 0.1))),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text(
                      'Profit:',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const Expanded(child: SizedBox()),
                    Consumer<MonthlyReportProvider>(
                      builder: (context, value, child) {
                        return value.profit != -1
                            ? Text(
                                value.profit.toStringAsFixed(2),
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              )
                            : Container();
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                  onPressed: generating
                      ? null
                      : () async {
                          log("generate bill pressed");

                          setState(() {
                            generating = true;
                          });

                          await generateBillPressed();
                          deleteLeaves();
                          deleteOldBills();

                          setState(() {
                            generating = false;
                          });
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor),
                  child: generating
                      ? Text('Generating',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.tertiary))
                      : Text('Generate Bill',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.tertiary))),
            ],
          ),
        ),
      ),
    );
  }

  void deleteLeaves() async {
    await Provider.of<MonthlyReportProvider>(context, listen: false)
        .deleteLeaves();
  }

  void deleteOldBills() async {
    await Provider.of<MonthlyReportProvider>(context, listen: false)
        .deleteOldBills();
  }

  Future<void> generateBillPressed() async {
    await Provider.of<MessBillProvider>(context, listen: false)
        .generateBill(double.parse(perDietCostController.text));
  }
}
