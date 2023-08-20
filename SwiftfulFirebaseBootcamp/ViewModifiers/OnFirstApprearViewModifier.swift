//
//  OnFirstApprearViewModifier.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 20.08.23.
//

import SwiftUI

struct OnFirstApprearViewModifier: ViewModifier {
    let perform: (() -> Void)?
    @State private var isDidAppear = false
    func body(content: Content) -> some View {
        content
            .onAppear {
                guard !isDidAppear else { return }
                perform?()
                isDidAppear = true
            }
    }
}

extension View {
    func onFirstAppear(perform: (() -> Void)?) -> some View {
        modifier(OnFirstApprearViewModifier(perform: perform))
    }
}
