# Post translation and summaries

Apple posts use the local `apple_post_translation` plugin and Apple's Translation
framework (iOS 18 / macOS 15 APIs). Translation does not require enabling the
app's Foundation Models setting. On systems offering a strategy choice, the
bridge selects `lowLatency`, which uses the dedicated translation models.

Tap Translate to replace the rendered body; tap Show original to restore it.
Hold the button (or right-click on macOS) to choose from `LanguageAvailability.supportedLanguages`.
The selection is local to the mounted post; its default is the device language.
The translation cache is invalidated by post content, identity or language changes.

Only visible text nodes enter TranslationSession. Tags, attributes, image sources,
link targets, standalone URLs, code, hidden content and media remain unchanged.
Link labels are translated. Model output is assigned to DOM text nodes, so it
cannot inject HTML. An error leaves the original body intact.

The native SwiftUI translation task is attached to the active window so Apple
can present language identification/download UI. iOS Simulator returns an explicit
unsupported error; do not use simulator results as translation quality evidence.
A full app rebuild is required after adding the native plugin.

Summaries use the local Foundation Models runtime. When Apple Intelligence is
available, the app enables it by default unless the user has explicitly disabled
it. An unavailable model never enables inference. Automatic summarization defaults
on for bodies longer than 500
characters, including replies. The summary appears below the post author/status,
uses the shared glass surface, and sweeps only while generating. Reduce Motion
and offscreen TickerMode suspend the effect.

Apple summaries stream partial text immediately instead of waiting for every
passage to finish. A memory-only LRU stores 32 completed summaries by content,
language and guardrail policy, and duplicate in-flight requests share inference.
Hidden/unmounted readers stop contributing model work. Input passages use a
conservative token estimate that accounts for the carried summary, leaving room
for instructions and a 512-token response; a native context overflow retries
smaller passages without dropping text. Estimates are not an exact tokenizer.
For example, a 6,000-character Latin test passage now takes one request, compared
with the previous fixed 1,200-character splitting. This is a call-count regression
check, not a device latency benchmark.

Foundation Models API guidance: [context windows](https://developer.apple.com/documentation/foundationmodels/managing-the-context-window),
[generation options](https://developer.apple.com/documentation/foundationmodels/generationoptions).

## Validation

Automated tests cover HTML/URL/media preservation, escaped output, stale-request
handling, inline toggle state, native channel routing, simulator errors, summary
preference persistence, and Reduce Motion. Swift type checks cover iOS and macOS.

Device acceptance still required:

- Rebuild and run on iPhone; use an English post with a Chinese app locale.
- Translate with Apple Intelligence switched off; accept Apple's language download
  prompt if needed. Check text, inline images, link destinations and link labels.
- Toggle original/translation twice, then long-press and choose another language.
- Cancel any system language/download prompt; confirm original remains and retry works.
- Check a long reply as well as the opening post: summary under author, glass style,
  sweep during generation only, Reduce Motion disables animation.

References:
- https://developer.apple.com/documentation/translation/translationsession
- https://developer.apple.com/documentation/translation/languageavailability
- https://developer.apple.com/videos/play/wwdc2024/10117/

## macOS

Build with `flutter build macos --debug`. Both sandbox entitlement files allow
outbound network connections so forum content can load. The Translation host is
attached to the window owned by the calling Flutter engine, independent of focus.

Run the real native smoke test with:

```
flutter test integration_test/apple_translation_macos_test.dart -d macos
```

The first run may show Apple's English/Chinese language download sheet. This test
uses the actual Translation framework, checks for Chinese output and preserved
image attributes, and prints `APPLE_TRANSLATION_NATIVE_RESULT` on success.

Native verification on macOS 27: English → Simplified Chinese returned
`今天天气很好。 让我们去公园散散步吧。` and preserved `<img src="test.jpg">`.
The first run displayed Apple's system language download sheet.

The native macOS integration smoke test passed on this machine, including actual
English-to-Chinese output. The full app additionally uses secure storage during
startup: both entitlement files include the plugin-required keychain access key,
and Runner uses the existing iOS development team for Apple Development signing.
A matching Mac App Development provisioning profile for
`com.kidozh.discuzFlutter` is required. With explicit user approval, Xcode configured the matching Mac Team Provisioning
Profile. The signed build passed codesign verification and launched to the normal
welcome screen; the previous secure-storage entitlement error is resolved.

Source-language detection uses NaturalLanguage on the full visible post before
translating HTML fragments. Every TranslationSession receives an explicit source.
Short labels inherit the post language; only passages with at least 40 letters
and a hypothesis confidence of 0.85 override it for mixed-language content.
