# R8 / Play Console obfuscation.
# Keep only entry points R8 cannot see. Plugin consumer-rules are merged automatically.

# ── Flutter core ──────────────────────────────────────────────
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

-keepclasseswithmembernames class * {
    native <methods>;
}

-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# ── AndroidX Startup (WorkManager provider) ──────────────────
-keep class androidx.startup.** { *; }
-keep class * extends androidx.startup.InitializationProvider { *; }
-dontwarn androidx.startup.**

# ── AndroidX WorkManager (used by google_mobile_ads) ─────────
-keep class androidx.work.** { *; }
-keep class * extends androidx.work.Worker { *; }
-keep class * extends androidx.work.ListenableWorker { *; }
-dontwarn androidx.work.**

# ── AndroidX Lifecycle ───────────────────────────────────────
-keep class androidx.lifecycle.** { *; }
-dontwarn androidx.lifecycle.**

# ── AndroidX Annotation / Core ───────────────────────────────
-keep class androidx.annotation.** { *; }
-keep class androidx.core.** { *; }
-dontwarn androidx.annotation.**
-dontwarn androidx.core.**

# ── Google Mobile Ads ────────────────────────────────────────
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }
-keep class com.google.android.gms.common.** { *; }
-dontwarn com.google.android.gms.**
-dontwarn com.google.ads.**

# ── In-App Purchase / Billing ────────────────────────────────
-keep class com.android.vending.billing.**
-keep class com.android.billingclient.** { *; }
-keep class com.android.billingclient.api.** { *; }
-keep class com.android.billing.ktx.** { *; }
-dontwarn com.android.billingclient.**
-dontwarn com.android.vending.billing.**

# ── Play Core / Play Features / Play Update ──────────────────
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.tasks.** { *; }
-dontwarn com.google.android.play.**

# ── sqflite (SQLite native) ──────────────────────────────────
-keep class org.sqlite.** { *; }
-keep class org.json.** { *; }
-dontwarn org.sqlite.**

# ── audioplayers ─────────────────────────────────────────────
-keep class xyz.luan.audioplayers.** { *; }
-keep class io.flutter.plugins.audioplayers.** { *; }
-dontwarn xyz.luan.audioplayers.**

# ── shared_preferences ───────────────────────────────────────
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# ── url_launcher ─────────────────────────────────────────────
-keep class io.flutter.plugins.urllauncher.** { *; }

# ── font_awesome_flutter ─────────────────────────────────────
-keep class io.flutter.plugins.font_awesome.** { *; }

# ── Kotlin coroutines (used by plugins) ──────────────────────
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**

# ── General Android / JSON ───────────────────────────────────
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses,EnclosingMethod
-keep class org.json.** { *; }
-keep class * extends java.lang.reflect.Array { *; }
-dontwarn javax.annotation.**
