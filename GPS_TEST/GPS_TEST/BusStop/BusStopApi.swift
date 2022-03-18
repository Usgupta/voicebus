//
//  BusStopApi.swift
//  GPS_TEST
//
//  Created by Gerald on 10/3/22.
//

import Foundation
import MapKit

class BusStopApi: ObservableObject {
//    @Published var responses = BusArrivalInfo(metadata: "", busStopCode: 0,
//                                              services: [])
    
    var consolidatedBusStopsArr: [[BusStop]] = [[], [], [], [], [], [], [], [], [], [], []]
    var busStops: [BusStop] = []
    
    func loadData(urlString: String, completion:@escaping (BusStopInfo) -> ()) {
//        var busStops: [BusStop] = []
//        var skipValue = 0
        
//        for i in 0...10 {
//            group.enter()

//      As of July 2021, there are 5,049 bus stops in operation islandwide. (11 x 500 = 5500)
//        var urlString = ""
//        urlString = "http://datamall2.mytransport.sg/ltaodataservice/BusStops"
//        if skipValue == 0 {
//            urlString = "http://datamall2.mytransport.sg/ltaodataservice/BusStops"
//        } else {
//            urlString = "http://datamall2.mytransport.sg/ltaodataservice/BusStops?$skip=\(skipValue * 500)"
//        }
        print(urlString)

        guard let url = URL(string: urlString) else {
            print("invalid url...")
            return
        }

        var request = URLRequest(url: url)
        request.addValue("Put API KEY here", forHTTPHeaderField: "AccountKey")


        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {return}

//            print("data:\(data)")
//            print("error:\(error)")
//            print("response:\(response)")

            do {
                let responses = try JSONDecoder().decode(BusStopInfo.self, from: data)


//
                DispatchQueue.main.async {
//                    self.consolidatedBusStopsArr[i] = responses.busStops
//                    print(self.consolidatedBusStopsArr[i].count)
//                        group.leave()
                    completion(responses)
                }
            } catch let error {
                print("Session Error: ", error)
            }

        }.resume()
//            skipValue += 1
//        }
    }
    
    
    func calculateNearestBusStop(busStops: [BusStop], currentLocationLat: CLLocationDegrees, currentLocationLong: CLLocationDegrees) -> String {
        
//        print(consolidatedBusStopsArr)
        // aggregate the bus stop lists
//        var busStops: [BusStop] = []
        print(self.busStops.count)
//        for busStopArr in self.consolidatedBusStopsArr {
//            print(busStopArr.count)
//            busStops += busStopArr
////            print("yes")
////            print(busStopArr)
//        }
        
        // setup
        var nearestBusStop: String = "nil"
        var minDist = CLLocationDistance(3000)
        
        // caluclation
        print("calculating nearest bus stop...")
        print(busStops.count)
        for busStop in busStops {
            
            let busStopLocation = CLLocation(latitude: busStop.lat, longitude: busStop.long)
            let currentLocation = CLLocation(latitude: currentLocationLat, longitude: currentLocationLong)
            let distanceInMeters = currentLocation.distance(from: busStopLocation)
            
            
//            print("distanceInMeters: \(distanceInMeters)")
            
            if distanceInMeters < minDist {
                minDist = distanceInMeters
                nearestBusStop = busStop.busStopCode
            }
//            print("minDist: \(minDist)")
//            print("nearestBusStop: \(nearestBusStop)")
        }
        print("completed!")
        
        return nearestBusStop
    }
}
