//
//  PerformanceManager.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 1.09.23.
//

import FirebasePerformance

final class PerformanceManager {
    static let shared = PerformanceManager()
    private init() {}
    
    private var traces: [String: Trace] = [:]
    
    func startTrace(name: String) {
        traces[name] = Performance.startTrace(name: name)
    }
    
    func setValue(name: String, value: String, forAttribute attribute: String) {
        guard let trace = traces[name] else { return }
        trace.setValue(value, forAttribute: attribute)
    }
    
    func stopTrace(name: String) {
        guard let trace = traces[name] else { return }
        trace.stop()
        traces[name] = nil
    }
}
