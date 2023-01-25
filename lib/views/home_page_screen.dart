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
  List<PurchaseDetails> _purchases = <PurchaseDetails>[];
  int _credits = 0;
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
    debugPrint('Init state');
    super.initState();
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    debugPrint(isAvailable.toString());

    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = <ProductDetails>[];
        _notFoundIds = <String>[];
        _loading = false;
      });
      debugPrint('Not available');

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
      debugPrint('Error');

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
      debugPrint('Empty');

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
    debugPrint(_products[0].id.toString());
  }

  _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // to-do implementation of pending purchase situation
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        //// to-do implementation of after purchased
        _purchases.add(purchaseDetails);
        verifyAndDeliverProducts(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        //   handleError(purchaseDetails.error);

      }
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isAvailable ? 'Open for business' : 'Store not available',
        ),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var prod in _products)
            if (_hasPurchased(prod.id) != null) ...[
              Icon(Icons.diamond),
              Text(
                _credits.toString(),
                style: TextStyle(fontSize: 60),
              ),
              ElevatedButton(
                onPressed: () => _spendCredit(_hasPurchased(prod.id)),
                child: Text('Consume'),
              )
            ] else ...[
              Text(
                prod.title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(prod.description),
              Text(
                prod.price,
                style: TextStyle(color: Colors.greenAccent, fontSize: 60),
              ),
              ElevatedButton(
                  onPressed: () => _buyProduct(prod), child: Text('Buy it'))
            ]
        ],
      )),
    );
  }

  dynamic _hasPurchased(String productId) {
    if (_purchases.isNotEmpty) {
      return _purchases.firstWhere(
        (purchase) => purchase.productID == productId,
      );
    }
    return null;
  }

  void verifyAndDeliverProducts(PurchaseDetails purchaseDetails) {
    PurchaseDetails? purchase = _hasPurchased(purchaseDetails.productID);

    if (purchase != null && purchase.status == PurchaseStatus.purchased) {
      _credits = 10;
      setState(() {});
    }
  }

  void _buyProduct(ProductDetails prod) async {
    
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    var purchased =
        await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
  }

  _spendCredit(PurchaseDetails? hasPurchased) async{
    setState(() {
      _credits--;
    });
    
  }
}
