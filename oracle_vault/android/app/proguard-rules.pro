# ML Kit Texterkennung: das Plugin referenziert alle Schrift-Varianten
# (Chinesisch, Devanagari, Japanisch, Koreanisch), mitgeliefert wird aber nur
# die lateinische. R8 bricht sonst im Release-Build ab:
#   Missing class com.google.mlkit.vision.text.chinese.…
# Die App nutzt ausschließlich lateinische Schrift — die anderen dürfen fehlen.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
