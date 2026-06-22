//
//  addscheduleview.swift
//  CH2_Master
//  created by vitha and runi
//

import SwiftUI
import SwiftData

struct AddScheduleView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var onSave: (Schedule) -> Void
    
    @State private var title: String = ""
    @State private var type: ScheduleType = .custom
    
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addingTimeInterval(3600)
    
    @State private var showRepeatPicker = false
    @State private var repeatDays: Set<Weekday> = Set(Weekday.allCases)
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                content
            }
        }
    }
}

// MARK: - Main Content

private extension AddScheduleView {
    
    var content: some View {
        VStack(spacing: 20) {
            
            // MARK: - Top Block
            
            VStack(spacing: 0) {
                
                TextField("Activity Name", text: $title)
                    .padding()
                
                Divider()
                
                HStack {
                    Text("Type")
                    Spacer()
                    
                    Picker("", selection: $type) {
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
                .contentShape(Rectangle())
                .onTapGesture {
                    showRepeatPicker = true
                }
            }
//            .background(Color.white)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            
            // MARK: - Time Block
            
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
//            .background(Color.white)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            
            Spacer()
        }
        .padding()
        
        // MARK: - Toolbar
        
        .toolbar {
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
        .navigationTitle("Add Schedule")
        .toolbarTitleDisplayMode(.inline)
        
        // MARK: - Repeat Sheet
        
        .sheet(isPresented: $showRepeatPicker) {
            RepeatView(selectedDays: $repeatDays)
        }
    }
}

// MARK: - Helpers

private extension AddScheduleView {
    
    func save() {
        let schedule = Schedule(
            type: type,
            title: title,
            startHour: Calendar.current.component(.hour, from: startDate),
            startMinute: Calendar.current.component(.minute, from: startDate),
            endHour: Calendar.current.component(.hour, from: endDate),
            endMinute: Calendar.current.component(.minute, from: endDate),
            repeatDays: repeatDays
        )
        
        onSave(schedule)
        dismiss()
    }
    
    var repeatText: String {
        if repeatDays.count == 7 { return "Every day" }
        if repeatDays.isEmpty { return "None" }
        
        let formatter = DateFormatter()
        let symbols = formatter.shortWeekdaySymbols ?? []
        
        return repeatDays
            .sorted { $0.rawValue < $1.rawValue }
            .map { symbols[$0.rawValue - 1] }
            .joined(separator: ", ")
    }
}
