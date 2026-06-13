//
//  AuthService.swift
//  Vibe
//

import Foundation

class AuthService: ObservableObject {
    @Published var isLoggedIn: Bool

    init() {
        isLoggedIn = APIClient.shared.isLoggedIn
    }

    func login(code: String) async throws {
        struct LoginReq: Encodable { let code: String }
        let resp: LoginResponse = try await APIClient.shared.request("/auth/login", method: "POST", body: LoginReq(code: code))
        APIClient.shared.token = resp.token
        await MainActor.run { isLoggedIn = true }
    }

    func logout() {
        APIClient.shared.token = nil
        DispatchQueue.main.async { self.isLoggedIn = false }
    }
}
