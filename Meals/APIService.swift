//
//  APIService.swift
//  Meals
//
//  Created by 김승재 on 2018. 8. 10..
//  Copyright © 2018년 Me. All rights reserved.
//

import Cocoa

class APIService: NSObject {
    
    let year = "2018"
    let month = "8"
    let day  = "10"
    lazy var endPoint: String = { return "https://schoolmenukr.ml/api/ice/E100002238?year=\(self.year)&month=\(self.month)&day=\(self.day)" }()
    
    func getDataWith(completion: @escaping (Result<[String: AnyObject]>) -> Void) {
        guard let url = URL(string: endPoint) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else { return }
            guard let data = data else { return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? [String: AnyObject] {
                    DispatchQueue.main.async {
                        completion(.Success(json))
                    }
                }
            } catch let error {
                print(error)
            }
            }.resume()
    }
    
}
enum Result <T>{
        case Success(T)
        case Error(String)
}
