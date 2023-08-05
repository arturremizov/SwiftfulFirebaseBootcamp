//
//  UIApplication+Extensions.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 5.08.23.
//

import UIKit

extension UIApplication {
    
    var keyWindow: UIWindow? {
        connectedScenes
            .compactMap {
                $0 as? UIWindowScene
            }
            .flatMap {
                $0.windows
            }
            .first {
                $0.isKeyWindow
            }
    }
    
    @MainActor
    func topMostController() -> UIViewController? {
        var topController: UIViewController? = keyWindow?.rootViewController
        while (topController?.presentedViewController != nil) {
            topController = topController?.presentedViewController
        }
        return topController
    }
}
