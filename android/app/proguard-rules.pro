-keep class ai.deepar.ar.** { *; }
-keep class ai.deepar.ar.core.videotexture.** { *; }
# Impede warnings caso as classes não sejam encontradas
-dontwarn ai.deepar.**
-dontwarn ai.deepar.ar.**
-dontwarn ai.deepar.ar.core.**

# Mantém todas as classes do DeepAR
-keep class ai.deepar.** { *; }
-keep class ai.deepar.ar.** { *; }
-keep class ai.deepar.ar.core.** { *; }
