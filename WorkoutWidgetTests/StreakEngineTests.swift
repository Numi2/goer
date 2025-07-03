import XCTest
@testable import WorkoutWidget

final class StreakEngineTests: XCTestCase {
    func testEmptyTotals() async {
        let streak = await StreakEngine.shared.evaluate(totals: [], threshold: 10_000)
        XCTAssertEqual(streak, 0, "Empty totals should result in a zero-day streak")
    }

    func testAllBelowThreshold() async {
        let totals = Array(repeating: 5_000.0, count: 7)
        let streak = await StreakEngine.shared.evaluate(totals: totals, threshold: 10_000)
        XCTAssertEqual(streak, 0, "No day meets the threshold so streak is zero")
    }

    func testConsecutiveAboveThreshold() async {
        let totals = [12_000, 11_000, 10_500, 10_000, 9_500, 12_000].map(Double.init)
        let streak = await StreakEngine.shared.evaluate(totals: totals, threshold: 10_000)
        XCTAssertEqual(streak, 4, "Streak should count consecutive days from start until first miss")
    }

    func testThresholdEdge() async {
        let totals = [10_000, 10_000, 9_999].map(Double.init)
        let streak = await StreakEngine.shared.evaluate(totals: totals, threshold: 10_000)
        XCTAssertEqual(streak, 2, "Values exactly equal to threshold count towards streak")
    }
}