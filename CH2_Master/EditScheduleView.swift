//
//  editscheduleview.swift
//  CH2_Master
//  created by vitha and runi
//


import SwiftUI
import SwiftData

struct EditScheduleView: View {
    
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    
    @Bindable var schedule: Schedule
    @Bindable var friend: Friend
    
    
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    
    @State private var showRepeatPicker = false
    @State private var showDeleteConfirm = false
    
    // MARK: - UI for editscheduleview
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                content
            }
            .onAppear {
                startDate = makeDate(schedule.startHour, schedule.startMinute)
                endDate = makeDate(schedule.endHour, schedule.endMinute)
            }
        }
    }
}

private extension EditScheduleView {
    
    // MARK: - existing content
    
    var content: some View {
        VStack(spacing: 20) {
            
            infoSection
            timeSection
            
            Spacer()
            
            deleteButton
        }
        .padding()
        .toolbar { toolbar }
        .navigationTitle("Edit Schedule")
        .toolbarTitleDisplayMode(.inline)
        .sheet(isPresented: $showRepeatPicker) {
            RepeatView(selectedDays: Binding(
                get: { schedule.repeatDays },
                set: { schedule.repeatDaysRaw = $0.map { $0.rawValue } }
            ))
        }
        .alert("Delete Schedule", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Yes, delete", role: .destructive) {
                if let index = friend.schedules.firstIndex(where: { $0.id == schedule.id }) {
                    let removed = friend.schedules.remove(at: index)
                    context.delete(removed)
                }
                dismiss()
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    // MARK: - form
    
    var infoSection: some View {
        VStack(spacing: 0) {
            
            TextField("Activity Name", text: $schedule.title)
                .padding()
            
            Divider()
            
            HStack {
                Text("Type")
                Spacer()
                
                Picker("", selection: Binding(
                    get: { schedule.type },
                    set: { schedule.typeRaw = $0.rawValue }
                )) {
                    ForEach(ScheduleType.allCases, id: \.self) {
                        Text($0.rawValue.capitalized)
                    }
                }
                .labelsHidden()
            }
            .padding()
            
            Divider()
            
            HStack {
                Text("Repeat")
                Spacer()
                Text(repeatText)
                    .foregroundColor(.secondary)
            }
            .padding()
            .onTapGesture {
                showRepeatPicker = true
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    var timeSection: some View {
        VStack(spacing: 0) {
            
            HStack {
                Text("Start Time")
                Spacer()
                
                DatePicker(
                    "",
                    selection: $startDate,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.compact)
                .labelsHidden()
            }
            .padding()
            
            Divider()
            
            HStack {
                Text("End Time")
                Spacer()
                
                DatePicker(
                    "",
                    selection: $endDate,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.compact)
                .labelsHidden()
            }
            .padding()
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    var deleteButton: some View {
        Button(role: .destructive) {
            showDeleteConfirm = true
        } label: {
            Text("Delete Schedule")
        }
    }
    
    var toolbar: some ToolbarContent {
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
            }
        }
    }
    
    // MARK: - time helpers aaaa
    
    func save() {
        schedule.startHour = Calendar.current.component(.hour, from: startDate)
        schedule.startMinute = Calendar.current.component(.minute, from: startDate)
        schedule.endHour = Calendar.current.component(.hour, from: endDate)
        schedule.endMinute = Calendar.current.component(.minute, from: endDate)
        
        dismiss()
    }
    
    func makeDate(_ h: Int, _ m: Int) -> Date {
        Calendar.current.date(bySettingHour: h, minute: m, second: 0, of: Date())!
    }
    
    var repeatText: String {
        if schedule.repeatDays.count == 7 { return "Every day" }
        if schedule.repeatDays.isEmpty { return "None" }
        return "Custom"
    }
}
