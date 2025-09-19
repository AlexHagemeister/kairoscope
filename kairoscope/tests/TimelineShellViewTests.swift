#if canImport(XCTest) && canImport(UIKit)
import XCTest
import SwiftUI
import UIKit
@testable import kairoscope

final class TimelineShellViewTests: XCTestCase {
    func testTitleIsVisible() {
        let view = TimelineShellView()
        let hosting = UIHostingController(rootView: view)
        hosting.loadViewIfNeeded()

        let foundLabel = findLabel(in: hosting.view, text: "Kairoscope")
        XCTAssertNotNil(foundLabel)
    }

    func testAnchorPlaceholderExists() {
        let view = TimelineShellView()
        let hosting = UIHostingController(rootView: view)
        hosting.loadViewIfNeeded()

        XCTAssertTrue(findAccessibilityElement(in: hosting.view, label: "Present moment anchor"))
    }

    private func findLabel(in view: UIView?, text: String) -> UILabel? {
        guard let view else { return nil }
        if let label = view as? UILabel, label.text == text {
            return label
        }
        for subview in view.subviews {
            if let label = findLabel(in: subview, text: text) {
                return label
            }
        }
        return nil
    }

    private func findAccessibilityElement(in view: UIView?, label: String) -> Bool {
        guard let view else { return false }
        if view.accessibilityLabel == label {
            return true
        }
        return view.subviews.contains { findAccessibilityElement(in: $0, label: label) }
    }
}

#endif
