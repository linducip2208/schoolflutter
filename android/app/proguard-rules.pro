# eSchool release shrinker rules.
# slf4j binding is provided at runtime by plugins; silence the missing-class error.
-dontwarn org.slf4j.**
-keep class org.slf4j.** { *; }
