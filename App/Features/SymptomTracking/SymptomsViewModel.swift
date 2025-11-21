//
//  SymptomsViewModel.swift
//  App
//
//  Created by Saf on 11/18/25.
//

import Foundation
import SwiftUI

// MARK: - Symptoms ViewModel

class SymptomsViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var selectedDate = Date()
    @Published var additionalNotes = ""
    @Published var showingDatePicker = false
    @Published var showingSymptomSelector = false
    
    @Published var availableSymptoms: [String: [String]] = SymptomData.availableSymptoms
    @Published var chosenSymptoms: [String: Double] = SymptomData.defaultChosenSymptoms
    
    // MARK: - Computed Properties
    
    var sortedChosenSymptoms: [String] {
        Array(chosenSymptoms.keys).sorted()
    }
    
    // MARK: - Methods
    
    func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
    
    func saveSymptoms() {
        // Save symptoms logic here
        let entry = SymptomLogEntry(
            date: selectedDate,
            symptoms: chosenSymptoms,
            notes: additionalNotes
        )
        // TODO: Persist to storage
        print("Saving symptoms: \(entry)")
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
}
