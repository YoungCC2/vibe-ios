//
//  APIClient.swift
//  Vibe
//
//  网络层封装 — 基于 URLSession
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case unauthorized
    case serverError(Int, String)
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:           return "无效的请求"
        case .unauthorized:         return "登录已过期，请重新登录"
        case .serverError(_, let m): return m
        case .decodingError:        return "数据解析失败"
        case .networkError:         return "网络连接失败"
        }
    }
}

class APIClient {
    static let shared = APIClient()

    private let baseURL: String
    private let session: URLSession

    private init() {
        baseURL = AppConfig.apiBaseURL
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        config.waitsForConnectivity = true
        session = URLSession(configuration: config)
    }

    // MARK: - Token 管理（Keychain 安全存储）
    private let tokenKey = "vibe_jwt_token"
    var token: String? {
        get { KeychainHelper.load(forKey: tokenKey) }
        set {
            if let newValue {
                KeychainHelper.save(newValue, forKey: tokenKey)
            } else {
                KeychainHelper.delete(forKey: tokenKey)
            }
        }
    }
    var isLoggedIn: Bool { token != nil }

    // MARK: - 请求方法
    func request<T: Codable>(
        _ path: String,
        method: String = "GET",
        body: Encodable? = nil,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> T {
        guard var components = URLComponents(string: baseURL + path) else {
            throw APIError.invalidURL
        }
        if let queryItems { components.queryItems = queryItems }

        guard let url = components.url else { throw APIError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            req.httpBody = try JSONEncoder().encode(body.anyEncodable)
        }

        let (data, response) = try await session.data(for: req)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(URLError(.badServerResponse))
        }

        if httpResponse.statusCode == 401 {
            token = nil
            throw APIError.unauthorized
        }

        let apiResp = try JSONDecoder().decode(APIResponse<T>.self, from: data)

        if apiResp.code != 0 {
            throw APIError.serverError(apiResp.code, apiResp.message)
        }

        guard let result = apiResp.data else {
            throw APIError.serverError(0, "空响应")
        }

        return result
    }

    // MARK: - 上传文件
    func upload(
        fileData: Data,
        fileName: String,
        mimeType: String,
        type: String
    ) async throws -> UploadResult {
        guard let url = URL(string: baseURL + "/upload") else { throw APIError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        if let token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let boundary = UUID().uuidString
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        // type 字段
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"type\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(type)\r\n".data(using: .utf8)!)
        // file
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        let (data, response) = try await session.upload(for: req, from: body)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(URLError(.badServerResponse))
        }

        if httpResponse.statusCode == 401 {
            token = nil
            throw APIError.unauthorized
        }

        let apiResp = try JSONDecoder().decode(APIResponse<UploadResult>.self, from: data)

        if apiResp.code != 0 {
            throw APIError.serverError(apiResp.code, apiResp.message)
        }

        guard let data = apiResp.data else {
            throw APIError.serverError(apiResp.code, "上传成功但服务端未返回数据")
        }
        return data
    }
}

// 泛型 Encodable wrapper
extension Encodable {
    var anyEncodable: AnyEncodable { AnyEncodable(self) }
}

struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void
    init(_ wrapped: Encodable) { encodeFunc = wrapped.encode }
    func encode(to encoder: Encoder) throws { try encodeFunc(encoder) }
}
