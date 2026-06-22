//
//  friendschedulessheet.swift
//  CH2_Master
//  created by vitha and runi
//


import SwiftUI
import SwiftData

struct FriendSchedulesSheet: View {
    
    
    @Bindable var friend: Friend
    
    
    @Environment(\.dismiss) private var dismiss
    
    
    @State private var selectedSchedule: Schedule?
    
    // MARK: - UI for the lil sheet
    
    var body: some View {
        NavigationStack {
            
            ScrollView {
                VStack(spacing: 16) {
                    
                    header
                    
                    if friend.schedules.isEmpty {
                        emptyState
                    } else {
                        schedulesList
                    }
                    
                    Spacer(minLength: 60)
                }
                .padding()
            }
            .scrollIndicators(.hidden)
            
            .fullScreenCover(item: $selectedSchedule) { schedule in
                EditScheduleView(schedule: schedule, friend: friend)
                    .preferredColorScheme(.dark)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - sections
    
    private var header: some View {
        Text("\(friend.name)'s Schedules")
            .font(.headline)
            .padding(.top)
    }
    
    private var emptyState: some View {
        VStack {
            Spacer()
            Text("No schedules")
                .foregroundColor(.secondary)
        }
    }
    
    private var schedulesList: some View {
        VStack(spacing: 0) {
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
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedSchedule = schedule
                }
                
                if schedule.id != friend.schedules.last?.id {
                    Divider()
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - time helper for the nth time
    
    private func timeString(_ s: Schedule) -> String {
        String(format: "%02d:%02d - %02d:%02d",
               s.startHour, s.startMinute,
               s.endHour, s.endMinute)
    }
}
