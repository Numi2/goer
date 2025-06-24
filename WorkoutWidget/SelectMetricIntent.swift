import AppIntents

/// An intent the user can configure inside the widget gallery to decide which
/// metric they want to use for their streak as well as the desired threshold.
struct SelectMetricIntent: AppIntent, WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Select Health Goal"
    static let description = IntentDescription("Choose which health metric and threshold should be used when calculating your daily streak.")

    @Parameter(title: "Metric")
    var metric: MetricAppEnum?

    /// The daily goal. For **steps** this is an absolute number (e.g. 10000).
    /// Using `Double` instead of `Int` keeps the door open for metrics that
    /// might be fractional (eg. kilometres, calories).
    @Parameter(title: "Threshold", default: 10_000)
    var threshold: Double?

    // Provide sensible defaults so the widget shows meaningful data right away
    init() {
        self.metric = .steps
        self.threshold = 10_000
    }
}
