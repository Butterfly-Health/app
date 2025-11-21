//
//  MetricModels.swift
//  App
//
//  Created by Saf on 11/19/25.
//

import Foundation
import SwiftUI

// MARK: - Metric Model

struct Metric: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    let iconColor: Color
    let subtitle: String
    let category: String
    
    static func == (lhs: Metric, rhs: Metric) -> Bool {
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

// MARK: - Time Period

enum TimePeriod: String, CaseIterable {
    case sevenDays = "7D"
    case oneMonth = "1M"
    case threeMonths = "3M"
}

// MARK: - Metric Category

enum MetricCategory: String {
    case labValues = "Lab Values"
    case symptoms = "Symptoms"
}

// MARK: - Metric Data

struct MetricData {
    static let labValues: [Metric] = [
        Metric(name: "T3 Level", icon: "syringe", iconColor: .blue, subtitle: "pg/mL", category: "Lab Values"),
        Metric(name: "T4 Level", icon: "syringe", iconColor: .purple, subtitle: "ºg/dL", category: "Lab Values"),
        Metric(name: "TPO Antibodies", icon: "staroflife", iconColor: .orange, subtitle: "IU/mL", category: "Lab Values"),
        Metric(name: "Reverse T3", icon: "drop", iconColor: .pink, subtitle: "ng/dL", category: "Lab Values")
    ]
    
    static let symptoms: [Metric] = [
        Metric(name: "Body Temp", icon: "thermometer.medium", iconColor: .orange, subtitle: "∞F", category: "Symptoms"),
        Metric(name: "Sleep Quality", icon: "moon.stars", iconColor: .purple, subtitle: "1-10", category: "Symptoms"),
        Metric(name: "Brain Fog", icon: "brain.head.profile", iconColor: .blue, subtitle: "1-10", category: "Symptoms"),
        Metric(name: "Weight", icon: "scalemass", iconColor: .green, subtitle: "lbs", category: "Symptoms")
    ]
    
    static let defaultActiveMetrics: Set<String> = ["TSH Level", "Energy Level"]
    
    static func colorForMetric(_ metric: String) -> Color {
        switch metric {
        case "TSH Level": return .blue
        case "Energy Level": return .green
        case "T3 Level": return .blue
        case "T4 Level": return .purple
        case "TPO Antibodies": return .orange
        case "Reverse T3": return .pink
        case "Body Temp": return .orange
        case "Sleep Quality": return .purple
        case "Brain Fog": return .blue
        case "Weight": return .green
        default: return .blue
        }
    }
}
