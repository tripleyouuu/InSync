//
//  timezonepickerview.swift
//  CH2_Master
//  created by vitha and runi
//

import SwiftUI

struct TimezonePickerView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Binding var selected: String
    
    @State private var searchText: String = ""
    
    private let timezones = TimeZone.knownTimeZoneIdentifiers
    
    struct TZItem: Identifiable {
        let id: String
        let city: String
        let region: String
    }
    
    private var items: [TZItem] {
        timezones.map { id in
            let parts = id.split(separator: "/")
            let region = parts.first.map(String.init) ?? ""
            let city = (parts.last.map(String.init) ?? id)
                .replacingOccurrences(of: "_", with: " ")
            
            return TZItem(id: id, city: city, region: region)
        }
    }
    
    private var filtered: [TZItem] {
        searchText.isEmpty
        ? items
        : items.filter { $0.city.localizedCaseInsensitiveContains(searchText) }
    }
    
    private var grouped: [String: [TZItem]] {
        Dictionary(grouping: filtered) {
            String($0.city.prefix(1)).uppercased()
        }
    }
    
    private var keys: [String] {
        grouped.keys.sorted()
    }
    
    var body: some View {
        NavigationStack {
            
            ScrollViewReader { proxy in
                
                ZStack(alignment: .trailing) {
                    
                    Color(UIColor.systemGroupedBackground)
                        .ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            
                            ForEach(keys, id: \.self) { key in
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    
                                    Text(key)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .id(key)
                                    
                                    VStack(spacing: 0) {
                                        ForEach(grouped[key] ?? []) { item in
                                            
                                            HStack {
                                                VStack(alignment: .leading, spacing: 2) {
                                                    
                                                    HStack {
                                                        Text(item.city)
                                                        
                                                        if item.id == selected {
                                                            Image(systemName: "checkmark")
                                                        }
                                                        
                                                        Spacer()
                                                    }
                                                    
                                                    Text(item.region)
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                            .padding()
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                selected = item.id
                                                dismiss()
                                            }
                                            
                                            if item.id != grouped[key]?.last?.id {
                                                Divider()
                                            }
                                        }
                                    }
                                }
                            }
                            
                            Spacer(minLength: 60)
                        }
                        .padding()
                    }
                    .scrollIndicators(.hidden)
                    
                    // MARK: - A-Z index
                    
                    VStack(spacing: 2) {
                        ForEach(keys, id: \.self) { key in
                            Text(key)
                                .font(.caption2)
                                .foregroundColor(.orange)
                                .frame(width: 24, height: 18)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation {
                                        proxy.scrollTo(key, anchor: .top)
                                    }
                                }
                        }
                    }
                    .padding(.trailing, 20)
                }
            }
            .navigationTitle("Choose a City")
            .toolbarTitleDisplayMode(.inline)
            .searchable(text: $searchText)
        }
    }
}
