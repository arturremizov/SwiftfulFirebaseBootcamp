//
//  PerformanceView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 1.09.23.
//

import SwiftUI
import FirebasePerformance

struct PerformanceView: View {
    @State private var title: String = "Some title"
    var body: some View {
        Text("Hello, World!")
            .onAppear {
                configure()
                downloadProducts()
                PerformanceManager.shared.startTrace(name: "performance_screen_time")
            }
            .onDisappear {
                PerformanceManager.shared.stopTrace(name: "performance_screen_time")

            }
        
    }
    
    private func configure() {
        let traceName = "performance_view_loading"
        let attribute = "func_state"

        let performanceManager = PerformanceManager.shared
        performanceManager.startTrace(name: traceName)

        Task {
            try? await Task.sleep(for: .seconds(2))
            performanceManager.setValue(name: traceName, value: "Started downloading", forAttribute: attribute)
            
            try? await Task.sleep(for: .seconds(2))
            performanceManager.setValue(name: traceName, value: "Continued downloading", forAttribute: attribute)
            
            try? await Task.sleep(for: .seconds(2))
            performanceManager.setValue(name: traceName, value: "Finished downloading", forAttribute: attribute)
            
            performanceManager.stopTrace(name: traceName)
        }
    }
    
    func downloadProducts() {
        let urlString = "https://dummyjson.com/products"
        guard let url = URL(string: urlString), let metric = HTTPMetric(url: url, httpMethod: .get) else { return }
        metric.start()
        Task {
            do {
                let (_, response) = try await URLSession.shared.data(from: url)
                if let response = response as? HTTPURLResponse {
                    metric.responseCode = response.statusCode
                }
                metric.stop()
                print("Success.")
            } catch {
                print(error.localizedDescription)
                metric.stop()
            }
        }
    }
}

struct PerformanceView_Previews: PreviewProvider {
    static var previews: some View {
        PerformanceView()
    }
}
