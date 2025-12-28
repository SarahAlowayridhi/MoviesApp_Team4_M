//
//  RootView.swift
//  MoviesApp_Team4_M
//
//  Created by Ruba Alghamdi on 08/07/1447 AH.
//

import SwiftUI

struct RootView: View {
    @State private var isSignedIn = false

    var body: some View {
        NavigationStack {
            if isSignedIn {
                MoviesCenter()
            } else {
                SignInView {
                    isSignedIn = true
                }
            }
        }
    }
}

#Preview {
    RootView()
}
