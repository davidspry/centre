//
//  Created by David Spry on 31/12/2022.
//

import AppKit

struct AlertController {
    public static func errorModal(message: String = "Centre: Error", description: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = description
        alert.icon = NSImage(systemSymbolName: "exclamationmark.circle",
                             accessibilityDescription: "An exclamation mark within a triangle")
        NSRunningApplication.current.activate(options: .activateIgnoringOtherApps)
        alert.runModal()
    }

    public static func errorSound() {
        NSSound.purr?.play()
    }
}
