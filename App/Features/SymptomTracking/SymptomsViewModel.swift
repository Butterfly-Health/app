//
//  SymptomsViewModel.swift
//  App
//
//  Created by Saf on 11/18/25.
//

import Foundation
import SwiftUI
import GRDB

// MARK: - Symptoms ViewModel

class SymptomsViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var selectedDate = Date()
    @Published var additionalNotes = ""
    @Published var showingDatePicker = false
    @Published var showingSymptomSelector = false
    
    @Published var availableSymptoms: [String: [String]] = SymptomData.availableSymptoms
    @Published var chosenSymptoms: [String: Double] = SymptomData.defaultChosenSymptoms
    @Published var symptomEntries: [SymptomEntry] = []
    @Published var errorMessage: String?
    
    private let dbManager = DatabaseManager.shared
    private let currentUserId: Int64 = 1 // TODO: Replace with actual user ID from auth
    
    // MARK: - Computed Properties
    
    var sortedChosenSymptoms: [String] {
        Array(chosenSymptoms.keys).sorted()
    }
    
    // MARK: - Initialization
    
    init() {
        loadSymptomEntriesForDate(selectedDate)
    }
    
    // MARK: - Methods
    
    func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
    
    func loadSymptomEntriesForDate(_ date: Date) {
        do {
            let startOfDay = Calendar.current.startOfDay(for: date)
            let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
            
            symptomEntries = try dbManager.fetchSymptomEntries(
                userId: currentUserId,
                startDate: startOfDay,
                endDate: endOfDay
            )
            
            // Populate chosenSymptoms from entries
            var symptoms: [String: Double] = [:]
            for entry in symptomEntries {
                if let symptomName = entry.symptomName {
                    symptoms[symptomName] = Double(entry.value)
                }
            }
            
            // If no entries for this date, use defaults
            if symptoms.isEmpty {
                chosenSymptoms = SymptomData.defaultChosenSymptoms
            } else {
                chosenSymptoms = symptoms
            }
            
            // Load notes from the first entry (assuming one set of notes per day)
            additionalNotes = symptomEntries.first?.notes ?? ""
            
        } catch {
            errorMessage = "Failed to load symptoms: \(error.localizedDescription)"
            print("Error loading symptoms: \(error)")
        }
    }
    
    func saveSymptoms() {
        do {
            // Delete existing entries for this date
            try dbManager.deleteSymptomEntries(userId: currentUserId, date: selectedDate)
            
            // Create new entries for each symptom
            for (symptomName, severity) in chosenSymptoms {
                let entry = SymptomEntry(
                    userId: currentUserId,
                    symptomName: symptomName,
                    value: Int(severity),
                    notes: additionalNotes,
                    recordedAt: selectedDate
                )
                try dbManager.insertSymptomEntry(entry)
            }
            
            // Reload entries
            loadSymptomEntriesForDate(selectedDate)
            
            print("Successfully saved \(chosenSymptoms.count) symptoms")
            
        } catch {
            errorMessage = "Failed to save symptoms: \(error.localizedDescription)"
            print("Error saving symptoms: \(error)")
        }
    }
    
    func addSymptom(_ symptom: String, severity: Double = 5) {
        chosenSymptoms[symptom] = severity
    }
    
    func removeSymptom(_ symptom: String) {
        chosenSymptoms.removeValue(forKey: symptom)
    }
    
    func updateSymptomSeverity(_ symptom: String, severity: Double) {
        chosenSymptoms[symptom] = severity
    }
    
    func loadHistoricalSymptoms(days: Int = 30) -> [SymptomEntry] {
        do {
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .day, value: -days, to: endDate)!
            return try dbManager.fetchSymptomEntries(
                userId: currentUserId,
                startDate: startDate,
                endDate: endDate
            )
        } catch {
            errorMessage = "Failed to load historical symptoms: \(error.localizedDescription)"
            return []
        }
    }
    
    func createCustomSymptomDefinition(name: String, category: String = "Custom") {
        do {
            // Check if symptom definition already exists
            if let _ = try dbManager.fetchSymptomDefinitionByName(name) {
                print("Symptom definition '\(name)' already exists")
                return
            }
            
            // Get or create the custom condition
            let conditionId = try dbManager.getOrCreateCustomCondition()
            
            // Create slug from name (lowercase, replace spaces with hyphens)
            let slug = name.lowercased().replacingOccurrences(of: " ", with: "-")
            
            // Create and insert the symptom definition
            let definition = SymptomDefinition(
                name: name,
                slug: slug,
                description: "Custom symptom added by user",
                category: category,
                condition: "Custom",
                conditionId: conditionId
            )
            
            try dbManager.insertSymptomDefinition(definition)
            print("Successfully created symptom definition for '\(name)'")
            
        } catch {
            errorMessage = "Failed to create custom symptom: \(error.localizedDescription)"
            print("Error creating custom symptom: \(error)")
        }
    }
}
