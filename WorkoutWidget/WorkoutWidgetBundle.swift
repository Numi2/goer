/*
Abstract:
A widget bundle that shows the Live Activity and step tracking widgets.
*/

import WidgetKit
import SwiftUI

@main
struct WorkoutWidgetBundle: WidgetBundle {
    var body: some Widget {
        WorkoutWidgetLiveActivity()
        DailySummaryWidget()
        HourlyStepsWidget()
        MonthlyStepsWidget()
        StreakWidget()
    }
}
