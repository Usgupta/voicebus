//
//  ContentView.swift
//  API_GPS_Test
//
//  Created by Gerald on 4/2/22.
//

import SwiftUI

struct ContentView: View {
    @State var responses = BusArrivalInfo(metadata: "", busStopCode: "", services: [])
    
    @State var busSvcNum = "not yet retrieved from api"
    
    var body: some View {
//        Text("Hello, world!")
//            .padding()
//            .onAppear() {
//                Api().loadData { item in
//                    self.responses = item
//                }
//            }
        Text("Bus Service: " + busSvcNum)
        Button("Retrieve API") {
            Api().loadData { item in
                self.responses = item
                self.busSvcNum = item.services[0].svcNum
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
