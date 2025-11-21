//
//  MetricInfoView.swift
//  App
//
//  Created by Saf on 11/19/25.
//

import SwiftUI

struct MetricInfoView: View {
    @Environment(\.dismiss) var dismiss
    let metricTitle: String
    let metricColor: Color
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("Information about \(metricTitle)")
                    .font(.title3)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .navigationTitle(metricTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
