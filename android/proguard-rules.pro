# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in ${sdk.dir}/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Add any project specific keep options here:

# Keep MethodChannel related classes to ensure Flutter communication works properly
-keep class io.flutter.plugin.common.** {
    *;
}

# Keep the plugin's main class and methods
-keep class com.datashield.oneclicklogin.** {
    *;
}

# Keep AAR library classes to prevent further obfuscation
-keep class com.datashield.oneclick.** {
    *;
}

# Keep all native method names and signatures
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep all enum values to prevent name obfuscation
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep all custom views and their constructors
-keep public class * extends android.view.View {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
    public void set*(...);
}

# Keep all parcelable classes and their CREATOR fields
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep all Serializable classes and their serialVersionUID fields
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Preserve annotation attributes
-keepattributes *Annotation*

# Preserve line numbers for debugging
-keepattributes SourceFile,LineNumberTable

# If your plugin uses WebView with JS, uncomment the following
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# For testing purposes, you might want to keep your test classes
#-dontwarn org.junit.**
#-dontwarn androidx.test.**
#-keep class org.junit.** {
#    *;
#}
#-keep class androidx.test.** {
#    *;
#}