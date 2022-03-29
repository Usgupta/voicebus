//
//  ContentView.swift
//  GPS_TEST
//
//  Created by Gerald on 18/2/22.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    @State private var isRecording = false
        
    @State var texttoaudio = TextToAudio()

    
    // GPS
    @StateObject private var viewModel = ContentViewModel()
    @State private var coordinates = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    @State private var currentLat: Double = 0.0
    @State private var currentLong: Double = 0.0
    
    
    // BusArrival
    @State private var busArrivalResponses = BusArrivalInfo(metadata: "", busStopCode: "", services: [])
    @State private var busTimings = "not yet retrieved from api"
    @State private var busServices = ["20"] //["9", "10"]
    
    // BusStop
    @State private var busStopResponses = BusStopInfo(metadata: "", busStops: [])
    @State private var urls = [
        "http://datamall2.mytransport.sg/ltaodataservice/BusStops",
        "http://datamall2.mytransport.sg/ltaodataservice/BusStops?$skip=500",
        "http://datamall2.mytransport.sg/ltaodataservice/BusStops?$skip=1000",
        "http://datamall2.mytransport.sg/ltaodataservice/BusStops?$skip=1500",
        "http://datamall2.mytransport.sg/ltaodataservice/BusStops?$skip=2000",
        "http://datamall2.mytransport.sg/ltaodataservice/BusStops?$skip=2500",
        "http://datamall2.mytransport.sg/ltaodataservice/BusStops?$skip=3000",
        "http://datamall2.mytransport.sg/ltaodataservice/BusStops?$skip=3500",
        "http://datamall2.mytransport.sg/ltaodataservice/BusStops?$skip=4000",
        "http://datamall2.mytransport.sg/ltaodataservice/BusStops?$skip=4500",
        "http://datamall2.mytransport.sg/ltaodataservice/BusStops?$skip=5000"
    ]
    @State private var busStops: [BusStop] = []
    @State private var busStopCode = "not yet retrieved from api"
    
    // Timer
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
//        Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
//            .ignoresSafeArea()
//            .accentColor(Color(.systemPink))
//            .onAppear {
//                viewModel.checkIfLocationServicesIsEnabled()
//            }
        
        
//        // GPS
//        Button("Retrieve coordinates!") {
//            viewModel.checkIfLocationServicesIsEnabled()
//            coordinates = viewModel.retrieveUserLocation()
//            currentLat = coordinates.latitude
//            currentLong = coordinates.longitude
//        }
//        .onAppear {
//            viewModel.checkIfLocationServicesIsEnabled()
//        }
//
//        Text("Latitude: \(coordinates.latitude)")
//        Text("Longitude: \(coordinates.longitude)")
        
        ZStack {
            // background
            Color(red: 130/255, green: 124/255, blue: 223/255, opacity: 1.0)
                .ignoresSafeArea()
            
            // app contents
            VStack {
                Spacer()
                
                // Bus Stop
                Button {
                    
                    
                    
                    self.busStopCode = BusStopApi().calculateNearestBusStop(busStops: self.busStops, currentLocationLat: currentLat, currentLocationLong: currentLong)
                    
                    
                    texttoaudio.verifybusstopbutton = true
                                    
                    texttoaudio.canSpeak.sayThis("Based on your current location, you are currently at \(self.busStopCode)")
                                    
                    print("done speaking")
                    
                } label: {
                    VStack {
                        Image(systemName: "mappin.and.ellipse")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .padding(20)
                            .foregroundColor(Color(red: 219/255, green: 213/255, blue: 244/255, opacity: 1.0))
                        Text("VERIFY\nBUS STOP")
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 36))
                            .foregroundColor(Color(red: 219/255, green: 213/255, blue: 244/255, opacity: 1.0))
                    }
                    .padding([.leading, .trailing], 80)
                    .padding([.top, .bottom], 70)
                    .background(Color(red: 49/255, green: 46/255, blue: 76/255, opacity: 1.0))
                    
                }
                .cornerRadius(10)
                .shadow(radius: 20)
                .onAppear {
                    // GPS
                    viewModel.checkIfLocationServicesIsEnabled()
                    coordinates = viewModel.retrieveUserLocation()
                    currentLat = coordinates.latitude
                    currentLong = coordinates.longitude
                    
                    // Load ALL bus stops API
                    for url in urls {
                        BusStopApi().loadData(urlString: url) { item in
                            self.busStopResponses = item
                            self.busStops += item.busStops
                        }
                    }
                }
        //        Text("Nearest bus stop is: \(busStopCode)")
                
                Spacer()
                
                // Bus Service
                Button {
                    
                    DispatchQueue.main.async {
                        
                        texttoaudio.canSpeak.sayThis("What bus number are you waiting for")
                        
                        BusArrivalApi().loadData(busStopCode: self.busStopCode, busServices: self.texttoaudio.busservices) { item in
            //                self.busArrivalResponses = item
            //                self.busSvcNum = item.services[0].svcNum
                            
                            self.busTimings = ""
                            print(item)
                            
                            for svc in self.texttoaudio.busservices {
                                self.busTimings += "Bus \(svc) is coming in \(item[svc] ?? "NIL") minutes..\n"
                            }
                        }
                        
                    }
                    
                   
                } label: {
                    VStack {
                        Image(systemName: "clock.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .padding(20)
                            .foregroundColor(Color(red: 219/255, green: 213/255, blue: 244/255, opacity: 1.0))
                        Text("VERIFY\nBUS TIME")
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 36))
                            .foregroundColor(Color(red: 219/255, green: 213/255, blue: 244/255, opacity: 1.0))
                    }
                    .padding([.leading, .trailing], 86)
                    .padding([.top, .bottom], 70)
                    .background(Color(red: 49/255, green: 46/255, blue: 76/255, opacity: 1.0))
                    
                }
                .cornerRadius(10)
                .shadow(radius: 20)
                .onReceive(timer) { input in
                    BusArrivalApi().loadData(busStopCode: self.busStopCode, busServices: self.texttoaudio.busservices) { item in
        //                self.busArrivalResponses = item
        //                self.busSvcNum = item.services[0].svcNum
                        
                        self.busTimings = ""
                        print(item)
                        
                        for svc in self.texttoaudio.busservices {
                            self.busTimings += "Bus \(svc) is coming in \(item[svc] ?? "NIL") minutes..\n"
                        }
                    }
                }
    //            Text(self.busTimings)
                
                Spacer()
            }
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
