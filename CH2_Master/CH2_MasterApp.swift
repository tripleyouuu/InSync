//
//  ch2_masterapp.swift
//  CH2_Master
//  created by vitha and runi
//


import SwiftUI
import SwiftData

@main
struct CH2_MasterApp: App {
    init() {
        setDarkMode()
    }
    
    var body: some Scene {
        
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [Friend.self, Schedule.self])
    }
    
    private func setDarkMode() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
        let window = scene.windows.first else { return }
        window.overrideUserInterfaceStyle = .dark
    }
}
