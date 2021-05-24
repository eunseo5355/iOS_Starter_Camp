//
//  Requestable.swift
//  OpenMarket
//
//  Created by Hailey, Ryan on 2021/05/17.
//

import Foundation

protocol Requestable: MultipartConvertible {
    func makeMultipartBody(_ body: Item) -> Data?
    func makeBody(_ body: Item) -> Data?
    func makeRequest(url: URL?, httpMethod: HTTPMethod, body: Item) -> URLRequest?
}

extension Requestable {
    func makeMultipartBody(_ body: Item) -> Data? {
        let boundary = generateBoundaryString()
        let mirror = Mirror(reflecting: body)
        var parameter: [String: Any] = [:]
        
        mirror.children.forEach({ child in
            guard let label = child.label else { return }
            parameter["\(label)"] = child.value
        })
        
        return createBody(parameters: parameter, boundary: boundary)
    }
    
    func makeBody(_ body: Item) -> Data? {
        guard let body = try? JSONEncoder().encode(body) else { return nil }
        return body
    }
    
    func makeRequest(url: URL?, httpMethod: HTTPMethod, body: Item) -> URLRequest? {
        guard let requestURL = url else { return nil }
        
        switch httpMethod {
        case .delete:
            var request = URLRequest(url: requestURL, httpMethod: httpMethod)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = makeBody(body)
            return request
        case .post, .patch:
            let boundary = generateBoundaryString()
            var request = URLRequest(url: requestURL, httpMethod: httpMethod)
            request.setValue(
                "multipart/form-data; boundary=\(boundary)",
                forHTTPHeaderField: "Content-Type"
            )
            request.httpBody = makeMultipartBody(body)
            return request
        default:
            print("존재하지 않는 요청입니다.")
            return nil
        }
    }
}
