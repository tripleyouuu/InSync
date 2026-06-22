//
//  addfriendview.swift
//  CH2_Master
//  created by vitha and runi
//


import SwiftUI
import SwiftData
import PhotosUI

struct AddFriendView: View {
    
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    
    @State private var name: String = ""
    @State private var city: String = ""
    @State private var timezoneIdentifier: String = TimeZone.current.identifier
    
    @State private var schedules: [Schedule] = []
    @State private var showAddSchedule = false
    @State private var showTimezonePicker = false
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var photoData: Data?
    

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // MARK: - UI for addfriendview
    
    var body: some View {
        NavigationStack {
            
            ZStack(alignment: .bottom) {
                
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        photoSection
                        infoSection
                        schedulesSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding()
                }
                .scrollIndicators(.hidden)
                
                addScheduleButton
            }
            
            .toolbar { toolbar }
            
            .fullScreenCover(isPresented: $showAddSchedule) {
                AddScheduleView { schedules.append($0) }
                    .preferredColorScheme(.dark)
            }
            
            .sheet(isPresented: $showTimezonePicker) {
                TimezonePickerView(selected: $timezoneIdentifier)
            }
        }
    }
    
    // MARK: - da form
    
    private var photoSection: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(Color(UIColor.systemGray5))
                    .frame(width: 150, height: 150)
                
                if let data = photoData,
                   let img = UIImage(data: data) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
            }
            
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Text("Add Photo")
            }
            .onChange(of: selectedItem) { _, newItem in
                loadImage(newItem)
            }
        }
    }
    
    private var infoSection: some View {
        VStack(spacing: 0) {
            
            TextField("Name", text: $name)
                .padding()
            
            Divider()
            
            TextField("Location", text: $city)
                .padding()
            
            Divider()
            
            Button {
                showTimezonePicker = true
            } label: {
                HStack {
                    Text("Timezone")
                    Spacer()
                    Text(timezoneIdentifier)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .buttonStyle(.plain)
            
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    private var schedulesSection: some View {
        VStack(spacing: 10) {
            
            if !schedules.isEmpty {
                VStack(spacing: 8) {
                    ForEach(schedules) { schedule in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(schedule.title.isEmpty
                                     ? schedule.type.rawValue.capitalized
                                     : schedule.title)
                                
                                Text(timeString(schedule))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button {
                                delete(schedule)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
    }
    
    private var addScheduleButton: some View {
        Button {
            showAddSchedule = true
        } label: {
            Text("Add Schedule")
                .padding()
        }
        .glassEffect()
        .padding()
        .padding(.horizontal, 20)
        .clipShape(Capsule())
    }
    
    private var toolbar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { save() } label: {
                    Image(systemName: "checkmark")
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isValid)
            }
        }
    }
    
    // MARK: - cooking pfp logic (or is it cooking me?)
    
    private func loadImage(_ item: PhotosPickerItem?) {
        guard let item else { return }
        
        Task.detached {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                
                let normalized = normalize(uiImage)
                let cropped = cropToSquare(normalized)
                let resized = resize(cropped)
                let compressed = resized.jpegData(compressionQuality: 0.7)
                
                await MainActor.run {
                    photoData = compressed
                }
            }
        }
    }
    
    private func normalize(_ image: UIImage) -> UIImage {
        if image.imageOrientation == .up { return image }
        
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
    }
    
    private func cropToSquare(_ image: UIImage) -> UIImage {
        let size = image.size
        let length = min(size.width, size.height)
        
        let x = (size.width - length) / 2
        let y = (size.height - length) / 2
        
        let rect = CGRect(x: x, y: y, width: length, height: length)
        
        guard let cg = image.cgImage?.cropping(to: rect) else { return image }
        
        return UIImage(cgImage: cg)
    }
    
    private func resize(_ image: UIImage, target: CGFloat = 300) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: target, height: target))
        
        return renderer.image { _ in
            image.draw(in: CGRect(x: 0, y: 0, width: target, height: target))
        }
    }
    
    // MARK: - logique
    
    private func save() {
        let newFriend = Friend(
            name: name,
            photoData: photoData,
            timezoneIdentifier: timezoneIdentifier,
            city: city,
            schedules: schedules
        )
        context.insert(newFriend)
        dismiss()
    }
    
    private func delete(_ schedule: Schedule) {
        schedules.removeAll { $0.id == schedule.id }
    }
    
    private func timeString(_ s: Schedule) -> String {
        String(format: "%02d:%02d - %02d:%02d",
               s.startHour, s.startMinute,
               s.endHour, s.endMinute)
    }
}
