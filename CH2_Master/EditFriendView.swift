//
//  editfriendview.swift
//  CH2_Master
//  created by vitha and runi
//

import SwiftUI
import SwiftData
import PhotosUI

struct EditFriendView: View {
    
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    
    @Bindable var friend: Friend
    
    @State private var showTimezonePicker = false
    @State private var showAddSchedule = false
    @State private var selectedSchedule: Schedule?
    @State private var showDeleteConfirm = false
    
    @State private var selectedItem: PhotosPickerItem?
    
    // MARK: - UI for editfrindview
    
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
                        deleteSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding()
                }
                .scrollIndicators(.hidden)
                
                addScheduleButton
            }
            
            .toolbar { toolbar }
            
            .sheet(isPresented: $showTimezonePicker) {
                TimezonePickerView(selected: $friend.timezoneIdentifier)
            }
            
            .fullScreenCover(isPresented: $showAddSchedule) {
                AddScheduleView { friend.schedules.append($0) }
                    .preferredColorScheme(.dark)
            }
            
            .fullScreenCover(item: $selectedSchedule) { schedule in
                EditScheduleView(schedule: schedule, friend: friend)
                    .preferredColorScheme(.dark)
            }
            
            .alert("Delete Profile", isPresented: $showDeleteConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Yes, delete", role: .destructive) {
                    context.delete(friend)
                    dismiss()
                }
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }
    
    // MARK: - form again lalala
    
    private var photoSection: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(Color(UIColor.systemGray5))
                    .frame(width: 150, height: 150)
                
                if let data = friend.photoData,
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
                Text("Edit Photo")
            }
            .onChange(of: selectedItem) { _, newItem in
                loadImage(newItem)
            }
        }
    }
    
    private var infoSection: some View {
        VStack(spacing: 0) {
            
            TextField("Friend Name", text: $friend.name)
                .padding()
            
            Divider()
            
            TextField("Location", text: $friend.city)
                .padding()
            
            Divider()
            
            Button {
                showTimezonePicker = true
            } label: {
                HStack {
                    Text("Timezone")
                    Spacer()
                    Text(friend.timezoneIdentifier)
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
            ForEach(friend.schedules) { schedule in
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
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .onTapGesture {
                    selectedSchedule = schedule
                }
            }
        }
    }
    
    private var deleteSection: some View {
        Button(role: .destructive) {
            showDeleteConfirm = true
        } label: {
            Text("Delete Profile")
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
                Button { dismiss() } label: {
                    Image(systemName: "checkmark")
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    // MARK: - images again
    
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
                    friend.photoData = compressed
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
    
    // MARK: - helper for time
    
    private func timeString(_ s: Schedule) -> String {
        String(format: "%02d:%02d - %02d:%02d",
               s.startHour, s.startMinute,
               s.endHour, s.endMinute)
    }
}
