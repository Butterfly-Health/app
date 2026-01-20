//
//  PhotoModel.swift
//  App
//
//  Created by Saf on 1/19/26.
//

import Foundation
import GRDB
import UIKit

// MARK: - Photo Entry (GRDB Model)

struct PhotoEntry: Codable, Identifiable, FetchableRecord, PersistableRecord {
    var id: Int64?
    var userId: Int64
    var r2Path: String
    var purpose: String?
    var recordedAt: Date
    var hash: String?
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let userId = Column(CodingKeys.userId)
        static let r2Path = Column(CodingKeys.r2Path)
        static let purpose = Column(CodingKeys.purpose)
        static let recordedAt = Column(CodingKeys.recordedAt)
        static let hash = Column(CodingKeys.hash)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case r2Path = "r2_path"
        case purpose
        case recordedAt = "recorded_at"
        case hash
    }
    
    init(id: Int64? = nil, userId: Int64, r2Path: String, purpose: String? = nil, recordedAt: Date = Date(), hash: String? = nil) {
        self.id = id
        self.userId = userId
        self.r2Path = r2Path
        self.purpose = purpose
        self.recordedAt = recordedAt
        self.hash = hash
    }
}

// MARK: - Photo Type Enum

enum PhotoType: String, Codable {
    case eyeDisease = "eye_disease"
    case goiter = "goiter"
    
    var displayName: String {
        switch self {
        case .eyeDisease: return "Eye Disease"
        case .goiter: return "Goiter"
        }
    }
    
    var icon: String {
        switch self {
        case .eyeDisease: return "eye.fill"
        case .goiter: return "figure.walk"
        }
    }
}

// MARK: - Photo with Image (View Model)

struct PhotoWithImage: Identifiable {
    let id: Int64?
    let entry: PhotoEntry
    var image: UIImage?
    var isLoading: Bool = false
    
    init(entry: PhotoEntry, image: UIImage? = nil) {
        self.id = entry.id
        self.entry = entry
        self.image = image
    }
}

// MARK: - Photo Comparison Data

struct PhotoComparisonData {
    let todayPhoto: PhotoWithImage?
    let comparisonPhoto: PhotoWithImage?
    let overlayOpacity: Double
    
    init(todayPhoto: PhotoWithImage? = nil, comparisonPhoto: PhotoWithImage? = nil, overlayOpacity: Double = 0.5) {
        self.todayPhoto = todayPhoto
        self.comparisonPhoto = comparisonPhoto
        self.overlayOpacity = overlayOpacity
    }
}
