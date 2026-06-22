//
//  contentview.swift
//  CH2_Master
//  created by vitha and runi
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    // loading from swiftdata
    
    @Query(sort: \Friend.name) var friends: [Friend]
    
    // states
    
    @State private var filter = FriendFilter()
    @State private var showAddFriend = false
    
    @State private var selectedFriend: Friend?
    @State private var editFriend: Friend?
    
    @StateObject private var timeManager = TimeManager()
    
    @State private var statusCache: [UUID: FriendStatus] = [:]
    
    // MARK: - main list of friends & pinning logic
    
    var sortedFriends: [Friend] {
        
        let filtered = filterFriends(
            friends: friends,
            filter: filter,
            now: timeManager.now
        )
        
        return filtered.sorted { a, b in
            
            let statusA = statusCache[a.id] ?? .available
            let statusB = statusCache[b.id] ?? .available
            
            if a.isPinned != b.isPinned {
                return a.isPinned && !b.isPinned
            }
            
            let aAvailable = statusA == .available
            let bAvailable = statusB == .available
            
            if aAvailable != bAvailable {
                return aAvailable && !bAvailable
            }
            
            return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
        }
    }
    
    // MARK: - UI for homepage
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                Group {
                    if sortedFriends.isEmpty {
                        emptyStateView
                    } else {
                        listView
                    }
                }
            }
            .navigationTitle("InSync")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar { toolbar }
            .searchable(text: $filter.searchText)
            
            // MARK: - update time cycle
            
            .onChange(of: timeManager.now) { _, newNow in
                updateCache(now: newNow)
            }
            
            .onAppear {
                updateCache(now: timeManager.now)
            }
            
            // MARK: - friend profile actions
            
            .fullScreenCover(isPresented: $showAddFriend) {
                AddFriendView()
                    .preferredColorScheme(.dark)
            }
            
            .sheet(item: $selectedFriend) { friend in
                FriendSchedulesSheet(friend: friend)
            }
            
            .fullScreenCover(item: $editFriend) { friend in
                EditFriendView(friend: friend)
                    .preferredColorScheme(.dark)
            }
        }
    }
    
    // MARK: - subviews
    
    private var listView: some View {
        List {
            ForEach(sortedFriends) { friend in
                
                FriendCardView(
                    friend: friend,
                    status: statusCache[friend.id] ?? .available,
                    now: timeManager.now
                )
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedFriend = friend
                }
                
                .contextMenu {
                    
                    Button {
                        editFriend = friend
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button {
                        friend.isPinned.toggle()
                    } label: {
                        Label(
                            friend.isPinned ? "Unpin" : "Pin",
                            systemImage: "pin"
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                showAddFriend = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            Text("No profiles to display yet.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
        }
    }
    
    // MARK: - cache helper
    
    private func updateCache(now: Date) {
        var newCache: [UUID: FriendStatus] = [:]
        for friend in friends {
            newCache[friend.id] = currentStatus(for: friend, now: now)
        }
        statusCache = newCache
    }
}

// MARK: - the only preview thats usable god bless

#Preview {
    ContentView()
        .modelContainer(for: [Friend.self, Schedule.self], inMemory: true)
        .preferredColorScheme(.dark)
}
