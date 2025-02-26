import 'dart:io';
import 'dart:convert';
import 'package:pay/pay.dart' as pay;
import 'package:children/config.dart';
import 'package:flutter/material.dart';
import '../models/payment_methods.dart';
import 'package:http/http.dart' as http;
import 'package:children/widgets/platform_pay_button.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:stripe_platform_interface/stripe_platform_interface.dart';


const _paymentItems = [
  pay.PaymentItem(
    label: 'Total',
    amount: '99.99',
    status: pay.PaymentItemStatus.final_price,
  )
];

const stripePublishableKey =  "pk_test_51QrsraCiI9KAAR1QoiaDEXhJQdBc7k1Oe6jxi2HBVpuNtHFJfRoE6RC1BHaLfbTHVYGTVVVrTJCpjl5Lqjp4It9S00PHsTWeL1";

class PaymentScreen extends StatefulWidget {
  PaymentScreen({super.key});
  static const routeName = '/google_pay';

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final items = [
    ApplePayCartSummaryItem.immediate(label: 'Product Test', amount: '0.01')
  ];
  bool _isPaymentSheetLoading = false;

  final shippingMethods = [
    ApplePayShippingMethod(
      identifier: 'free',
      detail: 'Arrives by July 2',
      label: 'Free Shipping',
      amount: '0.0',
    ),
    ApplePayShippingMethod(
      identifier: 'standard',
      detail: 'Arrives by June 29',
      label: 'Standard Shipping',
      amount: '3.21',
    )
  ];

  @override
  void initState() {
    stripe.Stripe.instance.isPlatformPaySupportedListenable.addListener(update);
    super.initState();
  }

  @override
  void dispose() {
    stripe.Stripe.instance.isPlatformPaySupportedListenable.removeListener(update);
    super.dispose();
  }

  void update() {
    setState(() {});
  }

  Future<void> initPaymentSheet() async {
    setState(() {
      _isPaymentSheetLoading = true;
    });
    try {
      // 1. 從你的後端伺服器取得 Payment Intent 的 client secret
      final response = await fetchPaymentIntentClientSecret();
      final clientSecret = response['clientSecret'];
      // 2. 初始化 Payment Sheet
      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Flutter Stripe Store',
          style: ThemeMode.system,
          googlePay: PaymentSheetGooglePay(merchantCountryCode: "US", currencyCode: "usd"), 
        ),
      );

      setState(() {
        _isPaymentSheetLoading = false;
      });
    } catch (e) {
      setState(() {
        _isPaymentSheetLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initiating Payment Sheet: $e')),
      );
      rethrow;
    } finally {
      setState(() {
        _isPaymentSheetLoading = false;
      });
    }
  }

  Future<void> displayPaymentSheet() async {
    setState(() {
      _isPaymentSheetLoading = true;
    });
    try {
      // 3. 顯示 Payment Sheet
      await stripe.Stripe.instance.presentPaymentSheet();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error displaying Payment Sheet: $e')),
      );
      rethrow;
    } finally {
      setState(() {
        _isPaymentSheetLoading = false;
      });
    }
  }   

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Pay'),
      ),
      body: Padding(padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(onPressed: _handleGooglePayPress, child: Text('Google Pay')),
          //  pay.GooglePayButton(
          // pay.GooglePayButton(
          //   paymentConfiguration: pay.PaymentConfiguration.fromJsonString(
          //     _paymentProfile,
          //   ),
          //   paymentItems: _paymentItems,
          //   margin: const EdgeInsets.only(top: 15),
          //   onPaymentResult: onGooglePayResult,
          //   loadingIndicator: const Center(
          //     child: CircularProgressIndicator(),
          //   ),
          //   onPressed: () async {},
          //   childOnError: Text('Google Pay is not available in this device'),
          //   onError: (e) {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(
          //         content: Text(
          //             'There was an error while trying to perform the payment'),
          //       ),
          //     );
          //   },
          // ),
          if (stripe.Stripe.instance.isPlatformPaySupportedListenable.value)
            PlatformPayButton(
            onShippingContactSelected: (contact) async {
              debugPrint('Shipping contact updated $contact');

              // Mandatory after entering a shipping contact
              await stripe.Stripe.instance.updatePlatformSheet(
                params: PlatformPaySheetUpdateParams.applePay(
                  summaryItems: items,
                  shippingMethods: shippingMethods,
                  errors: [],
                ),
              );

              return;
            },
            onShippingMethodSelected: (method) async {
              debugPrint('Shipping method updated $method');
              // Mandatory after entering a shipping contact
              await stripe.Stripe.instance.updatePlatformSheet(
                params: PlatformPaySheetUpdateParams.applePay(
                  summaryItems: items,
                  shippingMethods: shippingMethods,
                  errors: [],
                ),
              );

              return;
            },
            onCouponCodeEntered: (couponCode) {
              debugPrint('set coupon $couponCode');
            },
            onOrderTracking: () async {
              debugPrint('set order tracking');

              /// Provide a URL to your web service that will provide the order details
              ///
              await stripe.Stripe.instance.configurePlatformOrderTracking(
                  orderDetails: PlatformPayOrderDetails.applePay(
                orderTypeIdentifier: 'orderTypeIdentifier',
                orderIdentifier: 'https://your-web-service.com/v1/orders/',
                webServiceUrl: 'webServiceURL',
                authenticationToken: 'token',
              ));
            },
            type: PlatformButtonType.buy,
            appearance: PlatformButtonStyle.whiteOutline,
            onPressed: () => _handlePayPress(
              summaryItems: items,
              shippingMethods: shippingMethods,
            ),
          )
          else
            Text('Apple Pay is not available in this device'),
         ],
        ),
      ),
    );
  }

  Future<void>_handleGooglePayPress() async {
    try {
      await initPaymentSheet();
      await displayPaymentSheet();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  } 

  Future<void> _handlePayPress({
    required List<ApplePayCartSummaryItem> summaryItems,
    required List<ApplePayShippingMethod> shippingMethods,
  }) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      // 1. fetch Intent Client Secret from backend
      final response = await fetchPaymentIntentClientSecret();
      final clientSecret = response['clientSecret'];

      // 2. Confirm apple pay payment
      await stripe.Stripe.instance.confirmPlatformPayPaymentIntent(
        clientSecret: clientSecret,
        confirmParams: PlatformPayConfirmParams.applePay(
          applePay: ApplePayParams(
              cartItems: items,
              requiredShippingAddressFields: [
                ApplePayContactFieldsType.name,
                ApplePayContactFieldsType.postalAddress,
                ApplePayContactFieldsType.emailAddress,
                ApplePayContactFieldsType.phoneNumber,
              ],
              shippingMethods: shippingMethods,
              merchantCountryCode: 'Es',
              currencyCode: 'EUR',
              supportsCouponCode: true,
              couponCode: 'Coupon'),
        ),
      );
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
              content: Text('Apple Pay payment successfully completed')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      rethrow;
    }
  }

  Future<void> onGooglePayResult(paymentResult) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      debugPrint(paymentResult.toString());
      // 2. fetch Intent Client Secret from backend
      final response = await fetchPaymentIntentClientSecret();
      final clientSecret = response['clientSecret'];
      final token =
          paymentResult['paymentMethodData']['tokenizationData']['token'];
      final tokenJson = Map.castFrom(json.decode(token));
      debugPrint(tokenJson.toString());

      final params = stripe.PaymentMethodParams.cardFromToken(
        paymentMethodData: stripe.PaymentMethodDataCardFromToken(
          token: tokenJson['id'], // TODO extract the actual token
        ),
      );

      // 3. Confirm Google pay payment method
      await stripe.Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: params,
      );

      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
              content: Text('Google Pay payment successfully completed')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<Map<String, dynamic>> fetchPaymentIntentClientSecret() async {
    final url = Uri.parse('$kApiUrl/create-payment-intent');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': 'example@gmail.com',
        'currency': 'usd',
        'items': ['id-1'],
        'request_three_d_secure': 'any',
      }),
    );
    return json.decode(response.body);
  }
}

final _paymentProfile = """{
  "provider": "google_pay",
  "data": {
    "environment": "TEST",
    "apiVersion": 2,
    "apiVersionMinor": 0,
    "allowedPaymentMethods": [
      {
        "type": "CARD",
        "tokenizationSpecification": {
          "type": "PAYMENT_GATEWAY",
          "parameters": {
            "gateway": "stripe",
            "stripe:version": "2020-08-27",
            "stripe:publishableKey": "$stripePublishableKey"
          }
        },
        "parameters": {
          "allowedCardNetworks": ["VISA", "MASTERCARD"],
          "allowedAuthMethods": ["PAN_ONLY", "CRYPTOGRAM_3DS"],
          "billingAddressRequired": true,
          "billingAddressParameters": {
            "format": "FULL",
            "phoneNumberRequired": true
          }
        }
      }
    ],
    "merchantInfo": {
      "merchantId": "01234567890123456789",
      "merchantName": "Example Merchant Name"
    },
    "transactionInfo": {
      "countryCode": "US",
      "currencyCode": "USD"
    }
  }
}""";
