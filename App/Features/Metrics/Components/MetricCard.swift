//
//  MetricCard.swift
//  App
//
//  Created by Saf on 11/19/25.
//

import SwiftUI

struct MetricCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let isSelected: Bool
    let onToggle: () -> Void
    
    @State private var showingInfo = false

    var body: some View {
        Button(action: onToggle) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 32))
                        .foregroundColor(iconColor)

                    VStack(spacing: 4) {
                        Text(title)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(isSelected ? iconColor.opacity(0.1) : Color.gray.opacity(0.05))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? iconColor : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                )
                
                // Info button in top-left corner
                Button(action: {
                    showingInfo = true
                }) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 16))
                        .foregroundColor(.gray.opacity(0.6))
                        .padding(8)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                
                // Select button in top-right corner
                Image(systemName: isSelected ? "checkmark.circle.fill" : "plus.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? iconColor : .gray.opacity(0.6))
                    .padding(8)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingInfo) {
            MetricInfoView(metricTitle: title, metricColor: iconColor)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}
