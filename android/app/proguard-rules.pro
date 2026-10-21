# Keep Google Play Billing (used by the single "Buy Me a Coffee" IAP).
-keep class com.android.billingclient.** { *; }
-dontwarn com.android.billingclient.**
# Keep Flutter plugin registrant entry points.
-keep class io.flutter.plugins.** { *; }
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
