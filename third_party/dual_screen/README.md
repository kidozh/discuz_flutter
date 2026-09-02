# dual_screen compatibility fork

This directory contains the MIT-licensed `dual_screen` 1.0.5 source from
`mwdavis84/flutter-dualscreen` commit
`dd225c00293b5504a2d4b11787a00b2f1f81f6a1`.

Only the Android build metadata was modernized for this application:

- replaced the removed JCenter repository with the root project's repositories;
- removed the nested Android Gradle Plugin and Kotlin version declarations;
- aligned Java and Kotlin bytecode with Java 17;
- retained the original Dart and Android implementation.

The local copy can be removed once an upstream release supports the project's
current Flutter and Android Gradle Plugin versions.
