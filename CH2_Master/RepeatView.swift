//
//  repeatview.swift
//  CH2_Master
//  created by vitha and runi
//

import SwiftUI
import SwiftData

struct RepeatView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDays: Set<Weekday>
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        
                        VStack(spacing: 0) {
                            ForEach(Weekday.allCases, id: \.self) { day in
                                
                                HStack {
                                    Text(label(for: day))
                                    
                                    Spacer()
                                    
                                    if selectedDays.contains(day) {
                                        Image(systemName: "checkmark")
                                    }
                                }
                                .padding()
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    toggle(day)
                                }
                                
                                if day != Weekday.allCases.last {
                                    Divider()
                                }
                            }
                        }
                        
                        Spacer(minLength: 60)
                    }
                    .padding()
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Repeat")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
    
    private func toggle(_ day: Weekday) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }
    
    private func label(for day: Weekday) -> String {
        DateFormatter().weekdaySymbols[day.rawValue - 1]
    }
}
