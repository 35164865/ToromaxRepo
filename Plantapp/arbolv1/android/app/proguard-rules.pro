# Google Maps
-keep class com.google.android.gms.maps.** { *; }
-keep interface com.google.android.gms.maps.** { *; }

# Optional (evita errores si usas reflection o JSON parsing)
-keep class com.google.android.gms.** { *; }
