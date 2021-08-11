//
//  Model.swift
//  WorldrTest
//
//  Created by Ali Gadzhiev on 10.08.2021.
//

import Foundation

struct Item: Decodable {

    let id: String
    let text: String
    let attachment: Attachment?

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case attachment = "attachments"
    }
}

extension Item: Equatable {

    static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id
    }
}

struct Attachment: Decodable {

    let url: URL
    let width: Float
    let height: Float

    enum CodingKeys: String, CodingKey {
        case url
        case width
        case height
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = try container.decode(URL.self, forKey: .url)
        width = try container.decode(Float.self, forKey: .width)
        height = try container.decode(Float.self, forKey: .height)
    }
}
