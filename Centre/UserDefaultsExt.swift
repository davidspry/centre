//
//  Created by David Spry on 16/1/2023.
//

import Foundation

extension String {
    static let visibleFrameOnly = "visibleFrameOnly"
}

extension UserDefaults {
    @objc var visibleFrameOnly: Bool {
        get {
            bool(forKey: .visibleFrameOnly)
        }
        set {
            set(newValue, forKey: .visibleFrameOnly)
        }
    }
}
