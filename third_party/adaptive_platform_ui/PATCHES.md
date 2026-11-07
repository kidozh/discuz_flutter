# Discuz local package

Based on adaptive_platform_ui 1.0.2 (MIT). This copy preserves the installed
package's iPhone Duo and fixed-toolbar adaptations so builds do not depend on
edits in a developer's pub cache.

The horizontal Liquid Glass toolbar is 60 points tall, excluding the status
area. Its host, body inset, native view and Flutter leading controls share that
height. UIKit's controls retain their standard 44-point height and are centred,
leaving 8 points of vertical clearance. The Duo title fade ends within the title
band so pinned controls below it stay clear. The back button keeps the upstream
circular 44-point shape and is centered within the taller horizontal toolbar.

Upstream 1.0.2 fixes for toolbar semantics, IndexedStack navigation, native
menus, single-mounted tab content and Duo Split View are included.

Upstream 1.0.2 and the official main branch still fix the horizontal toolbar
at 44 points and expose no height setting. The local Dart changes share the
60-point height between host, page insets and native toolbar, and center its
44-point back button. Keep this copy until the public API can
express that spacing without changing the app's native toolbar appearance.
