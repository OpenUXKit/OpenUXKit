import AppKit
import XCTest
@testable import OpenUXKit

// Parity tests: OpenUXKit (open implementation) vs UXKit (Apple's private framework, TBD-linked).
//
// Goal: For the same fixture, the public-API-observable state of both
// implementations should be identical within a small geometric tolerance.
// This is the ground truth that catches subtle behavioral divergences which
// neither unit tests nor manual Showcase inspection can.
//
// Cross-target import strategy:
//   * UXKit is linked via Apple's TBD stub (Sources/UXKit/UXKit.tbd) and is
//     only available on macOS hosts that actually ship UXKit.framework.
//   * Test target depends on OpenUXKit only; UXKit usage must go through
//     #if canImport(UXKit) guards once the second dependency is wired.
//
// The Package.swift change to add UXKit dependency is deferred until P0+1
// — keeping it isolated avoids accidentally breaking builds on hosts where
// the private framework is missing.
//
// See: Docs/Plans/UXCollectionView-UXKit-Alignment/Plan.md §8 (Parity strategy)

final class UXKitParityTests: XCTestCase {

    // Phase P4: geometry parity
    func test_flowLayoutFrames_matchUXKit_withinTolerance() throws {
        throw XCTSkip("TODO(uxkit-align): wire UXKit target dependency, then implement at Phase P4")

        // Sketch (pseudocode):
        //   let fixture = UXCollectionViewFlowLayoutFixture()
        //   fixture.sections = [10, 20]
        //   let openAttrs = OpenUXKitFlowLayoutHarness.run(fixture)
        //   #if canImport(UXKit)
        //     let realAttrs = UXKitFlowLayoutHarness.run(fixture)
        //     XCTAssertEqual(openAttrs.map(\.frame), realAttrs.map(\.frame),
        //                    accuracy: 0.5)
        //   #endif
    }

    // Phase P9: visible cell set parity
    func test_visibleCellsAfterBatchUpdates_matchUXKit() throws {
        throw XCTSkip("TODO(uxkit-align): wire UXKit target dependency, then implement at Phase P9")
    }

    // Phase P9: selection state parity
    func test_selectionStateAfterRangeSelection_matchesUXKit() throws {
        throw XCTSkip("TODO(uxkit-align): wire UXKit target dependency, then implement at Phase P9")
    }
}
