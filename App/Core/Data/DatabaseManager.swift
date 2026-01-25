import GRDB
import Foundation
import UIKit

class DatabaseManager {
    // Singleton pattern to disallow multiple creations of DBManager
    static let shared = DatabaseManager()
    
    var dbQueue: DatabaseQueue!
    
    private init() {
        // Initialize database synchronously but safely
        setupDatabase()
    }
    
    private func setupDatabase() {
        do {
            let databaseURL = try FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("db.sqlite")

            dbQueue = try DatabaseQueue(path: databaseURL.path)
            
            // Setup schema
            try defineSchema()
            
        } catch {
            fatalError("Failed to initialize database: \(error)")
        }
    }
    
    private func defineSchema() throws {
        try dbQueue.write { db in
            // Conditions table
            try db.create(table: "conditions", ifNotExists: true) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull().unique()
                t.column("slug", .text).notNull().unique()
            }
            
            // Symptom definitions table
            try db.create(table: "symptom_definitions", ifNotExists: true) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull().unique()
                t.column("slug", .text).notNull().unique()
                t.column("description", .text)
                t.column("category", .text).notNull().defaults(to: "custom")
                t.column("condition", .text).notNull()
                t.column("condition_id", .integer).notNull().references("conditions", onDelete: .cascade)
                t.column("icon", .text)
            }
            
            // Lab definitions table
            try db.create(table: "lab_definitions", ifNotExists: true) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull().unique()
                t.column("slug", .text).notNull().unique()
                t.column("description", .text)
                t.column("condition", .text).notNull()
                t.column("condition_id", .integer).notNull().references("conditions", onDelete: .cascade)
            }
            
            // Symptom entries table
            try db.create(table: "symptom_entries", ifNotExists: true) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("user_id", .integer).notNull()
                t.column("symptom_id", .integer).references("symptom_definitions", onDelete: .setNull)
                t.column("symptom_name", .text)
                t.column("value", .integer).notNull()
                t.column("notes", .text)
                t.column("recorded_at", .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")
                t.column("created_at", .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")
            }
            
            // Lab entries table
            try db.create(table: "lab_entries", ifNotExists: true) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("user_id", .integer).notNull()
                t.column("lab_id", .integer).references("lab_definitions", onDelete: .setNull)
                t.column("lab_name", .text)
                t.column("user_defined_lab", .boolean).notNull()
                t.column("value", .integer).notNull()
                t.column("unit", .text)
                t.column("recorded_at", .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")
                t.column("created_at", .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")
            }
            
            // Photos table
            try db.create(table: "photos", ifNotExists: true) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("user_id", .integer).notNull()
                t.column("r2_path", .text).notNull()
                t.column("purpose", .text)
                t.column("recorded_at", .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")
                t.column("hash", .text)
            }
            
            // Create indexes
            try db.create(index: "idx_symptom_definitions_id", on: "symptom_definitions", columns: ["id"], ifNotExists: true)
            try db.create(index: "idx_conditions_id", on: "conditions", columns: ["id"], ifNotExists: true)
            try db.create(index: "idx_symptom_entries_id", on: "symptom_entries", columns: ["id"], ifNotExists: true)
            try db.create(index: "idx_symptom_entries_user_id", on: "symptom_entries", columns: ["user_id"], ifNotExists: true)
            try db.create(index: "idx_symptom_entries_symptom_id", on: "symptom_entries", columns: ["symptom_id"], ifNotExists: true)
            try db.create(index: "idx_symptom_entries_symptom_name", on: "symptom_entries", columns: ["symptom_name"], ifNotExists: true)
            try db.create(index: "idx_symptom_entries_recorded_at", on: "symptom_entries", columns: ["recorded_at"], ifNotExists: true)
            try db.create(index: "idx_lab_entries_id", on: "lab_entries", columns: ["id"], ifNotExists: true)
            try db.create(index: "idx_lab_entries_user_id", on: "lab_entries", columns: ["user_id"], ifNotExists: true)
            try db.create(index: "idx_lab_entries_lab_name", on: "lab_entries", columns: ["lab_name"], ifNotExists: true)
            try db.create(index: "idx_lab_entries_recorded_at", on: "lab_entries", columns: ["recorded_at"], ifNotExists: true)
            try db.create(index: "idx_lab_definitions_id", on: "lab_definitions", columns: ["id"], ifNotExists: true)
            try db.create(index: "idx_photos_recorded_at", on: "photos", columns: ["recorded_at"], ifNotExists: true)
            try db.create(index: "idx_photos_user_id", on: "photos", columns: ["user_id"], ifNotExists: true)
        }
    }
    
    // MARK: - Symptom Entry Methods
    
    func insertSymptomEntry(_ entry: SymptomEntry) throws {
        try dbQueue.write { db in
            var mutableEntry = entry
            try mutableEntry.insert(db)
        }
    }
    
    func fetchSymptomEntries(userId: Int64, startDate: Date, endDate: Date) throws -> [SymptomEntry] {
        try dbQueue.read { db in
            try SymptomEntry
                .filter(Column("user_id") == userId)
                .filter(Column("recorded_at") >= startDate)
                .filter(Column("recorded_at") < endDate)
                .order(Column("recorded_at").desc)
                .fetchAll(db)
        }
    }
    
    func deleteSymptomEntries(userId: Int64, date: Date) throws {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        try dbQueue.write { db in
            try SymptomEntry
                .filter(Column("user_id") == userId)
                .filter(Column("recorded_at") >= startOfDay)
                .filter(Column("recorded_at") < endOfDay)
                .deleteAll(db)
        }
    }
    
    func fetchSymptomEntry(id: Int64) throws -> SymptomEntry? {
        try dbQueue.read { db in
            try SymptomEntry.fetchOne(db, key: id)
        }
    }
    
    // MARK: - Photo Entry Methods
    
    func insertPhotoEntry(_ entry: PhotoEntry) throws {
        try dbQueue.write { db in
            var mutableEntry = entry
            try mutableEntry.insert(db)
        }
    }
    
    func fetchPhotoEntries(userId: Int64, purpose: String? = nil, startDate: Date, endDate: Date) throws -> [PhotoEntry] {
        try dbQueue.read { db in
            var request = PhotoEntry
                .filter(Column("user_id") == userId)
                .filter(Column("recorded_at") >= startDate)
                .filter(Column("recorded_at") < endDate)
            
            if let purpose = purpose {
                request = request.filter(Column("purpose") == purpose)
            }
            
            return try request
                .order(Column("recorded_at").desc)
                .fetchAll(db)
        }
    }
    
    func fetchPhotoEntry(id: Int64) throws -> PhotoEntry? {
        try dbQueue.read { db in
            try PhotoEntry.fetchOne(db, key: id)
        }
    }
    
    func deletePhotoEntry(id: Int64) throws {
        try dbQueue.write { db in
            try PhotoEntry.deleteOne(db, key: id)
        }
    }
    
    func fetchAllPhotosForUser(userId: Int64) throws -> [PhotoEntry] {
        try dbQueue.read { db in
            try PhotoEntry
                .filter(Column("user_id") == userId)
                .order(Column("recorded_at").desc)
                .fetchAll(db)
        }
    }
    
    // MARK: - Symptom Definition Methods
    
    func fetchSymptomDefinitions() throws -> [SymptomDefinition] {
        try dbQueue.read { db in
            try SymptomDefinition
                .order(Column("category"), Column("name"))
                .fetchAll(db)
        }
    }
    
    func fetchSymptomDefinition(id: Int64) throws -> SymptomDefinition? {
        try dbQueue.read { db in
            try SymptomDefinition.fetchOne(db, key: id)
        }
    }
    
    func fetchSymptomDefinitionByName(_ name: String) throws -> SymptomDefinition? {
        try dbQueue.read { db in
            try SymptomDefinition
                .filter(Column("name") == name)
                .fetchOne(db)
        }
    }
    
    func insertSymptomDefinition(_ definition: SymptomDefinition) throws {
        try dbQueue.write { db in
            var mutableDefinition = definition
            try mutableDefinition.insert(db)
        }
    }
    
    func getOrCreateCustomCondition() throws -> Int64 {
        try dbQueue.write { db in
            // Check if "Custom" condition exists
            if let existingCondition = try Row.fetchOne(db, sql: "SELECT id FROM conditions WHERE slug = ?", arguments: ["custom"]) {
                return existingCondition["id"]
            }
            
            // Create it if it doesn't exist
            try db.execute(sql: "INSERT INTO conditions (name, slug) VALUES (?, ?)", arguments: ["Custom", "custom"])
            return db.lastInsertedRowID
        }
    }
}

