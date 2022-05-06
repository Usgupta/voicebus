//
//  BusStopInfo.swift
//  VoiceBus
//
//  Created by Umang Gupta on 5/5/22.
//

import Foundation

struct BusStop: Codable {
    
    enum CodingKeys: String, CodingKey {
        case busStopCode = "BusStopCode"
        case roadName = "RoadName"
        case description = "Description"
        case lat = "Latitude"
        case long = "Longitude"
    }
    
    var busStopCode: String
    var roadName: String
    var description: String
    var lat: Double
    var long: Double
}

struct BusStopInfo: Codable {
    
    enum CodingKeys: String, CodingKey {
        case metadata = "odata.metadata"
        case busStops = "value"
    }
    
    var metadata: String
    var busStops: [BusStop]
}



