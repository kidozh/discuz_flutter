# webview_cookie_manager compatibility fork

This directory contains the MIT-licensed source from
`fryette/webview_cookie_manager` commit
`8572dd54c437c919aedc8dca6c5bffd25fe74b3`.

The Dart, Android, and iOS implementations are unchanged. The Android build
metadata was simplified to use the application's AGP and repositories, and its
Java compatibility is now declared inside `compileOptions` as required by AGP
9.
