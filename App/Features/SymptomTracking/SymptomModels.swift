//
//  SymptomModels.swift
//  App
//
//  Created by Saf on 11/18/25.
//

import Foundation

// MARK: - Symptom Model

struct Symptom: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: String
    
    static func == (lhs: Symptom, rhs: Symptom) -> Bool {
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

// MARK: - Symptom Category

enum SymptomCategory: String, CaseIterable {
    case physical = "Physical"
    case sleepEnergy = "Sleep & Energy"
    case mentalEmotional = "Mental & Emotional"
    case cardiovascular = "Cardiovascular"
    case digestive = "Digestive"
    case custom = "Custom"
}

// MARK: - Symptom Log Entry

struct SymptomLogEntry {
    let date: Date
    let symptoms: [String: Double] // symptom name: severity (1-10)
    let notes: String
}

// MARK: - Available Symptoms Data

struct SymptomData {
    static let availableSymptoms: [String: [String]] = [
        "Physical": [
            "Fatigue",
            "Weight Changes",
            "Hair Loss",
            "Dry Skin",
            "Joint Pain",
            "Muscle Weakness",
            "Tremors"
        ],
        "Sleep & Energy": [
            "Sleep Issues",
            "Cold Intolerance",
            "Heat Intolerance",
            "Sweating"
        ],
        "Mental & Emotional": [
            "Mood Changes",
            "Brain Fog",
            "Depression",
            "Anxiety",
            "Memory Problems"
        ],
        "Cardiovascular": [
            "Heart Palpitations"
        ],
        "Digestive": [
            "Constipation"
        ]
    ]
    
    static let defaultChosenSymptoms: [String: Double] = [
        "Fatigue": 5,
        "Weight Changes": 3,
        "Mood Changes": 7,
        "Sleep Issues": 4,
        "Hair Loss": 6,
        "Cold Intolerance": 2
    ]
}
