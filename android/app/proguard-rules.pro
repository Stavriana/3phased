# Flutter-specific rules
-keep class io.flutter.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn io.flutter.embedding.**
-dontwarn com.google.firebase.**

# Retain annotations
-keepattributes *Annotation*

# Retain generic type information for use by reflection
-keepattributes Signature

# Prevent obfuscation of class names used in JSON serialization/deserialization
-keepnames class * implements java.io.Serializable

# Keep Play Core library
-keep class com.google.android.play.** { *; }
-dontwarn com.google.android.play.**

# Flutter-specific rules
-keep class io.flutter.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn io.flutter.embedding.**
-dontwarn com.google.firebase.**

# Keep annotations
-keepattributes *Annotation*

# Retain generic type information
-keepattributes Signature

# Prevent obfuscation of Serializable classes
-keepnames class * implements java.io.Serializable


# Don't strip debug information (for debugging purposes)
-keepattributes SourceFile,LineNumberTable

