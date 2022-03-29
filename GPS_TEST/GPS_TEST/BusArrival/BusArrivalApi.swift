//
//  BusArrivalApi.swift
//  GPS_TEST
//
//  Created by Gerald on 10/3/22.
//

import Foundation

class BusArrivalApi: ObservableObject {
//    @Published var responses = BusArrivalInfo(metadata: "", busStopCode: 0,
//                                              services: [])
    
    func loadData(busStopCode: String, busServices: [String], completion:@escaping ([String: String]) -> ()) {
//        guard let url = URL(string: "https://training.xcelvations.com/data/books.json") else {
//            print("invalid url...")
//            return
//        }
        

        guard let url = URL(string: "http://datamall2.mytransport.sg/ltaodataservice/BusArrivalv2?BusStopCode=\(busStopCode)") else {
            print("invalid url...")
            return
        }

        var request = URLRequest(url: url)
        request.addValue("IMC5QMM+QRixua7zFSeB3w==", forHTTPHeaderField: "AccountKey")

        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {return}
            
//            print("data:\(data)")
//            print("error:\(error)")
//            print("response:\(response)")
            
            do {
                let responses = try JSONDecoder().decode(BusArrivalInfo.self, from: data)

//                print(responses)
                
                var output: [String: String] = [String: String]()
                
//                print(responses.services)
                
                for svc in responses.services {
//                    print("svcNum:", svc.svcNum)
                    if busServices.contains(svc.svcNum) {
                        // convert estimatedArrival timestamp to minutes here
                        let time = String(svc.bus1.estimatedArrival.dropFirst(11).prefix(5))
//                        print("Time: \(time)")
                        
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
