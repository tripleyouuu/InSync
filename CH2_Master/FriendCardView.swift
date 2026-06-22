//
//  friendcardview.swift
//  CH2_Master
//  created by vitha and runi
//


import SwiftUI

struct FriendCardView: View {
    
    
    let friend: Friend
    let status: FriendStatus
    let now: Date
    
    
    var body: some View {
        HStack {
            
            profileImage
            
            VStack(alignment: .leading, spacing: 4) {
                
                HStack(spacing: 6) {
                    Text(friend.name)
                        .font(.headline)
                    
                    if friend.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption)
                    }
                }
                
                Text(timeLocationString)
                    .font(.subheadline)
            }
            
            Spacer()
            
            VStack(spacing: 6) {
                Image(systemName: status.style.iconName)
                Text(status.style.label)
                    .font(.caption)
            }
        }
        .foregroundStyle(.white)
        .padding()
        .background(
            status.style.background
                .overlay(Color.black.opacity(0.2))
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8)
    }
}

// MARK: - subviews

private extension FriendCardView {
    
    var profileImage: some View {
        let size: CGFloat = 40
        
        return ZStack {
            Circle()
                .fill(Color.white.opacity(0.1))
            
            if let data = friend.photoData,
               let uiImage = UIImage(data: data) {
                
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                
            } else {
                Text(initials)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .glassEffect()
    }
    
    // MARK: - derived valuez
    
    var initials: String {
        let parts = friend.name
            .trimmingCharacters(in: .whitespaces)
            .split(separator: " ")
        
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        } else {
            return parts.first?.prefix(1).uppercased() ?? "?"
        }
    }
    
    var timeLocationString: String {
        let time = currentTimeString(for: friend)
        let trimmedCity = friend.city.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return trimmedCity.isEmpty ? time : "\(time) · \(trimmedCity)"
    }
    
    // MARK: - time display (the actual clock, yk, the app we're remixing?)
    
    func currentTimeString(for friend: Friend) -> String {
        guard let tz = TimeZone(identifier: friend.timezoneIdentifier) else {
            return "--:--"
        }
        
        let formatter = DateFormatter()
        formatter.timeZone = tz
        formatter.dateFormat = "HH:mm"
        
        return formatter.string(from: now)
    }
}
