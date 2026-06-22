//
//  structs.swift
//  CH2_Master
//  created by vitha and runi
//

import Foundation
import SwiftUI
import SwiftData

// MARK: - dayz

enum Weekday: Int, Codable, CaseIterable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
}

// MARK: - supported schedule types

enum ScheduleType: String, Codable, CaseIterable {
    case sleep
    case work
    case school
    case gym
    case travel
    case custom
    
    var mappedStatus: FriendStatus {
        switch self {
        case .sleep: return .asleep
        case .work: return .atWork
        case .school: return .atSchool
        case .gym: return .atGym
        case .travel: return .traveling
        case .custom: return .busy
        }
    }
}

// MARK: - SwiftData models

@Model
class Schedule {
    var id: UUID
    var typeRaw: String
    var title: String
    
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int
    
    var repeatDaysRaw: [Int]
    
    init(
        id: UUID = UUID(),
        type: ScheduleType,
        title: String,
        startHour: Int,
        startMinute: Int,
        endHour: Int,
        endMinute: Int,
        repeatDays: Set<Weekday> = []
    ) {
        self.id = id
        self.typeRaw = type.rawValue
        self.title = title
        self.startHour = startHour
        self.startMinute = startMinute
        self.endHour = endHour
        self.endMinute = endMinute
        self.repeatDaysRaw = repeatDays.map { $0.rawValue }
    }
    
    var type: ScheduleType {
        ScheduleType(rawValue: typeRaw) ?? .custom
    }
    
    var repeatDays: Set<Weekday> {
        Set(repeatDaysRaw.compactMap { Weekday(rawValue: $0) })
    }
}

@Model
class Friend {
    var id: UUID
    var name: String
    var photoData: Data?
    var isPinned: Bool = false
    var timezoneIdentifier: String
    var city: String
    
    @Relationship(deleteRule: .cascade)
    var schedules: [Schedule]
    
    init(
        id: UUID = UUID(),
        name: String,
        photoData: Data? = nil,
        timezoneIdentifier: String,
        city: String,
        schedules: [Schedule] = []
    ) {
        self.id = id
        self.name = name
        self.photoData = photoData
        self.timezoneIdentifier = timezoneIdentifier
        self.city = city
        self.schedules = schedules
    }
}

struct TimezoneItem: Identifiable {
    let id = UUID()
    let city: String
    let country: String
    let identifier: String
    
    var display: String {
        "\(city), \(country)"
    }
}

// MARK: - status

enum FriendStatus: String {
    case asleep
    case atWork
    case atSchool
    case atGym
    case traveling
    case busy
    case available
}

// MARK: - mapping status to its icons and bgs

struct StatusStyle {
    let iconName: String
    let background: AnyView
    let label: String
}

extension FriendStatus {
    var style: StatusStyle {
        switch self {
        case .asleep:
            return StatusStyle(iconName: "bed.double", background: AnyView(
                Image("sleepbg")
                    .resizable()
                    .scaledToFill()
            ), label: "Asleep")
        case .atWork:
            return StatusStyle(iconName: "briefcase", background: AnyView(
                Image("workbg")
                    .resizable()
                    .scaledToFill()
            ), label: "At Work")
        case .atSchool:
            return StatusStyle(iconName: "book", background: AnyView(
                Image("schoolbg")
                    .resizable()
                    .scaledToFill()
            ), label: "At School")
        case .atGym:
            return StatusStyle(iconName: "dumbbell", background: AnyView(
                Image("gymbg")
                    .resizable()
                    .scaledToFill()
            ), label: "At the Gym")
        case .traveling:
            return StatusStyle(iconName: "car", background: AnyView(
                Image("travelbg")
                    .resizable()
                    .scaledToFill()
            ), label: "Traveling")
        case .busy:
            return StatusStyle(iconName: "calendar", background: AnyView(
                Image("busybg")
                    .resizable()
                    .scaledToFill()
            ), label: "Busy")
        case .available:
            return StatusStyle(iconName: "person", background: AnyView(
                Image("availablebg")
                    .resizable()
                    .scaledToFill()
            ), label: "Available")
        }
    }
}

// MARK: - logique

func currentStatus(for friend: Friend, now: Date = Date()) -> FriendStatus {
    guard let tz = TimeZone(identifier: friend.timezoneIdentifier) else {
        return .available
    }
    
    var calendar = Calendar.current
    calendar.timeZone = tz
    
    let nowComponents = calendar.dateComponents([.hour, .minute, .weekday], from: now)
    
    let activeSchedules = friend.schedules.filter {
        isActive(schedule: $0, now: nowComponents)
    }
    
    if activeSchedules.isEmpty {
        return .available
    }
    
    let uniqueTypes = Set(activeSchedules.map { $0.type })
    
    if uniqueTypes.count == 1 {
        return uniqueTypes.first!.mappedStatus
    } else {
        return .busy
    }
}

// MARK: - timezone magique

private func isActive(schedule: Schedule, now: DateComponents) -> Bool {
    guard let hour = now.hour,
          let minute = now.minute,
          let weekdayRaw = now.weekday,
          let today = Weekday(rawValue: weekdayRaw)
    else { return false }
    
    let nowMinutes = hour * 60 + minute
    let start = schedule.startHour * 60 + schedule.startMinute
    let end = schedule.endHour * 60 + schedule.endMinute
    
    guard let yesterday = Weekday(rawValue: weekdayRaw == 1 ? 7 : weekdayRaw - 1) else {
        return false
    }
    
    let appliesToday: Bool = {
        if schedule.repeatDays.isEmpty { return true }
        
        if start <= end {
            return schedule.repeatDays.contains(today)
        } else {
            if nowMinutes >= start {
                return schedule.repeatDays.contains(today)
            } else {
                return schedule.repeatDays.contains(yesterday)
            }
        }
    }()
    
    if !appliesToday { return false }
    
    if start <= end {
        return nowMinutes >= start && nowMinutes < end
    } else {
        return nowMinutes >= start || nowMinutes < end
    }
}
