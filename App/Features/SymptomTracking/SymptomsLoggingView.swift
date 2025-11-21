//
//  SymptomsLoggingView.swift
//  App
//
//  Created by Saf on 11/12/25.
//

import SwiftUI

struct SymptomsLoggingView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = SymptomsViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Date Section
                    HStack {
                        Text(viewModel.isToday(viewModel.selectedDate) ? "Today" : "Selected Date")
                            .font(.headline)
                            .foregroundColor(.primary)

                        Spacer()

                        Button(action: {
                            viewModel.showingDatePicker = true
                        }) {
                            HStack(spacing: 6) {
                                Text(viewModel.selectedDate, style: .date)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Image(systemName: "calendar")
                                    .font(.system(size: 16))
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .sheet(isPresented: $viewModel.showingDatePicker) {
                        DatePickerSheet(selectedDate: $viewModel.selectedDate)
                    }

                    // Symptoms Section
                    VStack(spacing: 28) {
                        ForEach(viewModel.sortedChosenSymptoms, id: \.self) { symptom in
                            SymptomSlider(
                                title: symptom,
                                value: Binding(
                                    get: { viewModel.chosenSymptoms[symptom] ?? 5 },
                                    set: { viewModel.updateSymptomSeverity(symptom, severity: $0) }
                                ),
                                color: .blue
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Add More Symptoms Button
                    Button(action: {
                        viewModel.showingSymptomSelector = true
                    }) {
                        Text("Add More Symptoms")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue, lineWidth: 1.5)
                            )
                    }
                    .padding(.horizontal)
                    .sheet(isPresented: $viewModel.showingSymptomSelector) {
                        SymptomSelectorView(
                            availableSymptoms: $viewModel.availableSymptoms,
                            chosenSymptoms: $viewModel.chosenSymptoms
                        )
                    }

                    // Additional Notes Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Additional Notes")
                            .font(.headline)
                            .foregroundColor(.primary)

                        TextEditor(text: $viewModel.additionalNotes)
                            .frame(height: 120)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(
                                Group {
                                    if viewModel.additionalNotes.isEmpty {
                                        Text("Add any additional details about your symptoms today...")
                                            .foregroundColor(.gray)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 20)
                                            .allowsHitTesting(false)
                                    }
                                },
                                alignment: .topLeading
                            )
                    }
                    .padding(.horizontal)

                    // Save Button
                    Button(action: {
                        viewModel.saveSymptoms()
                        dismiss()
                    }) {
                        Text("Save Symptoms")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            .scrollDismissesKeyboard(.interactively)
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
                    Text("Log Symptoms")
                        .font(.headline)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Help action
                    }) {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }

}

// MARK: - Date Picker Sheet

struct DatePickerSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedDate: Date
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    in: ...Date(),
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Today") {
                        selectedDate = Date()
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Symptom Slider Component

struct SymptomSlider: View {
    let title: String
    @Binding var value: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Spacer()

                Text("\(Int(value))")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }

            // Custom Slider
            VStack(spacing: 8) {
                Slider(value: $value, in: 1...10, step: 1)
                    .tint(color)

                HStack {
                    Text("1 - Mild")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Spacer()

                    Text("10 - Severe")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    SymptomsLoggingView()
}
