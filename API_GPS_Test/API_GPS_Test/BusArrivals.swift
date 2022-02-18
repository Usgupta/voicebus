//
//  BusArrivals.swift
//  API_GPS_Test
//
//  Created by Gerald on 4/2/22.
//

import Foundation

struct BusInfo: Codable {
    
    enum CodingKeys: String, CodingKey {
        case originCode = "OriginCode"
        case destinationCode = "DestinationCode"
        case estimatedArrival = "EstimatedArrival"
        case lat = "Latitude"
        case long = "Longitude"
        case visitNum = "VisitNumber"
        case load = "Load"
        case feature = "Feature"
        case type = "Type"
    }
    
    var originCode: String
    var destinationCode: String
    var estimatedArrival: String
    var lat: String
    var long: String
    var visitNum: String
    var load: String
    var feature: String
    var type: String
}

struct BusService: Codable {
    
    enum CodingKeys: String, CodingKey {
        case svcNum = "ServiceNo"
        case busOperator = "Operator"
        case bus1 = "NextBus"
        case bus2 = "NextBus2"
        case bus3 = "NextBus3"
    }
    
    var svcNum: String
    var busOperator:  String
    var bus1: BusInfo
    var bus2: BusInfo
    var bus3: BusInfo
}

struct BusArrivalInfo: Codable {
    
    enum CodingKeys: String, CodingKey {
        case metadata = "odata.metadata"
        case busStopCode = "BusStopCode"
        case services = "Services"
    }
    
    var metadata: String
    var busStopCode: String
    var services: [BusService]
}

class Api: ObservableObject {
//    @Published var responses = BusArrivalInfo(metadata: "", busStopCode: 0,
//                                              services: [])
    
    func loadData(completion:@escaping (BusArrivalInfo) -> ()) {
//        guard let url = URL(string: "https://training.xcelvations.com/data/books.json") else {
//            print("invalid url...")
//            return
//        }

        guard let url = URL(string: "http://datamall2.mytransport.sg/ltaodataservice/BusArrivalv2?BusStopCode=83139") else {
            print("invalid url...")
            return
        }

        var request = URLRequest(url: url)
        request.addValue("insert api key here", forHTTPHeaderField: "AccountKey")

        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {return}
            
            print("data:\(data)")
//            print("error:\(error)")
//            print("response:\(response)")
            
            do {
                let responses = try JSONDecoder().decode(BusArrivalInfo.self, from: data)

                print(responses)
                
                
                DispatchQueue.main.async {
                    completion(responses)
                }
            } catch let error {
                print("Session Error: ", error)
            }
            
        }.resume()
    }
}
