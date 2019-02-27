//
//  MarvelResponse.swift
//  Capstone
//
//  Created by Frederik Skytte on 26/02/2019.
//  Copyright © 2019 Frederik Skytte. All rights reserved.
//

import Foundation

struct MarvelResponse: Codable {
    let code: String
    let data: MarvelData?
}

struct MarvelData: Codable {
    let offset: Int
    let limit: Int
    let total: Int
    let count: Int
    let results: [MarvelCharacter]
}

struct MarvelCharacter: Codable {
    let id: Int
    let name: String
    let results: [MarvelData]
}

struct Thumbnail: Codable {
    let path: String
    let ext: String
    
    enum CodingKeys: String, CodingKey {
        case path
        case ext = "extension"
    }
}
