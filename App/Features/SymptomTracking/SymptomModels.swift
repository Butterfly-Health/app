//
//  SymptomModels.swift
//  App
//
//  Created by Saf on 11/18/25.
//

import Foundation
import GRDB

// MARK: - Symptom Definition (GRDB Model)

struct SymptomDefinition: Codable, Identifiable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "symptom_definitions"
    
    var id: Int64?
    var name: String
    var slug: String
    var description: String?
    var category: String
    var condition: String
    var conditionId: Int64
    var icon: String?
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
        static let slug = Column(CodingKeys.slug)
        static let description = Column(CodingKeys.description)
        static let category = Column(CodingKeys.category)
        static let condition = Column(CodingKeys.condition)
        static let conditionId = Column(CodingKeys.conditionId)
        static let icon = Column(CodingKeys.icon)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case slug
        case description
        case category
        case condition
        case conditionId = "condition_id"
        case icon
    }
}

// MARK: - Symptom Entry (GRDB Model)

struct SymptomEntry: Codable, Identifiable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "symptom_entries"
    
    var id: Int64?
    var userId: Int64
    var symptomId: Int64?
    var symptomName: String?
    var value: Int
    var notes: String?
    var recordedAt: Date
    var createdAt: Date
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let userId = Column(CodingKeys.userId)
        static let symptomId = Column(CodingKeys.symptomId)
        static let symptomName = Column(CodingKeys.symptomName)
        static let value = Column(CodingKeys.value)
        static let notes = Column(CodingKeys.notes)
        static let recordedAt = Column(CodingKeys.recordedAt)
        static let createdAt = Column(CodingKeys.createdAt)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case symptomId = "symptom_id"
        case symptomName = "symptom_name"
        case value
        case notes
        case recordedAt = "recorded_at"
        case createdAt = "created_at"
    }
    
    init(id: Int64? = nil, userId: Int64, symptomId: Int64? = nil, symptomName: String?, value: Int, notes: String? = nil, recordedAt: Date, createdAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.symptomId = symptomId
        self.symptomName = symptomName
        self.value = value
        self.notes = notes
        self.recordedAt = recordedAt
        self.createdAt = createdAt
    }
}

// MARK: - Symptom Model (View Model)

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
