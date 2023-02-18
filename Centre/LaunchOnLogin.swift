//
//  Created by David Spry on 13/1/2023.
//

import ServiceManagement
import SwiftUI

struct LaunchOnLogin {
    fileprivate static let observable = Observable()

    public static var isEnabled: Bool {
        get {
            SMAppService.mainApp.status == .enabled
        }
        set(shouldBeEnabled) {
            guard shouldBeEnabled != isEnabled else {
                return
            }

            observable.objectWillChange.send()

            do {
                if shouldBeEnabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to \(shouldBeEnabled ? "enable" : "disable") launch-on-login: \(error.localizedDescription)")
            }
        }
    }
}

extension LaunchOnLogin {
    final class Observable: ObservableObject {
        var isEnabled: Bool {
            get { LaunchOnLogin.isEnabled }
            set { LaunchOnLogin.isEnabled = newValue }
        }
    }
}

extension LaunchOnLogin {
    public struct Toggle<Label: View>: View {
        @ObservedObject private var launchAfterLogin = LaunchOnLogin.observable
        private let label: Label

        public init(@ViewBuilder label: () -> Label) {
            self.label = label()
        }

        public var body: some View {
            SwiftUI.Toggle(isOn: $launchAfterLogin.isEnabled) { label }
        }
    }
}
