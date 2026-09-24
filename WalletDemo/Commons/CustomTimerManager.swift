//
//  CustomTimerManager.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import Foundation

@Observable
@MainActor
class CustomTimerManager {
    var timeRemaining: Int
    var isRunning: Bool = false
    
    private let initialTime: Int
    private var timerTask: Task<Void, Never>? = nil
    
    var timeFormatted: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    init(durationInSeconds: Int = 120) {
        self.initialTime = durationInSeconds
        self.timeRemaining = durationInSeconds
    }
    
    func start() {
        stop()
        timeRemaining = initialTime
        isRunning = true
        
        timerTask = Task {
            let clock = ContinuousClock()
            while timeRemaining > 0 && !Task.isCancelled {
                try? await clock.sleep(for: .seconds(1))
                guard !Task.isCancelled else { break }
                self.timeRemaining -= 1
            }
            if !Task.isCancelled {
                self.isRunning = false
            }
        }
    }
    
    func stop() {
        isRunning = false
        timerTask?.cancel()
        timerTask = nil
    }
}
