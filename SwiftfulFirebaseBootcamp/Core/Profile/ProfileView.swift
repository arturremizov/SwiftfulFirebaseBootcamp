//
//  ProfileView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 11.08.23.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    
    @Binding var isShowingSignInView: Bool
    @StateObject var viewModel: ProfileViewModel
    @EnvironmentObject private var authManager: AuthenticationManager
    
    var body: some View {
        List {
            if let user = viewModel.user {
                Text("UserId: \(user.userId)")
                Text("Is Anonymous: \(user.isAnonymous.description.capitalized)")
                
                Button {
                    Task {
                        try await viewModel.togglePremiumStatus()
                    }
                } label: {
                    Text("User is premium: \((user.isPremium ?? false).description.capitalized)")
                }
                
                VStack {
                    HStack {
                        ForEach(viewModel.preferences, id: \.self) { preference in
                            Button(preference) {
                                Task {
                                    if viewModel.preferenceIsSelected(preference) {
                                        try await viewModel.removeUserPreference(preference)
                                    } else {
                                        try await viewModel.addUserPreference(preference)
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .font(.headline)
                            .tint(viewModel.preferenceIsSelected(preference) ? .green : .gray)
                        }
                    }
                    
                    Text("User preferences: \((user.preferences ?? []).joined(separator: ", "))")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Button {
                    Task {
                        if viewModel.user?.favoriteMovie == nil {
                            try await viewModel.addFavoriteMovie()
                        } else {
                            try await viewModel.removeFavoriteMovie()
                        }
                    }
                } label: {
                    Text("Favorite Movie: \(user.favoriteMovie?.title ?? "")")
                }
                
                PhotosPicker(
                    selection: $viewModel.selectedPhotoItem,
                    matching: .images,
                    photoLibrary: .shared()) {
                        Text("Select an image")
                    }
                
                if let profileImageUrl = viewModel.user?.profileImageUrl, let url = URL(string: profileImageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .cornerRadius(10, antialiased: true)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 150, height: 150)
                    }
                    
                    if (viewModel.user?.profileImagePath) != nil {
                        Button("Delete image", role: .destructive) {
                            Task {
                                try await viewModel.deleteProfileImage()
                                try await viewModel.loadCurrentUser()
                            }
                        }
                    }
                }
            }
        }
        .task {
            do {
                try await viewModel.loadCurrentUser()
            } catch {
                print(error.localizedDescription)
            }
        }
        .onChange(of: viewModel.selectedPhotoItem, perform: { newValue in
            if let newValue {
                Task {
                    do {
                        try await viewModel.saveProfileImage(item: newValue)
                        try await viewModel.loadCurrentUser()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        })
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    SettingsView(
                        isShowingSignInView: $isShowingSignInView,
                        viewModel: SettingsViewModel(authManager: authManager)
                    )
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.headline)
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView(
                isShowingSignInView: .constant(false),
                viewModel: ProfileViewModel(authManager: .init(), userManager: .init(), storageManager: .init())
            )
        }
        .environmentObject(AuthenticationManager())
    }
}
