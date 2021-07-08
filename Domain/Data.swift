//
//  Data.swift
//  Domain
//
//  Created by Alex on 21.06.2021.
//
//
// https://gist.github.com/nokimaro/73388765d3a592b02583b7da79d0466f

import Foundation


struct Domains: Codable {
    let response: Response
}

struct Response: Codable {
    let count: Int
    let items: [Item]
}

struct Item: Codable {
    let domain: String
    let freeAt, checkedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case domain
        case freeAt = "free_at"
        case checkedAt = "checked_at"
    }
}

class IsLoader {
    @Published var isLoader = false
}

class Api {
    let api = "4.noki.cc"
    func getPosts(mask: String, zone: String, length: String, list: String, no_digit: Bool, no_dash: Bool, no_alpha: Bool, completion: @escaping(Domains) -> ()) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = api
        components.path = "/api/get_domains.php"
        components.queryItems = [
            URLQueryItem(name: "mask", value: mask),
            URLQueryItem(name: "zone", value: zone),
            URLQueryItem(name: "list", value: list),
            URLQueryItem(name: "offset", value: "0"),
            URLQueryItem(name: "count", value: "20"),
            URLQueryItem(name: "length", value: length),
        ]
        if (no_digit) {
            components.queryItems?.append(URLQueryItem(name: "no_digit", value: "1"))
        }
        if (no_dash) {
            components.queryItems?.append(URLQueryItem(name: "no_dash", value: "1"))
        }
        if (no_alpha) {
            components.queryItems?.append(URLQueryItem(name: "no_alpha", value: "1"))
        }
        //guard let url = URL(string: "https://4.noki.cc/api/get_domains.php?mask=**1&zone=ru&list=all&offset=0&count=10&length=3") else { return }
        
        guard let url = components.url else { return }
        
        print(url)
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            IsLoader().isLoader = true
            
            if error != nil {
                IsLoader().isLoader = false
                return
            }
            
            guard let data = data else { return }
            
            let domains = try! JSONDecoder().decode(Domains.self, from: data)
            
            DispatchQueue.main.async {
                completion(domains)
                IsLoader().isLoader = false
            }
        }
        .resume()
    }
}


