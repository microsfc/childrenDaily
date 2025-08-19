# Flutter Stripe
# From https://github.com/stripe/stripe-react-native/blob/master/android/proguard-rules.pro
-keepclassmembers class com.facebook.react.bridge.WritableMap {*;}
-keepclassmembers class com.facebook.react.bridge.WritableArray {*;}
-keepclassmembers class com.facebook.react.bridge.ReadableMap {*;}
-keepclassmembers class com.facebook.react.bridge.ReadableArray {*;}

-keepclassmembers class * {
    @com.facebook.react.uimanager.ReactProp <methods>;
    @com.facebook.react.uimanager.ReactPropGroup <methods>;
}

# Stripe SDK
-keep class com.stripe.** { *; }
-keepclassmembers class com.stripe.** { *; }
-dontwarn com.stripe.**

# react-native-stripe-sdk
-keep class com.reactnativestripesdk.** { *; }
-keepclassmembers class com.reactnativestripesdk.** { *; }
-dontwarn com.reactnativestripesdk.**