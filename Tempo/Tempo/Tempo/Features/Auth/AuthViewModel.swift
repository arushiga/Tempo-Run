//
//  AuthViewModel.swift
//  Tempo
//
//  Created by Kristine Huang on 4/5/26.
//

import Foundation
import Combine
import FirebaseAuth

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var errorMessage: String? = nil
    @Published var isLoading = false

    init() {
        // Automatically detect if user is already logged in
        self.user = Auth.auth().currentUser
    }

    func signUp(fullName: String, email: String, password: String) async {
          do {
              let result = try await Auth.auth().createUser(withEmail: email, password: password)

              let changeRequest = result.user.createProfileChangeRequest()
              changeRequest.displayName = fullName
              try await changeRequest.commitChanges()

              try await result.user.reload()
              self.user = Auth.auth().currentUser
          } catch {
              errorMessage = error.localizedDescription
          }
      }

    func signIn(email: String, password: String) async {
      isLoading = true
      errorMessage = nil
      do {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        self.user = result.user
      } catch {
        errorMessage = error.localizedDescription
      }
      isLoading = false
    }
  
    func resetPassword(email: String) async {
        isLoading = true
        errorMessage = nil
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }


    func signOut(store: AppDataStore) {
        try? Auth.auth().signOut()
        self.user = nil
        store.clearUserData()
    }

    private func clearLocalCache() {
        let keys = UserDefaults.standard.dictionaryRepresentation().keys
        keys.filter { $0.hasPrefix("tempo_") }.forEach {
            UserDefaults.standard.removeObject(forKey: $0)
        }
    }
}
