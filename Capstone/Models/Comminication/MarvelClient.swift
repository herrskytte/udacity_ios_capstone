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
    
    /*
    class func getFavorites(completion: @escaping ([Movie], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getFavorites.url, responseType: MovieResults.self) { (responseObject, error) in
            guard let responseObject = responseObject else {
                completion([], error)
                return
            }
            completion(responseObject.results, nil)
        }
    }
    
    class func search(query: String, completion: @escaping ([Movie], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.search(query).url, responseType: MovieResults.self) { (responseObject, error) in
            guard let responseObject = responseObject else {
                completion([], error)
                return
            }
            completion(responseObject.results, nil)
        }
    }
    
    class func markWatchlist(movieId: Int, mark: Bool, completion: @escaping (Bool, Error?) -> Void) {
        let body = MarkWatchlist(mediaType: MediaType.movie.rawValue, mediaId: movieId, watchlist: mark)
        taskForPOSTRequest(url: Endpoints.markWatchlist.url, requestBody: body, responseType: TMDBResponse.self) { (responseObject, error) in
            if let responseObject = responseObject {
                completion(
                    responseObject.statusCode == 1 ||
                        responseObject.statusCode == 12 ||
                        responseObject.statusCode == 13, nil)
            }
            else{
                completion(false, error)
            }
        }
    }
    
    class func markFavorite(movieId: Int, mark: Bool, completion: @escaping (Bool, Error?) -> Void) {
        let body = MarkFavorite(mediaType: MediaType.movie.rawValue, mediaId: movieId, favorite: mark)
        taskForPOSTRequest(url: Endpoints.markFavorite.url, requestBody: body, responseType: TMDBResponse.self) { (responseObject, error) in
            if let responseObject = responseObject {
                completion(
                    responseObject.statusCode == 1 ||
                        responseObject.statusCode == 12 ||
                        responseObject.statusCode == 13, nil)
            }
            else{
                completion(false, error)
            }
        }
    }

    
    class func getImage(imgPath: String, completion: @escaping (Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.posterImage(imgPath).url) {
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
    
    class func getRequestToken(completion: @escaping (Bool, Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getRequestToken.url, responseType: RequestTokenResponse.self) { (responseObject, error) in
            guard let responseObject = responseObject else {
                completion(false, error)
                return
            }
            Auth.requestToken = responseObject.requestToken
            completion(responseObject.success, nil)
        }
    }
    
    class func login(un: String, pw: String, completion: @escaping (Bool, Error?) -> Void) {
        let body = LoginRequest(username: un, password: pw, requestToken: Auth.requestToken)
        taskForPOSTRequest(url: Endpoints.login.url, requestBody: body, responseType: RequestTokenResponse.self) { (responseObject, error) in
            guard let responseObject = responseObject else {
                completion(false, error)
                return
            }
            Auth.requestToken = responseObject.requestToken
            completion(responseObject.success, nil)
        }
    }
    
    class func getSessionId(completion: @escaping (Bool, Error?) -> Void) {
        let body = PostSession(requestToken: Auth.requestToken)
        taskForPOSTRequest(url: Endpoints.getSessionId.url, requestBody: body, responseType: SessionResponse.self) { (responseObject, error) in
            guard let responseObject = responseObject else {
                completion(false, error)
                return
            }
            Auth.sessionId = responseObject.sessionId
            completion(responseObject.success, nil)
        }
    }
    
    class func logout(completion: @escaping () -> Void) {
        var request = URLRequest(url: Endpoints.logout.url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = LogoutRequest(sessionId: Auth.sessionId)
        request.httpBody = try! JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            Auth.requestToken = ""
            Auth.sessionId = ""
            completion()
        }
        task.resume()
    }
 
 */
    
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
                //print(String(decoding: data, as: UTF8.self))
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
