//
//  MetricsViewModel.swift
//  App
//
//  Created by Saf on 11/19/25.
//

import Foundation
import SwiftUI
import Combine

class MetricsViewModel: ObservableObject {
    @Published var selectedTimePeriod: TimePeriod = .oneMonth
    @Published var activeMetrics: Set<String> = MetricData.defaultActiveMetrics
    
    // MARK: - Public Methods
    
    func toggleMetric(_ metric: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if activeMetrics.contains(metric) {
                activeMetrics.remove(metric)
            } else {
                activeMetrics.insert(metric)
            }
        }
    }
    
    func removeActiveMetric(_ metric: String) {
        activeMetrics.remove(metric)
    }
    
    func colorForMetric(_ metric: String) -> Color {
        return MetricData.colorForMetric(metric)
    }
    
    func saveMetrics() {
        // TODO: Persist to storage
    }
}
