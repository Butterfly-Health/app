//
//  PhotoViewModel.swift
//  App
//
//  Created by Saf on 1/19/26.
//

import Foundation
import SwiftUI
import PhotosUI
import GRDB

class PhotoViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var selectedPhotoType: PhotoType = .eyeDisease
    @Published var todaysPhoto: UIImage?
    @Published var todaysPhotoEntry: PhotoEntry?
    @Published var comparisonPhotos: [PhotoWithImage] = []
    @Published var selectedComparisonPhoto: PhotoWithImage?
    
    @Published var showingImagePicker = false
    @Published var showingCamera = false
    @Published var selectedDate: String = "Dec 14"
    @Published var overlayOpacity: Double = 0.5
    @Published var notes: String = ""
    @Published var errorMessage: String?
    
    @Published var availableDates: [String] = []
    
    private let dbManager = DatabaseManager.shared
    private let currentUserId: Int64 = 1 // TODO: Replace with actual user ID from auth
    
    // MARK: - Initialization
    
    init() {
        // Defer database operations to avoid dispatch_once deadlock during view initialization
        // Load data after the view has been initialized
        Task { @MainActor in
            loadTodaysPhoto()
            loadAvailableDates()
        }
    }
    
    // MARK: - Photo Loading Methods
    
    func loadTodaysPhoto() {
        do {
            let startOfDay = Calendar.current.startOfDay(for: Date())
            let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
            
            let entries = try dbManager.fetchPhotoEntries(
                userId: currentUserId,
                purpose: selectedPhotoType.rawValue,
                startDate: startOfDay,
                endDate: endOfDay
            )
            
            if let entry = entries.first {
                todaysPhotoEntry = entry
                // TODO: Load actual image from R2 path
                // For now, we'll rely on the user capturing a new photo
            }
        } catch {
            errorMessage = "Failed to load today's photo: \(error.localizedDescription)"
            print("Error loading today's photo: \(error)")
        }
    }
    
    func loadAvailableDates() {
        do {
            // Load photos from the last 30 days
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .day, value: -30, to: endDate)!
            
            let entries = try dbManager.fetchPhotoEntries(
                userId: currentUserId,
                purpose: selectedPhotoType.rawValue,
                startDate: startDate,
                endDate: endDate
            )
            
            // Group by date and create available dates
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d"
            
            let uniqueDates = Set(entries.map { Calendar.current.startOfDay(for: $0.recordedAt) })
            availableDates = uniqueDates
                .sorted(by: >)
                .prefix(10)
                .map { dateFormatter.string(from: $0) }
            
            // Create PhotoWithImage objects for comparison
            comparisonPhotos = entries.map { PhotoWithImage(entry: $0) }
            
            if !availableDates.isEmpty {
                selectedDate = availableDates[0]
                loadComparisonPhoto(for: selectedDate)
            }
            
        } catch {
            errorMessage = "Failed to load available dates: \(error.localizedDescription)"
            print("Error loading available dates: \(error)")
        }
    }
    
    func loadComparisonPhoto(for dateString: String) {
        // Find the photo matching the selected date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        
        if let matchingPhoto = comparisonPhotos.first(where: {
            dateFormatter.string(from: $0.entry.recordedAt) == dateString
        }) {
            selectedComparisonPhoto = matchingPhoto
            // TODO: Load actual image from R2 path
        }
    }
    
    // MARK: - Photo Capture Methods
    
    func saveCapturedPhoto(_ image: UIImage) {
        do {
            // TODO: Upload image to R2 storage and get path
            let r2Path = "temp/\(UUID().uuidString).jpg" // Placeholder
            
            let photoEntry = PhotoEntry(
                userId: currentUserId,
                r2Path: r2Path,
                purpose: selectedPhotoType.rawValue,
                recordedAt: Date()
            )
            
            try dbManager.insertPhotoEntry(photoEntry)
            
            todaysPhoto = image
            todaysPhotoEntry = photoEntry
            
            // Reload available dates
            loadAvailableDates()
            
            print("Successfully saved photo")
            
        } catch {
            errorMessage = "Failed to save photo: \(error.localizedDescription)"
            print("Error saving photo: \(error)")
        }
    }
    
    func deletePhoto(_ photoEntry: PhotoEntry) {
        do {
            guard let photoId = photoEntry.id else { return }
            try dbManager.deletePhotoEntry(id: photoId)
            
            // Reload photos
            if photoEntry.id == todaysPhotoEntry?.id {
                todaysPhoto = nil
                todaysPhotoEntry = nil
            }
            loadAvailableDates()
            
            print("Successfully deleted photo")
            
        } catch {
            errorMessage = "Failed to delete photo: \(error.localizedDescription)"
            print("Error deleting photo: \(error)")
        }
    }
    
    // MARK: - Photo Type Change
    
    func changePhotoType(to type: PhotoType) {
        selectedPhotoType = type
        todaysPhoto = nil
        todaysPhotoEntry = nil
        comparisonPhotos = []
        selectedComparisonPhoto = nil
        
        loadTodaysPhoto()
        loadAvailableDates()
    }
    
    // MARK: - Comparison Methods
    
    func updateOverlay(opacity: Double) {
        overlayOpacity = opacity
    }
    
    func selectComparisonDate(_ dateString: String) {
        selectedDate = dateString
        loadComparisonPhoto(for: dateString)
    }
}
