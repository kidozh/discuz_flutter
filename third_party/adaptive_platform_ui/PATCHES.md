# Discuz local package

Based on adaptive_platform_ui 1.0.1 (MIT). This copy preserves the installed
package's iPhone Duo and fixed-toolbar adaptations so builds do not depend on
edits in a developer's pub cache.

The horizontal Liquid Glass toolbar is 60 points tall, excluding the status
area. Its host, body inset, native view and Flutter leading controls share that
height. UIKit's controls retain their standard 44-point height and are centred,
leaving 8 points of vertical clearance. The Duo vertical controls and title band
keep their existing layout.
