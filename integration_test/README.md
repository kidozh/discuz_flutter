# Issue 12: iOS Liquid Glass scrolling

Use a test iOS 26+ simulator with Cupertino style selected, Keylol added and no
signed-in forum account. Complete the first-run consent page manually first.
The test will not accept terms or modify stored preferences for you.
Use a dedicated test simulator: installing test/normal builds can reset the
test app's local setup. Do not use a simulator containing important account data.

```sh
flutter drive --no-pub --debug \
  -d <simulator-id> \
  --driver=test_driver/keylol_scroll_driver.dart \
  --target=integration_test/keylol_scroll_test.dart
```

The test boots the real app entry point and loads live public Keylol content.
It verifies finite bounds on the real `UiKitView`, one mounted topic list,
glass cards without per-row `BackdropFilter`, 32 pointer-driven swipes for the
current five categories, and independent scroll-position restoration.

Category changes invoke the production segmented-control callback because
Flutter's integration test API cannot inject UIKit-native touches. This is not
coverage of the native segmented control's touch handling. List scrolling uses
`WidgetTester.timedDrag`, not direct scroll-controller position changes.

Results and three screenshots are saved in `build/issue12_integration/`, including
the before/after offset for each gesture. Network/website changes may fail this
live-content test. A debug simulator run checks functionality and runtime errors;
it does **not** establish real-device frame rate, power use, or thermal behavior.

## Long-post layout regression coverage

The Cupertino thread page promotes a long main post (at least 4000 source HTML
characters) into the outer `CustomScrollView`. `DiscuzHtmlWidget.asSliver` uses
the HTML renderer's block-level sliver mode; it does not truncate or manually
split HTML, or add another vertical scroll view. Header and footer remain in the
same decorated sliver group. Short posts, replies and Material pages keep their
existing box path. The scrolling card retains tint/highlight, without a backdrop
filter; native navigation/toolbars still use Liquid Glass.

Visited HTML blocks retain state (e.g. expanded sections and horizontal media
positions); unvisited blocks are laid out on demand. This is not full memory
virtualization: visiting the whole post can retain all its blocks, just as the
old box layout did initially. A single huge table, quote, code block or unbroken
paragraph stays atomic and may still have expensive layout. Large-image decode,
video playback and system-compositor dropped frames require separate coverage.

`flutter test test/reading_sliver_test.dart` checks asynchronous/empty/refreshed
HTML, initial lazy layout, reaching the footer, numeric offset restoration with
matching visible text, dark large-font rich blocks, expanded-state retention and
the full image-gallery source list. Diagnostic device reports additionally record
`sliver_post_count` and `offset_after_open`. Both box and sliver posts wait for HTML
readiness before restoring their cached offset, with bounded corrections for
estimated sliver extents. The initial cache animation keeps its original target
until the refresh response has settled; it must not finalize a temporarily short
extent while that response is pending. An actual user drag cancels restoration,
including during the wait. The diagnostic
checks the offset against the record read before opening (clamped for shortened
content on the first visit) and fails if it differs by more than one logical pixel.
It records raw error and clamping separately; an immediate reopen cannot pass by
silently clamping away a changed offset. The stop-position
check separately verifies persistence. A single snapshot of mounted widgets can
miss an offscreen sliver: opt-in `post.content` probe records identify the actual
body path (post ID, first/number flags, source length and sliver flag only).

Simple table rows have independent repaint boundaries; complex rowspan/colspan
tables retain their renderer. Regression tests verify cached-row reuse during
horizontal scrolling, retained offsets, links and original image callbacks.
Pending Cupertino avatars use an accessible static initial-letter placeholder
instead of perpetual per-avatar spinners. Successful images (including their
providers), errors, taps and Material's determinate progress remain unchanged.
This does not resize/compress images or change the full-image gallery/download.

Reading page responses are validated before updating posts, cache or the next
page number. A permission-error response may still include placeholder posts;
these are not appended. Later-page errors keep the current article in place and
report failure through the load footer and detailed toast, with the same page
available for retry. First-page errors and expired-account guidance are retained.
Requests capture their page/query; results from an obsolete refresh/query or a
disposed page are ignored. `reading_page_update_test.dart` covers rejected error
responses, successful retry, page-one replacement and cached-prefix preservation.

Reading benchmarks check gallery opening, original URL/list preservation, a
real pointer-driven page swipe and return-position preservation in a separate
phase outside scroll measurements. The script searches from the article top
when no image is visible; it does not assume page midpoint is image content.
Partial visit details are retained even if a later assertion fails. Photo saving
and permission prompts are not exercised on the user's device.

## Physical-device thermal test

`keylol_thermal_native.dart` is a separate, bounded **profile** benchmark. It hosts
the production Keylol page, cards and native Liquid Glass controls in an isolated
app (`com.kidozh.discuz-flutter.perftest`). It does not start the production app,
accept its terms, log in, or initialize ads and push. This measures the page-level
workload, not the complete app or an old-versus-new comparison.

Build from a disposable copy of the iOS project, using
`support/ThermalAppDelegate.swift` only in that copy. Keep the normal Runner bundle
identifier, AppDelegate and entitlements unchanged. The isolated copy removes
push entitlements and disables Firebase auto-init. Verify the built bundle ID and
signature before installing. Do not install the signing-only registration stub.

The benchmark uses normal `WidgetsFlutterBinding`, `LiveWidgetController` for
pointer injection, and `Future.delayed` for waiting. It never calls controller
`pump` or installs a test binding. There are no screenshots or forced frames in
the measurement window: 30 seconds idle, 180 seconds alternating verified pointer
drags (categories rotate every 20 seconds), then 30 seconds idle. A stop button,
leaving the foreground, or a serious/critical thermal notification ends the run.
The native probe restores its battery-monitoring and keep-awake flags afterward.

JSON reports exported to `build/issue12_thermal/` include system thermal
state, battery/charging status, brightness, low-power state, process CPU time,
resident memory and raw Flutter frame timings. Frame percentiles are separated
by phase using raster-finish wall-clock timestamps. Build/raster over-budget
ratios are **not** display-dropped-frame counts or presented FPS; vsync-to-raster
time is **not** touch-to-photon latency. Empty samples are unavailable, not zero.

Thermal states are pressure classifications, **not temperatures in degrees**.
Nominal does not mean the phone feels cool. USB charging, screen brightness,
ambient conditions, background workloads and beta OS/SDK can influence results.
Allow natural cooling before a run, record the conditions, and avoid extrapolating
a short run to battery life or long-term heat. Instruments/system compositor
traces or external temperature measurements are separate follow-up measurements.

The benchmark does not require Flutter's Intel `iproxy` or Rosetta. It writes a
uniquely named `Documents/issue12-thermal-<epoch>.json` inside its own container,
including partial results on failure. Build the isolated profile app with
`FLUTTER_TARGET=integration_test/keylol_thermal_native.dart`, then use:

```sh
xcrun devicectl device install app --device <id> <verified-test-Runner.app>
xcrun devicectl device process launch --device <id> --terminate-existing \
  --console com.kidozh.discuz-flutter.perftest
# Obtain the exact filename from the console or devicectl device info files
# scoped to this app's Documents directory (some hosts omit Flutter print logs).
xcrun devicectl device copy from --device <id> \
  --domain-type appDataContainer \
  --domain-identifier com.kidozh.discuz-flutter.perftest \
  --source Documents/<reported-filename>.json --destination <new-local-file>.json
```

Use the same `DEVELOPER_DIR` override for these commands. This has no attached
Dart sampling profiler; the standalone benchmark runs on the device.
After collecting the report, terminate only the verified **test app** process.

### Heavy reading variant

`keylol_reading_native.dart` reuses the normal-binding host and native probe.
It taps real `ForumThreadWidget` rows to open the production reading page without
test-only layout replacements. Public samples 1048330 (long text) and 1043189 (21 image tags at selection)
are visited twice: first-open + 60 seconds of alternating fast/slow pointer drags,
return, reopen + 25 seconds of drags, return. There is a 15-second idle baseline
at either end. The global stop button remains visible on pushed routes.

Opening, scrolling and return frame timings are separated. Reports include
observed content-ready latency, verified offsets, mounted decoded-image counts,
largest decoded-image pixel count and observed HTML size. Image counts do not
prove every remote image loaded. First-open is not guaranteed cold image cache;
no cache is deleted. Response coverage varies: earlier HTTP preflights exposed
only the main post, while device runs also observe many short login-gated reply
placeholders. This does not establish performance of full authenticated reply
content. Gallery interaction is checked separately; video is not automated.
Back navigation uses `Navigator.pop`.
The entry target must be changed only in the disposable iOS build configuration.

### Reading hotspot diagnostics

`keylol_reading_diagnostic.dart` enables opt-in application timing scopes and
connects to its own existing loopback Dart VM service. It neither starts a new
debug server nor exports its authentication URI. Trace arguments are stripped.
Original timeline-stream settings are restored on exit. If the service cannot
be used, the report records that limitation and retains app-level counters.

Each reading scroll lasts 15 seconds (gesture completion can extend it), starting
from offset zero after the production restore animation. Resetting the viewport
is a separate unmeasured-for-scrolling preparation phase, not pointer coverage.
The optimized version also verifies that the stopped offset equals the stored
reading position within one logical pixel. The global stop/thermal guards apply.

`ReadingPerformanceProbe` is disabled by default in production. Its optional
layout proxy is absent when disabled. Diagnostic timeline recording, boundary
collection and report allocation add overhead: do not treat this as a normal-use
thermal run, nor infer FPS improvement from before/after write counts. The VM
timeline is a bounded ring buffer, so busy phases can lose events. Probe counters
are separately retained per phase. Timeline spans nest: do not add root layout,
child layout and total UI durations together.

Offline analysis:

```sh
ruby integration_test/support/summarize_device_report.rb <report.json>
ruby integration_test/support/summarize_reading_timeline.rb <report.json>
```

The second script emits one pretty-printed JSON object per phase. Its trace
aggregates can include inter-phase events captured before the next clear; use
the raw frame's monotonic interval for exact slow-frame correlations.

### Legacy stress harness — not suitable for normal-use heat estimates

`keylol_thermal_test.dart` and `test_driver/keylol_thermal_driver.dart` retain the
first integration-test harness for reference. On Flutter 3.47.2,
`LiveTestWidgetsFlutterBinding.handleDrawFrame` requests the next engine frame
even with `benchmarkLive`. An idle screen consequently keeps rendering near
60 frames per second on the iPhone 12. Its CPU and heat results include this
artificial load. Use the normal-binding entry above instead; do not mistake the
legacy idle activity for a production app bug or a display FPS measurement.

For Xcode 27 beta, the current Foundation Models plugin needs two new enum cases
handled before compiling. This session uses a compatibility fallback only in the
disposable plugin copy; AI is not exercised. Do not patch the global pub cache or
claim that this fallback implements the new AI cases.
