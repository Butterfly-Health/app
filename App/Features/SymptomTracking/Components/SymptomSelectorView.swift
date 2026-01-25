//
//  SymptomSelectorView.swift
//  App
//
//  Created by Saf on 11/21/25.
//

import SwiftUI

struct SymptomSelectorView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var availableSymptoms: [String: [String]]
    @Binding var chosenSymptoms: [String: Double]
    @ObservedObject var viewModel: SymptomsViewModel
    
    @State private var searchText = ""
    @State private var expandedCategories: Set<String> = []
    
    var allSymptoms: [String] {
        availableSymptoms.values.flatMap { $0 }
    }
    
    var filteredCategories: [String: [String]] {
        if searchText.isEmpty {
            return availableSymptoms
        }
        
        var filtered: [String: [String]] = [:]
        for (category, symptoms) in availableSymptoms {
            let matchingSymptoms = symptoms.filter { $0.lowercased().contains(searchText.lowercased()) }
            if !matchingSymptoms.isEmpty {
                filtered[category] = matchingSymptoms.sorted()
            }
        }
        return filtered
    }
    
    var showCustomSymptom: Bool {
        !searchText.isEmpty && !allSymptoms.contains(where: { $0.lowercased() == searchText.lowercased() })
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search for symptoms or create a custom one", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()
                
                // Symptoms List
                List {
                    // Custom symptom row if search doesn't match
                    if showCustomSymptom {
                        Section {
                            HStack {
                                Text(searchText)
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                Toggle("", isOn: Binding(
                                    get: { chosenSymptoms.keys.contains(searchText) },
                                    set: { isOn in
                                        if isOn {
                                            // Add custom symptom to "Custom" category
                                            if availableSymptoms["Custom"] != nil {
                                                availableSymptoms["Custom"]?.append(searchText)
                                            } else {
                                                availableSymptoms["Custom"] = [searchText]
                                            }
                                            chosenSymptoms[searchText] = 5
                                            
                                            // Save to database
                                            viewModel.createCustomSymptomDefinition(name: searchText, category: "Custom")
                                        } else {
                                            chosenSymptoms.removeValue(forKey: searchText)
                                        }
                                    }
                                ))
                                .labelsHidden()
                            }
                        } header: {
                            Text("Custom Symptom")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .listRowBackground(Color(.systemGray6))
                    }
                    
                    // Categories with symptoms
                    ForEach(filteredCategories.keys.sorted(), id: \.self) { category in
                        Section {
                            ForEach(filteredCategories[category] ?? [], id: \.self) { symptom in
                                HStack {
                                    Text(symptom)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: Binding(
                                        get: { chosenSymptoms.keys.contains(symptom) },
                                        set: { isOn in
                                            if isOn {
                                                chosenSymptoms[symptom] = 5
                                            } else {
                                                chosenSymptoms.removeValue(forKey: symptom)
                                            }
                                        }
                                    ))
                                    .labelsHidden()
                                }
                            }
                        } header: {
                            Text(category)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Select Symptoms")
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
