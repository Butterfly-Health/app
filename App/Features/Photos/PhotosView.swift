//
//  PhotosView.swift
//  App
//
//  Created by Saf on 11/12/25.
//

import SwiftUI
import PhotosUI

struct PhotosView: View {
    @StateObject private var viewModel = PhotoViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Photo Type Selection
                    photoTypeSection

                    // Today's Photo
                    todaysPhotoSection

                    // Compare with Previous
                    compareSection

                    // Add Notes
                    notesSection

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .navigationTitle("Photo Comparison")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {}) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.primary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.primary)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingImagePicker) {
                ImagePicker(image: $viewModel.todaysPhoto, sourceType: .photoLibrary, onImagePicked: { image in
                    viewModel.saveCapturedPhoto(image)
                })
            }
            .sheet(isPresented: $viewModel.showingCamera) {
                ImagePicker(image: $viewModel.todaysPhoto, sourceType: .camera, onImagePicked: { image in
                    viewModel.saveCapturedPhoto(image)
                })
            }
        }
    }

    // MARK: - Photo Type Section
    private var photoTypeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Photo Type")
                .font(.title3)
                .fontWeight(.semibold)

            HStack(spacing: 16) {
                PhotoTypeButton(
                    icon: "eye.fill",
                    title: "Eye Disease",
                    isSelected: viewModel.selectedPhotoType == .eyeDisease
                ) {
                    viewModel.changePhotoType(to: .eyeDisease)
                }

                PhotoTypeButton(
                    icon: "figure.walk",
                    title: "Goiter",
                    isSelected: viewModel.selectedPhotoType == .goiter
                ) {
                    viewModel.changePhotoType(to: .goiter)
                }

                Spacer()
            }
        }
    }

    // MARK: - Today's Photo Section
    private var todaysPhotoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Photo")
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
                Text(Date().formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .frame(height: 280)

                if let photo = viewModel.todaysPhoto {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 280)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("Tap to capture photo")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .onTapGesture {
                viewModel.showingCamera = true
            }

            // Action Buttons
            HStack(spacing: 24) {
                Button(action: { viewModel.showingImagePicker = true }) {
                    Image(systemName: "photo")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                        .frame(width: 56, height: 56)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }

                Button(action: { viewModel.showingCamera = true }) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                        .frame(width: 72, height: 72)
                        .background(Color.blue)
                        .clipShape(Circle())
                }

                Button(action: {}) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                        .frame(width: 56, height: 56)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Compare Section
    private var compareSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Compare with Previous")
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
                Button("View All") {
                    // Action
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }

            // Date Selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.availableDates, id: \.self) { date in
                        Button(action: { 
                            viewModel.selectComparisonDate(date)
                        }) {
                            Text(date)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(viewModel.selectedDate == date ? .white : .primary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(viewModel.selectedDate == date ? Color.blue : Color(.systemGray6))
                                .cornerRadius(20)
                        }
                    }
                }
            }

            // Comparison Images - Overlayed
            ZStack {
                // Bottom layer - Today's photo
                ComparisonImageCard(
                    icon: "camera.fill",
                    label: "Today",
                    backgroundColor: Color.green.opacity(0.1)
                )
                .opacity(1.0 - viewModel.overlayOpacity)
                
                // Top layer - Selected date photo
                ComparisonImageCard(
                    icon: "eye.fill",
                    label: viewModel.selectedDate,
                    backgroundColor: Color.blue.opacity(0.1)
                )
                .opacity(viewModel.overlayOpacity)
            }
            .frame(height: 180)

            // Overlay Slider
            VStack(spacing: 8) {
                HStack {
                    Text("Overlay")
                        .font(.subheadline)
                    Spacer()
                    Text("\(Int(viewModel.overlayOpacity * 100))%")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("Today")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    Slider(value: $viewModel.overlayOpacity, in: 0...1)
                    
                    Text(viewModel.selectedDate)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }

            // Tools Row
            HStack(spacing: 20) {
                Button(action: {}) {
                    HStack {
                        Image(systemName: "pencil.line")
                        Text("Measure")
                            .font(.subheadline)
                    }
                    .foregroundColor(.primary)
                }

                Button(action: {}) {
                    HStack{
                        Image(systemName: "eye")
                            .foregroundColor(.primary)
                        Text("Side by\nSide")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                    }
                }

                Spacer()
            }
        }
    }

    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add Notes")
                .font(.title3)
                .fontWeight(.semibold)

            TextEditor(text: $viewModel.notes)
                .frame(height: 100)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    Group {
                        if viewModel.notes.isEmpty {
                            Text("How are you feeling today? Any changes\nyou've noticed?")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                                .padding(.leading, 12)
                                .padding(.top, 16)
                                .allowsHitTesting(false)
                        }
                    },
                    alignment: .topLeading
                )

            // Quick Selection Tags
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    TagButton(title: "Better", isSelected: false)
                    TagButton(title: "Same", isSelected: false)
                    TagButton(title: "Worse", isSelected: false)
                    TagButton(title: "Swollen", isSelected: false)
                }
            }
        }
    }
}

// MARK: - Photo Type Enum (Moved to PhotoModel.swift)

// MARK: - Photo Type Button
struct PhotoTypeButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(isSelected ? .white : .gray)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(width: 160, height: 100)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

// MARK: - Comparison Image Card
struct ComparisonImageCard: View {
    let icon: String
    let label: String
    let backgroundColor: Color

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .frame(height: 120)

                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(icon == "camera.fill" ? .green : .blue)
            }

            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(icon == "camera.fill" ? .green : .blue)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Tag Button
struct TagButton: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        Text(title)
            .font(.subheadline)
            .foregroundColor(isSelected ? .blue : .gray)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    var onImagePicked: ((UIImage) -> Void)?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
                parent.onImagePicked?(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    PhotosView()
}
