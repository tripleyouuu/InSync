//
//  filters.swift
//  CH2_Master
//  created by vitha and runi
//

import Foundation

// MARK: - f i l t e r

struct FriendFilter {
    var searchText: String = ""
    var showOnlyAvailable: Bool = false
}

// MARK: - filter base logic

func filterFriends(
    friends: [Friend],
    filter: FriendFilter,
    now: Date = Date()
) -> [Friend] {
    
    friends.filter { friend in
        matchesSearch(friend: friend, searchText: filter.searchText)
        &&
        matchesAvailability(friend: friend, showOnlyAvailable: filter.showOnlyAvailable, now: now)
    }
}

// MARK: - actual filters

private func matchesSearch(friend: Friend, searchText: String) -> Bool {
    let query = searchText
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .lowercased()
    
    guard !query.isEmpty else { return true }
    
    return friend.name
        .lowercased()
        .hasPrefix(query)
}

private func matchesAvailability(friend: Friend, showOnlyAvailable: Bool, now: Date) -> Bool {
    guard showOnlyAvailable else { return true }
    
    return currentStatus(for: friend, now: now) == .available
}
