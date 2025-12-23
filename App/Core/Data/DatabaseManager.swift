import GRDB
import Foundation
import UIKit

class DatabaseManager {
    static let shared = DatabaseManager()
    
    var dbQueue: DatabaseQueue!
    
    private init() {
        do {
            // Set up database connection
            try DatabaseManager.setup()
            
            // Setup schema
            try DatabaseManager.defineSchema()
            
        } catch {
            fatalError("Failed to initialize database: \(error)")
        }
    }
    
    static func setup() throws {
        let databaseURL = try FileManager.default
            .url(for: .applicationDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("db.sqlite")

        shared.dbQueue = try DatabaseQueue(path: databaseURL.path)
    }
    
    static func defineSchema() throws {
        try shared.dbQueue.write { db in
            // Conditions table
            try db.create(table: "conditions") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull().unique()
                t.column("slug", .text).notNull().unique()
            }
            
            // Symptom definitions table
            try db.create(table: "symptom_definitions") { t in
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
            try db.create(table: "lab_definitions") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull().unique()
                t.column("slug", .text).notNull().unique()
                t.column("description", .text)
                t.column("condition", .text).notNull()
                t.column("condition_id", .integer).notNull().references("conditions", onDelete: .cascade)
            }
            
            // Symptom entries table
            try db.create(table: "symptom_entries") { t in
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
            try db.create(table: "lab_entries") { t in
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
            try db.create(table: "photos") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("user_id", .integer).notNull()
                t.column("r2_path", .text).notNull()
                t.column("purpose", .text)
                t.column("recorded_at", .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")
                t.column("hash", .text)
            }
            
            // Create indexes
            try db.create(index: "idx_symptom_definitions_id", on: "symptom_definitions", columns: ["id"])
            try db.create(index: "idx_conditions_id", on: "conditions", columns: ["id"])
            try db.create(index: "idx_symptom_entries_id", on: "symptom_entries", columns: ["id"])
            try db.create(index: "idx_symptom_entries_user_id", on: "symptom_entries", columns: ["user_id"])
            try db.create(index: "idx_symptom_entries_symptom_id", on: "symptom_entries", columns: ["symptom_id"])
            try db.create(index: "idx_symptom_entries_symptom_name", on: "symptom_entries", columns: ["symptom_name"])
            try db.create(index: "idx_symptom_entries_recorded_at", on: "symptom_entries", columns: ["recorded_at"])
            try db.create(index: "idx_lab_entries_id", on: "lab_entries", columns: ["id"])
            try db.create(index: "idx_lab_entries_user_id", on: "lab_entries", columns: ["user_id"])
            try db.create(index: "idx_lab_entries_lab_name", on: "lab_entries", columns: ["lab_name"])
            try db.create(index: "idx_lab_entries_recorded_at", on: "lab_entries", columns: ["recorded_at"])
            try db.create(index: "idx_lab_definitions_id", on: "lab_definitions", columns: ["id"])
            try db.create(index: "idx_photos_recorded_at", on: "photos", columns: ["recorded_at"])
            try db.create(index: "idx_photos_user_id", on: "photos", columns: ["user_id"])
        }
    }
}

