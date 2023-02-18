//
//  Created by David Spry on 31/12/2022.
//

import AppKit
import Foundation
import SwiftUI

struct Dimension: OptionSet {
    let rawValue: Int
    static let vertical = Dimension(rawValue: 1)
    static let horizontal = Dimension(rawValue: 2)
}

enum WindowController {
    fileprivate static let windowListOption = CGWindowListOption(arrayLiteral: .excludeDesktopElements, .optionOnScreenOnly)

    @AppStorage(.visibleFrameOnly) static var useVisibleFrameOnly: Bool = true

    /// Centre the given UI element within the main screen.
    /// - Parameter element The UI element to be centred on the main screen.

    fileprivate static func centre(element: AXUIElement, dimensions: [Dimension]) {
        let sizeKey = kAXSizeAttribute as CFString
        let positionKey = kAXPositionAttribute as CFString

        guard let mainScreen = NSScreen.main else {
            return AlertController.errorModal(description: "The main screen could not be acquired.")
        }

        let screenBounds = useVisibleFrameOnly
            ? mainScreen.visibleFrame
            : mainScreen.frame

        var elementSize = CGSize()
        var elementSizeAttributeValue: AnyObject?
        AXUIElementCopyAttributeValue(element, sizeKey, &elementSizeAttributeValue)

        if let cgSizeType = AXValueType(rawValue: kAXValueCGSizeType) {
            let currentElementSize = elementSizeAttributeValue as! AXValue
            AXValueGetValue(currentElementSize, cgSizeType, &elementSize)
        }

        var elementPosition = CGPoint()
        var elementPositionAttributeValue: AnyObject?
        AXUIElementCopyAttributeValue(element, positionKey, &elementPositionAttributeValue)

        if let cgPointType = AXValueType(rawValue: kAXValueCGPointType) {
            let currentElementPosition = elementPositionAttributeValue as! AXValue
            AXValueGetValue(currentElementPosition, cgPointType, &elementPosition)
        }

        let screenCentre = CGPoint(x: screenBounds.midX, y: screenBounds.midY)
        let centrePosition = CGPoint(x: screenCentre.x + screenBounds.minX - elementSize.width / 2,
                                     y: screenCentre.y - screenBounds.minY - elementSize.height / 2)
        var newPosition = CGPoint(x: dimensions.contains(.horizontal) ? centrePosition.x : elementPosition.x,
                                  y: dimensions.contains(.vertical) ? centrePosition.y : elementPosition.y)

        if let cgPointType = AXValueType(rawValue: kAXValueCGPointType),
           let targetPosition = AXValueCreate(cgPointType, &newPosition) {
            AXUIElementSetAttributeValue(element, positionKey, targetPosition)
        }
    }

    /// Get the currently visible windows as UI elements.
    /// - Parameter usingPredicate An optional predicate to filter the returned windows by their associated process id.

    fileprivate static func getAllWindowsAsAccessibilityUIElements(usingPredicate predicate: ((pid_t) -> Bool)?) -> [AXUIElement]? {
        guard let windowInfoListAsArray = CGWindowListCopyWindowInfo(windowListOption, kCGNullWindowID),
              let windowInfoList = windowInfoListAsArray as? [[String: AnyObject]] else {
            return nil
        }

        return windowInfoList
            .filter { windowInfo in
                guard let windowLayerNumber = windowInfo[kCGWindowLayer as String] as? Int,
                      let windowPid = windowInfo[kCGWindowOwnerPID as String] as? pid_t,
                      windowLayerNumber == 0 else {
                    return false
                }

                if let shouldIncludeWindow = predicate {
                    return shouldIncludeWindow(windowPid)
                } else {
                    return true
                }
            }
            .compactMap { windowInfo -> [AXUIElement]? in
                guard let windowPid = windowInfo[kCGWindowOwnerPID as String] as? pid_t else {
                    return nil
                }

                var activeWindows: AnyObject?
                let applicationRef = AXUIElementCreateApplication(windowPid)
                let error = AXUIElementCopyAttributeValue(applicationRef, kAXWindowsAttribute as CFString, &activeWindows)

                guard error == .success, let windows = activeWindows as? [AXUIElement] else {
                    return nil
                }

                return windows
            }
            .flatMap { $0 }
    }

    /// Centre each open and visible window.

    public static func centreAllOpenWindows(dimensions: [Dimension]) {
        guard let allOpenWindows = getAllWindowsAsAccessibilityUIElements(usingPredicate: nil) else {
            return AlertController.errorModal(description: "The currently-open windows could not be acquired.")
        }

        for window in allOpenWindows {
            centre(element: window, dimensions: dimensions)
        }
    }

    public static func centreAllOpenWindows() {
        return centreAllOpenWindows(dimensions: [.vertical, .horizontal])
    }

    public static func centreAllOpenWindowsVertically() {
        return centreAllOpenWindows(dimensions: [.vertical])
    }

    public static func centreAllOpenWindowsHorizontally() {
        return centreAllOpenWindows(dimensions: [.horizontal])
    }

    /// Centre the currently active window.

    public static func centreCurrentWindow(dimensions: [Dimension]) {
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication,
              let frontmostWindows = getAllWindowsAsAccessibilityUIElements(usingPredicate: { $0 == frontmostApp.processIdentifier }) else {
            return AlertController.errorSound()
        }

        guard let frontmostWindow = frontmostWindows.first else {
            return AlertController.errorSound()
        }

        centre(element: frontmostWindow, dimensions: dimensions)
    }

    public static func centreCurrentWindow() {
        return centreCurrentWindow(dimensions: [.vertical, .horizontal])
    }

    public static func centreCurrentWindowVertically() {
        return centreCurrentWindow(dimensions: [.vertical])
    }

    public static func centreCurrentWindowHorizontally() {
        return centreCurrentWindow(dimensions: [.horizontal])
    }
}
