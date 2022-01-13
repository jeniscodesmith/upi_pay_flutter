import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:upi_pay/upi_pay.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String? _upiAddrError;

  final _upiAddressController = TextEditingController();
  final _amountController = TextEditingController(text:  '10.00');
  bool _isUpiEditable = false;
  GlobalKey<FormState> _formkey = GlobalKey<FormState>();

   List<ApplicationMeta> appMetaList = [];

  getUpiPays()async{
    appMetaList =  await UpiPay.getInstalledUpiApplications( statusType: UpiApplicationDiscoveryAppStatusType.all);

  }
  String? _validateUpiAddress(String value) {
    if (value.isEmpty) {
      return 'UPI VPA is required.';
    }
    if (value.split('@').length != 2) {
      return 'Invalid UPI VPA';
    }
    return null;
  }


   Future<void> _onTap(ApplicationMeta app) async {
    if(_formkey.currentState!.validate()) {
      final transactionRef = Random.secure().nextInt(1 << 32).toString();
      print("Starting transaction with id $transactionRef");

      final a = await UpiPay.initiateTransaction(
        amount: _amountController.text,
        app: app.upiApplication,
        receiverName: 'Jenis',
        receiverUpiAddress: _upiAddressController.text,
        transactionRef: transactionRef,
        transactionNote: 'UPI Payment',
        // merchantCode: '7372',
      );

      print(a);
    }
   }









  @override
  void initState() {
    Future.delayed(Duration.zero,()async{

      await  getUpiPays();
      print(appMetaList.toString());
    });
    super.initState();
  }



  Widget _submitButton() {
    return Container(
      margin: EdgeInsets.only(top: 32),
      child: Row(
        children: <Widget>[
          Expanded(
            child: MaterialButton(
              onPressed: () async => await _onTap(appMetaList[0]),
              child: Text('Initiate Transaction',
                  style: Theme.of(context)
                      .textTheme
                      .button!
                      .copyWith(color: Colors.white)),
              color: Theme.of(context).accentColor,
              height: 48,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _androidApps() {
    return Container(
      margin: EdgeInsets.only(top: 32, bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 12),
            child: Text(
              'Pay Using',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          if (appMetaList.isNotEmpty) _appsGrid(appMetaList.map((e) => e).toList()),
        ],
      ),
    );
  }

  Widget _iosApps() {
    return Container(
      margin: EdgeInsets.only(top: 32, bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 24),
            child: Text(
              'One of these will be invoked automatically by your phone to '
                  'make a payment',
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 12),
            child: Text(
              'Detected Installed Apps',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          if (appMetaList.isNotEmpty) _discoverableAppsGrid(),
          Container(
            margin: EdgeInsets.only(top: 12, bottom: 12),
            child: Text(
              'Other Supported Apps (Cannot detect)',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          if (appMetaList.isNotEmpty) _nonDiscoverableAppsGrid(),
        ],
      ),
    );
  }

  GridView _discoverableAppsGrid() {
    List<ApplicationMeta> metaList = [];
    appMetaList.forEach((e) {
      if (e.upiApplication.discoveryCustomScheme != null) {
        metaList.add(e);
      }
    });
    return _appsGrid(metaList);
  }

  GridView _nonDiscoverableAppsGrid() {
    List<ApplicationMeta> metaList = [];
    appMetaList.forEach((e) {
      if (e.upiApplication.discoveryCustomScheme == null) {
        metaList.add(e);
      }
    });
    return _appsGrid(metaList);
  }

  GridView _appsGrid(List<ApplicationMeta> apps) {
    apps.sort((a, b) => a.upiApplication
        .getAppName()
        .toLowerCase()
        .compareTo(b.upiApplication.getAppName().toLowerCase()));
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      // childAspectRatio: 1.6,
      physics: NeverScrollableScrollPhysics(),
      children: apps
          .map(
            (it) => Material(
          key: ObjectKey(it.upiApplication),
          // color: Colors.grey[200],
          child: InkWell(
            onTap: Platform.isAndroid ? () async => await _onTap(it) : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                it.iconImage(48),
                Container(
                  margin: EdgeInsets.only(top: 4),
                  alignment: Alignment.center,
                  child: Text(
                    it.upiApplication.getAppName(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      )
          .toList(),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('UPI'),),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: <Widget>[

            //UPI TEXTFIELD
            Form(
              key: _formkey,
              child: Container(
                margin: EdgeInsets.only(top: 32),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: _upiAddressController,
                        validator: (value){
                          if(value!.isEmpty){
                            return "Enter UPI address";
                          }
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'address@upi',
                          labelText: 'Receiving UPI Address',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 32),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Amount',
                      ),
                    ),
                  ),
                ],
              ),
            )   ,
            if (Platform.isIOS) _submitButton(),
            Platform.isAndroid ? _androidApps() : _iosApps(),
          ],
        ),
      )
    );
  }
}


