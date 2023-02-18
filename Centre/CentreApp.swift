//
//  Created by David Spry on 31/12/2022.
//

import HotKey
import SwiftUI

func askForPermission(withPrompt shouldPrompt: Bool) -> Bool {
    let prompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
    let options = [prompt: shouldPrompt] as CFDictionary
    return AXIsProcessTrustedWithOptions(options)
}

@main
struct CentreApp: App {
    @State var appHasAccessibilityPermission: Bool = askForPermission(withPrompt: true)

    fileprivate typealias Windows = WindowController
    fileprivate let hotKeys: [HotKey] = [
        HotKey(key: .zero, modifiers: [.command, .option],
               keyDownHandler: Windows.centreCurrentWindow),
        HotKey(key: .zero, modifiers: [.command, .option, .shift],
               keyDownHandler: Windows.centreAllOpenWindows),
        HotKey(key: .h, modifiers: [.command, .option],
               keyDownHandler: Windows.centreCurrentWindowHorizontally),
        HotKey(key: .v, modifiers: [.command, .option],
               keyDownHandler: Windows.centreCurrentWindowVertically),
        HotKey(key: .h, modifiers: [.command, .option, .shift],
               keyDownHandler: Windows.centreAllOpenWindowsHorizontally),
        HotKey(key: .v, modifiers: [.command, .option, .shift],
               keyDownHandler: Windows.centreAllOpenWindowsVertically)
    ]

    @AppStorage(.visibleFrameOnly) var useVisibleFrameOnly: Bool = true

    var body: some Scene {
        MenuBarExtra("Centre", systemImage: "plus") {
            Group {
                Group {
                    Button("Centre Active Window") { Windows.centreCurrentWindow() }
                        .keyboardShortcut(KeyEquivalent("0"), modifiers: [.command, .option])
                    
                    Button("Centre Visible Windows") { Windows.centreAllOpenWindows() }
                        .keyboardShortcut(KeyEquivalent("0"), modifiers: [.command, .option, .shift])
                    
                    Divider()
                }
                
                Group {
                    Button("Horizontally Centre Active Window") { Windows.centreCurrentWindowHorizontally() }
                        .keyboardShortcut(KeyEquivalent("h"), modifiers: [.command, .option])
                    
                    Button("Horizontally Centre Visible Windows") { Windows.centreAllOpenWindowsHorizontally() }
                        .keyboardShortcut(KeyEquivalent("h"), modifiers: [.command, .option, .shift])
                    
                    Divider()
                }
                
                Group {
                    Button("Vertically Centre Active Window") { Windows.centreCurrentWindowVertically() }
                        .keyboardShortcut(KeyEquivalent("v"), modifiers: [.command, .option])
                    
                    Button("Vertically Centre Visible Windows") { Windows.centreAllOpenWindowsVertically() }
                        .keyboardShortcut(KeyEquivalent("v"), modifiers: [.command, .option, .shift])
                    
                    Divider()
                }

                Toggle("Account for Dock & Menu Bar", isOn: WindowController.$useVisibleFrameOnly)
                    .onChange(of: useVisibleFrameOnly) { newToggleValue in
                        Windows.useVisibleFrameOnly = newToggleValue
                    }

                LaunchOnLogin.Toggle {
                    Text("Launch on Login")
                }
            }
            .disabled(!appHasAccessibilityPermission)

            Divider()

            Button {
                self.appHasAccessibilityPermission = askForPermission(withPrompt: true)
            } label: {
                Text("Verify Permission")
            }

            Divider()

            Button("Quit") { NSApplication.shared.terminate(nil) }
                .keyboardShortcut(KeyEquivalent("Q"), modifiers: [.command])
        }
    }

    fileprivate func hideMaximiseButton() {
        NSApplication.shared.mainWindow?.standardWindowButton(NSWindow.ButtonType.zoomButton)?.isHidden = true
    }
}
