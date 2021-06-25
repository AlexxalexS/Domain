//
//  Data.swift
//  Domain
//
//  Created by Mac on 21.06.2021.
//

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


class Api {
    let api = "4.noki.cc"
    func getPosts(mask: String, zone: String, length: String, list: String, completion: @escaping(Domains) -> ()) {
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
        //guard let url = URL(string: "https://4.noki.cc/api/get_domains.php?mask=**1&zone=ru&list=all&offset=0&count=10&length=3") else { return }
        
        guard let url = components.url else { return }
        
        //print(url)
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            
            let domains = try! JSONDecoder().decode(Domains.self, from: data)
     
            DispatchQueue.main.async {
                completion(domains)
                
            }
        }
        .resume()
    }
}


