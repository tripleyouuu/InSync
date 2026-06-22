//
//  timemanager.swift
//  CH2_Master
//  created by vitha and runi
//

import Foundation
import Combine

final class TimeManager: ObservableObject {
    
    @Published var now: Date = Date()
    
    private var timer: Timer?
    
    init() {
        start()
    }
    
    private func start() {
        let seconds = Calendar.current.component(.second, from: Date())
        let delay = 60 - seconds
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay)) {
            self.now = Date()
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                self.now = Date()
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
