//
//  BusArrivalApi.swift
//  VoiceBus
//
//  Created by Umang Gupta on 5/5/22.
//

import Foundation

class BusArrivalApi: ObservableObject {
    
    func loadData(busStopCode: String, busServices: [String], completion:@escaping ([String: String]) -> ()) {

        

        guard let url = URL(string: "http://datamall2.mytransport.sg/ltaodataservice/BusArrivalv2?BusStopCode=\(busStopCode)") else {
            print("invalid url...")
            return
        }

        var request = URLRequest(url: url)
        request.addValue("IMC5QMM+QRixua7zFSeB3w==", forHTTPHeaderField: "AccountKey")
//        request.addValue("insert api key here", forHTTPHeaderField: "AccountKey")


        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {return}
            
            do {
                let responses = try JSONDecoder().decode(BusArrivalInfo.self, from: data)
                
                var output: [String: String] = [String: String]()
                
                
                for svc in responses.services {
//                    print("svcNum:", svc.svcNum)
                    if busServices.contains(svc.svcNum) {
                        // convert estimatedArrival timestamp to minutes here
                        let time = String(svc.bus1.estimatedArrival.dropFirst(11).prefix(5))
//                        let time = String("00:24")
                        print("Time: \(time)")
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "HH:mm"
                        let timeDate = dateFormatter.date(from: time)!
                        let calendar = Calendar.current
                        let timeComponents = calendar.dateComponents([.hour, .minute], from: timeDate)
                        let nowComponents = calendar.dateComponents([.hour, .minute], from: Date())

                        let difference = abs(calendar.dateComponents([.minute], from: timeComponents, to: nowComponents).minute!)
//                        print("Difference: \(difference)")
                        output[svc.svcNum] = "\(difference)"
                    }
                }
                
                
                DispatchQueue.main.async {
                    
                    completion(output)
                }
            } catch let error {
                print("Session Error: ", error)
            }
            
        }.resume()
    }
}

