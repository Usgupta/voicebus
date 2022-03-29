//
//  BusArrivalInfo.swift
//  GPS_TEST
//
//  Created by Gerald on 10/3/22.
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
