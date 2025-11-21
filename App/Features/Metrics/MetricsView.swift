//
//  MetricsView.swift
//  App
//
//  Created by Saf on 11/12/25.
//

import SwiftUI

struct MetricsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = MetricsViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Wellness Trends Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Your Wellness Trends")
                                .font(.title3)
                                .fontWeight(.semibold)

                            Spacer()

                            // Time Period Selector
                            HStack(spacing: 8) {
                                ForEach(TimePeriod.allCases, id: \.self) { period in
                                    Button(action: {
                                        viewModel.selectedTimePeriod = period
                                    }) {
                                        Text(period.rawValue)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(viewModel.selectedTimePeriod == period ? .blue : .gray)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                viewModel.selectedTimePeriod == period ?
                                                Color.blue.opacity(0.1) : Color.gray.opacity(0.1)
                                            )
                                            .cornerRadius(20)
                                    }
                                }
                            }
                        }

                        // Chart Placeholder
                        VStack(spacing: 12) {
                            Spacer()

                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 50))
                                .foregroundColor(.gray.opacity(0.4))

                            Text(viewModel.activeMetrics.isEmpty ? "Select metrics below to visualize" : "Tracking \(viewModel.activeMetrics.count) metric\(viewModel.activeMetrics.count == 1 ? "" : "s")")
                                .font(.body)
                                .foregroundColor(.gray)

                            Spacer()
                        }
                        .frame(height: 280)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                                .foregroundColor(.gray.opacity(0.3))
                        )
                    }

                    // Active Metrics Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Active Metrics")
                            .font(.title3)
                            .fontWeight(.semibold)

                        if viewModel.activeMetrics.isEmpty {
                            Text("No metrics selected")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.vertical, 8)
                                .frame(minHeight: 44)
                        } else {
                            FlowLayout(spacing: 12) {
                                ForEach(Array(viewModel.activeMetrics).sorted(), id: \.self) { metric in
                                    MetricPill(
                                        title: metric,
                                        color: viewModel.colorForMetric(metric),
                                        onRemove: { viewModel.toggleMetric(metric) }
                                    )
                                }
                            }
                            .animation(.easeInOut(duration: 0.2), value: viewModel.activeMetrics)
                            .frame(minHeight: 44)
                        }
                    }
                    .frame(minHeight: 80)

                    // Available Metrics Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Available Metrics")
                            .font(.title3)
                            .fontWeight(.semibold)

                        // Lab Values
                        HStack {
                            Image(systemName: "cross.vial")
                                .foregroundColor(.blue)
                            Text("Lab Values")
                                .font(.headline)
                        }

                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(MetricData.labValues) { metric in
                                MetricCard(
                                    icon: metric.icon,
                                    iconColor: metric.iconColor,
                                    title: metric.name,
                                    subtitle: metric.subtitle,
                                    isSelected: viewModel.activeMetrics.contains(metric.name),
                                    onToggle: { viewModel.toggleMetric(metric.name) }
                                )
                            }
                        }

                        // Symptoms
                        HStack {
                            Image(systemName: "heart.text.square")
                                .foregroundColor(.green)
                            Text("Symptoms")
                                .font(.headline)
                        }
                        .padding(.top, 8)

                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(MetricData.symptoms) { metric in
                                MetricCard(
                                    icon: metric.icon,
                                    iconColor: metric.iconColor,
                                    title: metric.name,
                                    subtitle: metric.subtitle,
                                    isSelected: viewModel.activeMetrics.contains(metric.name),
                                    onToggle: { viewModel.toggleMetric(metric.name) }
                                )
                            }
                        }
                    }

                    // Add Custom Metric Button
                    Button(action: {
                        // Action to add custom metric
                    }) {
                        HStack {
                            Image(systemName: "plus")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text("Add Custom Metric")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollDisabled(false)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.primary)
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("Metrics")
                        .font(.headline)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // More options action
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.primary)
                            .rotationEffect(.degrees(90))
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MetricsView()
}
