//
//  MarvelClient.swift
//  Capstone
//
//  Created by Frederik Skytte on 12/02/2019.
//  Copyright © 2019 Frederik Skytte. All rights reserved.
//

import Foundation

class MarvelClient {
    
    static let apiKey = "267b7e797ccd15b61bcdcda5583e33da"
    static let serverKey = "707b2fc5998003196709ba0591c2d24b26227ec3"
    
    enum Endpoints {
        static let base = "https://gateway.marvel.com:443/v1/public/"
        static let securityParam = { () -> String in
            let ts = NSDate().timeIntervalSince1970.description
            let hash = "\(ts)\(serverKey)\(apiKey)".md5()
            return "?apikey=\(apiKey)&ts=\(ts)&hash=\(hash)"
        }
        static let apiKeyParam = "?apikey=\(MarvelClient.apiKey)"
        
        case getCharacters
        case searchCharacters(String)
        
        var stringValue: String {
            switch self {
                case .getCharacters:
                    return "\(Endpoints.base)characters\(createSecurity())&offset=\(createRandomOffset())"
                case .searchCharacters(let q):
                    return "\(Endpoints.base)characters\(createSecurity())\(createSearchQuery(q))"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
        
        func createSecurity() -> String {
            let ts = NSDate().timeIntervalSince1970.description
            let hash = "\(ts)\(serverKey)\(apiKey)".md5()
            return "?apikey=\(apiKey)&ts=\(ts)&hash=\(hash)"
        }
        
        func createSearchQuery(_ q: String) -> String {
            return "&nameStartsWith=\(q.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }
        
        func createRandomOffset() -> Int {
            return Int.random(in: 0 ... 1000)
        }
    }
    
    class func getCharacters(completion: @escaping ([MarvelCharacter], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getCharacters.url, responseType: MarvelResponse.self) {
            (responseObject, error) in
            guard let responseObject = responseObject else {
                completion([], error)
                return
            }
            print(responseObject)
            print(responseObject.code)
            completion(responseObject.data?.results ?? [], nil)
        }
    }
    
    class func search(query: String, completion: @escaping ([MarvelCharacter], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.searchCharacters(query).url, responseType: MarvelResponse.self) {
            (responseObject, error) in
            guard let responseObject = responseObject else {
                completion([], error)
                return
            }
            completion(responseObject.data?.results ?? [], nil)
        }
    }
    
    class func getImage(imgPath: String, completion: @escaping (Data?, Error?) -> Void) {
        print("Downloading image \(imgPath)")
        let task = URLSession.shared.dataTask(with: URL(string: imgPath)!) {
            (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            DispatchQueue.main.async {
                completion(data, nil)
            }
        }
        task.resume()
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void){
        
        print(url.absoluteString)
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            do {
                let responseObject = try JSONDecoder().decode(responseType, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            }
            catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, requestBody: RequestType, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void){
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(requestBody)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            do {
                let responseObject = try JSONDecoder().decode(responseType, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            }
            catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
}
