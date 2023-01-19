import 'dart:async';
import 'package:flutter/material.dart';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:io';

Set<String> prod_id = {'gems_test'};

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = <ProductDetails>[];
  bool _isAvailable = true;
  var _notFoundIds = <String>[];
  bool _loading = false;
  String? _queryProductError;
  bool _purchasePending = false;

  @override
  void initState() {
    final Stream<List<PurchaseDetails>> purchasedUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchasedUpdated.listen((PurchaseDetailsList) {
      _listenToPurchaseUpdated(PurchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (Object e) {
      debugPrint("error: ${e.toString()}");
    });
    initStoreInfo();
    super.initState();
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = <ProductDetails>[];
        _notFoundIds = <String>[];
        _loading = false;
      });
      return;
    }
    Set<String> _subcriptionProductId = prod_id;
    final ProductDetailsResponse productDetailsResponse =
        await _inAppPurchase.queryProductDetails(_subcriptionProductId);
    if (productDetailsResponse.error != null) {
      setState(() {
        _queryProductError = productDetailsResponse.error!.message;
        _isAvailable = isAvailable;
        _products = productDetailsResponse.productDetails;
        _notFoundIds = productDetailsResponse.notFoundIDs;
        debugPrint('_notFoundIds : ${_notFoundIds.toList()}');
        _loading = false;
      });
      return;
    }
    if (productDetailsResponse.productDetails.isEmpty) {
      setState(() {
        _queryProductError = null;
        _isAvailable = isAvailable;
        _products = productDetailsResponse.productDetails;
        _notFoundIds = productDetailsResponse.notFoundIDs;
        debugPrint('_notFoundIds : ${_notFoundIds.toList()}');
        debugPrint(
            'productDetailResponse error: ${productDetailsResponse.error}');
        _loading = false;
      });
      return;
    } else {
      debugPrint('=======}');
    }
    setState(() {
      _isAvailable = _isAvailable;
      _products = productDetailsResponse.productDetails;
      _notFoundIds = productDetailsResponse.notFoundIDs;
      debugPrint('No Product :: ${_notFoundIds.toList()}');
      _purchasePending = false;
      _loading = false;
    });
  }

  _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // to-do implementation of pending purchase situation
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
            //// to-do implementation of after purchased 
            verifyAndDeliverProduct(purchaseDetails);
          }else if(purchaseDetails.status == PurchaseStatus.error){
        handleError(purchaseDetails.error);

          }
          if(purchaseDetails.pendingCompletePurchase){
            await _inAppPurchase.completePurchase(purchaseDetails);
          }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
