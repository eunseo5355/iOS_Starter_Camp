//
//  Note.swift
//  CloudNotes
//
//  Created by 배은서 on 2021/06/01.
//

import Foundation

struct Note: Decodable {
    let title: String
    let body: String
    let lastModified: Int
    var formattedLastModified: String?
    
    private enum CodingKeys: String, CodingKey {
        case title, body
        case lastModified = "last_modified"
    }
}
