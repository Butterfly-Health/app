//
//  ContentView.swift
//  App
//
//  Created by Saf on 2025-09-22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var greetingViewModel = GreetingViewModel()
    @State private var selectedTab: Int = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGroupedBackground).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    topBar
                    GreetingView(viewModel: greetingViewModel)
                    watchCard
                    quickActions
                    healthTrends
                    flareAlert
                    todaysSummary
                    recentMeals
                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }

            bottomTabBar
        }
    }
    
    // MARK: - Top bar
    private var topBar: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(colors: [Color.blue.opacity(0.9), Color.green.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 32, height: 32)
                .overlay(Image(systemName: "heart.fill").foregroundColor(.white))

            Text("Butterfly")
                .font(.title3).fontWeight(.semibold)
                .foregroundColor(.primary)

            Spacer()

            Button(action: {}) {
                Image(systemName: "person.fill")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }


    // MARK: - Watch Card
    private var watchCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "applelogo").foregroundColor(.green)
                .font(.system(size: 18))
            VStack(alignment: .leading, spacing: 2) {
                Text("Apple Watch Connected").font(.subheadline).fontWeight(.semibold)
                Text("Last sync: 2 min ago").font(.caption).foregroundColor(.green)
            }
            Spacer()
            Circle().fill(Color.green).frame(width: 10, height: 10)
        }
        .padding(16)
        .background(Color.green.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.green.opacity(0.2), lineWidth: 1))
    }

    // MARK: - Quick Actions
    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions").font(.title2).fontWeight(.semibold)
            HStack(spacing: 14) {
                ActionCard(gradient: [.purple.opacity(0.7), .purple],
                           title: "Log Symptoms",
                           subtitle: "Track daily feelings",
                           icon: "plus")
                ActionCard(gradient: [.purple.opacity(0.8), .purple.opacity(0.9)],
                           title: "Add Meal",
                           subtitle: "Track iodine intake",
                           icon: "fork.knife")
            }
        }
    }

    // MARK: - Health Trends
    private var healthTrends: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Health Trends").font(.title2).fontWeight(.semibold)
                Spacer()
                Button("View All") {}
                    .font(.subheadline).foregroundColor(.blue)
            }
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 2).fill(Color.blue).frame(width: 12, height: 12)
                Text("Number of hours of REM sleep").font(.footnote).foregroundColor(.secondary)
            }
            .padding(.leading, 2)

            SimpleLineChart(data: [2.8, 1.9, 2.4, 3.3, 1.2, 1.8, 2.7])
                .frame(height: 140)
                .padding(.vertical, 6)

            HStack {
                ForEach(["Mon","Tue","Wed","Thu","Fri","Sat","Sun"], id: \.self) { d in
                    Text(d).font(.footnote).foregroundColor(.secondary).frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.systemGray5), lineWidth: 1))
    }

    // MARK: - Flare Alert
    private var flareAlert: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange)
                .font(.system(size: 18))
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 8) {
                Text("Potential Flare Alert").font(.headline)
                Text("Your fatigue and mood symptoms are similar to patterns before previous flares.")
                    .font(.subheadline).foregroundColor(.secondary)
                Button(action: {}) {
                    Text("View Details")
                        .font(.subheadline).fontWeight(.semibold)
                        .padding(.horizontal, 16).padding(.vertical, 8)
                        .background(Capsule().fill(Color.orange))
                        .foregroundColor(.white)
                }
                .padding(.top, 2)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Color.orange.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.orange.opacity(0.25), lineWidth: 1))
    }

    // MARK: - Today's Summary
    private var todaysSummary: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Today's Summary").font(.title2).fontWeight(.semibold)
//            SummaryRow(icon: "thermometer", tint: .pink, title: "Symptoms Logged", subtitle: "3 symptoms today", trailing: Text("3").font(.title2).fontWeight(.semibold).foregroundColor(.red))
//            SummaryRow(icon: "leaf.fill", tint: .green, title: "Iodine Intake", subtitle: "Target: 150µg", trailing: Text("127µg").font(.title2).fontWeight(.bold).foregroundColor(.green))
        }
    }

    // MARK: - Recent Meals
    private var recentMeals: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Recent Meals").font(.title2).fontWeight(.semibold)
                Spacer()
                Button("View All") {}
                    .font(.subheadline).foregroundColor(.blue)
            }
            MealRow(title: "Breakfast", subtitle: "Oatmeal with berries", trailing: "45µg iodine")
            MealRow(title: "Lunch", subtitle: "Salmon salad", trailing: "82µg iodine")
        }
    }

    // MARK: - Bottom Tab Bar
    private var bottomTabBar: some View {
        HStack {
            TabBarItem(icon: "house.fill", label: "Home", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            TabBarItem(icon: "chart.bar.fill", label: "Metrics", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            TabBarItem(icon: "fork.knife", label: "Meals", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
            TabBarItem(icon: "heart.fill", label: "Symptoms", isSelected: selectedTab == 3) {
                selectedTab = 3
            }
            TabBarItem(icon: "person.fill", label: "Profile", isSelected: selectedTab == 4) {
                selectedTab = 4
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .overlay(Rectangle().fill(Color(.systemGray5)).frame(height: 0.5), alignment: .top)
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

// MARK: - Components

private struct ActionCard: View {
    var gradient: [Color]
    var title: String
    var subtitle: String
    var icon: String

    var body: some View {
        Button(action: {}) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.white)
                    Text(title)
                        .font(.headline).foregroundColor(.white)
                    Text(subtitle)
                        .font(.caption).foregroundColor(.white.opacity(0.9))
                }
                Spacer()
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 110)
            .background(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

private struct SummaryRow<Trailing: View>: View {
    var icon: String
    var tint: Color
    var title: String
    var subtitle: String
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(tint.opacity(0.12))
                Image(systemName: icon).foregroundColor(tint)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(subtitle).font(.subheadline).foregroundColor(.secondary)
            }
            Spacer()
            trailing
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.systemGray5), lineWidth: 1))
    }
}

private struct MealRow: View {
    var title: String
    var subtitle: String
    var trailing: String

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(subtitle).font(.subheadline).foregroundColor(.secondary)
            }
            Spacer()
            Text(trailing).font(.subheadline).foregroundColor(.green)
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.systemGray5), lineWidth: 1))
    }
}

private struct SimpleLineChart: View {
    var data: [Double]
    var lineColor: Color = .blue

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let maxVal = max(data.max() ?? 1, 1)
            let minVal = min(data.min() ?? 0, 0)
            let range = max(maxVal - minVal, 1e-6)
            let stepX = width / CGFloat(max(data.count - 1, 1))
            let points: [CGPoint] = data.enumerated().map { idx, val in
                let x = CGFloat(idx) * stepX
                // Invert y so higher values are higher visually with a small top/bottom inset
                let normalized = (val - minVal) / range
                let y = height - CGFloat(normalized) * (height - 12) - 6
                return CGPoint(x: x, y: y)
            }

            ZStack {
                // Baseline grid (light)
                VStack {
                    Spacer()
                    Rectangle().fill(Color(.systemGray5)).frame(height: 1)
                    Spacer()
                    Rectangle().fill(Color(.systemGray5)).frame(height: 1)
                    Spacer()
                    Rectangle().fill(Color(.systemGray5)).frame(height: 1)
                }
                .opacity(0.6)

                // Line
                Path { path in
                    guard let first = points.first else { return }
                    path.move(to: first)
                    for p in points.dropFirst() { path.addLine(to: p) }
                }
                .stroke(lineColor, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                // Dots
                ForEach(0..<points.count, id: \.self) { i in
                    Circle().fill(lineColor)
                        .frame(width: 6, height: 6)
                        .position(points[i])
                }
            }
        }
    }
}

private struct TabBarItem: View {
    var icon: String
    var label: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .blue : .gray)
                Text(label)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
