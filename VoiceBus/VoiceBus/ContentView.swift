//
//  ContentView.swift
//  GPS_TEST
//
//  Created by Gerald on 18/2/22.
//

import SwiftUI
import MapKit
import UserNotifications

//pop up here
struct Popup<D, V: View>: ViewModifier {
    let popup: (Binding<D>) -> V
    let isPresented: Binding<Bool>
    let data: Binding<D>

    init(isPresented: Binding<Bool>, with data: Binding<D>, @ViewBuilder content: @escaping (Binding<D>) -> V) {
        self.isPresented = isPresented
        popup = content
        self.data = data
    }

    func body(content: Content) -> some View {
        content
            .overlay(popupContent())
    }

    @ViewBuilder private func popupContent() -> some View {
        GeometryReader { geometry in
            if isPresented.wrappedValue {
                popup(data)
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

extension View {
    func popup<D, V: View>(isPresented: Binding<Bool>, with data: Binding<D>, @ViewBuilder content: @escaping (Binding<D>) -> V) -> some View {
        self.modifier(Popup(isPresented: isPresented, with: data, content: content))
    }
}


struct ContentView: View {
    
    @State private var isShowingDetailView = false
    @State private var isRecording = false
    
    // GPS
    @StateObject private var viewModel = ContentViewModel()
    @State private var coordinates = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    @State private var currentLat: Double = 0.0
    @State private var currentLong: Double = 0.0
    
    
    // BusArrival
    @State private var busArrivalResponses = BusArrivalInfo(metadata: "", busStopCode: "", services: [])
    @State private var busServices = ["20"]
    
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
//    @State private var busStopCode = "not yet retrieved from api"
    
    // Timer
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    
    // Bus Information
    @State private var busNumber = "Bus"
    @State private var busTiming = "Mins"
    @State private var lastTap : Date = Date(timeIntervalSince1970:0)
    
    @State var texttoaudio = TextToAudio()
    
    // Notification
    @State private var feedback = UINotificationFeedbackGenerator()
    @State private var showPopup: Bool = false
    @State private var selectedPicture = Int.random(in: 0...3) //accesiblilty
    
    
    fileprivate func getNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("All set!")
            } else if let error = error {
                print(error.localizedDescription)
                
            }
        }
    }
    
    var verifyBusStopbuttonTapped: Void {
                
        let replyMsg = BusStopApi().calculateNearestBusStop(busStops: self.busStops, currentLocationLat: currentLat, currentLocationLong: currentLong)
        var replyArr = replyMsg.components(separatedBy: " ")
        
        print(replyArr)
        
        self.texttoaudio.busStopCode = replyArr[0]
        replyArr.remove(at: 0)
        let busStopName = replyArr.joined()
        self.texttoaudio.busStopName = busStopName
         
        getNotificationPermission()
        
 
    }
 
    fileprivate func VerifyBusTimingTapped(){
        
        print("before \(lastTap)")

        // Checks if it has been tapped in the last two seconds

        if (Date().timeIntervalSince(lastTap) < 2) {

            return

        }
        
        lastTap = Date()
        print("after \(lastTap)")

        
        DispatchQueue.main.async {
            texttoaudio = TextToAudio()
            texttoaudio.verifybusStop = verifyBusStopbuttonTapped
            texttoaudio.canSpeak.sayThis(texttoaudio.TTSques)
        }
        
    }
    
    fileprivate func BusTimingFromApi() {
        BusArrivalApi().loadData(busStopCode: self.texttoaudio.busStopCode, busServices: self.texttoaudio.busservices) { item in
            
            self.texttoaudio.busTimings = ""
            print(item)
            
            for svc in self.texttoaudio.busservices {
                self.texttoaudio.busTimings += "Bus \(svc) is coming in \(item[svc] ?? "NIL") minutes..\n"
                
                self.busNumber = "Bus " + self.texttoaudio.busservices[0]
                self.busTiming = (item[self.texttoaudio.busservices[0]] ?? "NIL") + " Mins"
            }
            self.showPopup = true
 
        }

    }
    
    var body: some View {
 
        if #available(iOS 15.0, *) {
            ZStack {
                // background
                Color(red: 130/255, green: 124/255, blue: 223/255, opacity: 1.0)
                    .ignoresSafeArea()
                
                // app contents
                VStack {
                    GeometryReader { geo in
                        Spacer()
  
                        Button {
                            
                            VerifyBusTimingTapped()

                        } label: {
                            HStack {
                                Spacer()
                                VStack {
                                    Spacer()
                                    Image(systemName: "clock.fill")
                                        .resizable()
                                        .frame(width: geo.size.width*0.18, height: geo.size.width*0.18)
                                        .padding(.bottom, 10)
                                        .foregroundColor(Color(red: 219/255, green: 213/255, blue: 244/255, opacity: 1.0))
                                    Text("VERIFY\nBUS TIME")
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: geo.size.width*0.1))
                                        .foregroundColor(Color(red: 219/255, green: 213/255, blue: 244/255, opacity: 1.0))
                                    Spacer()
                                }
                                .frame(width: geo.size.width*0.9, height: geo.size.height*0.65)
                                .background(Color(red: 49/255, green: 46/255, blue: 76/255, opacity: 1.0))
                                .cornerRadius(10)
                                Spacer()
                            }
                        }
                        
                        .accessibility(addTraits: .startsMediaSession) // prevents voiceover to read the label on tapping the button to prevent clashing with the audio produced by the button
                        .shadow(radius: 20)
                        .onReceive(timer) { input in
                            BusTimingFromApi()
                        }
                        
                        Spacer()
                        
                        // Bus information
                        VStack {
                            VStack {
                                Image(systemName: "mappin.and.ellipse")
                                    .resizable()
                                    .frame(width: geo.size.width*0.16, height: geo.size.width*0.16)
                                    .foregroundColor(Color(red: 219/255, green: 213/255, blue: 244/255, opacity: 1.0))
                                    .accessibility(hidden: true)
                                    .padding(.top, 20)
                                
                                Text(self.texttoaudio.busStopName)
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                                    .multilineTextAlignment(.leading)
                                    .font(.system(size: geo.size.width*0.1))
                                    .minimumScaleFactor(0.01)
                                    .foregroundColor(Color(red: 219/255, green: 213/255, blue: 244/255, opacity: 1.0))
                                    .accessibility(hidden: true)
                                HStack {
                                    Spacer()
                                    Text(self.busNumber)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.leading)
                                        .font(.system(size: geo.size.width*0.06))
                                        .foregroundColor(Color(red: 219/255, green: 213/255, blue: 244/255, opacity: 1.0))
                                        .accessibility(hidden: true)
                                    Spacer()
                                    Text(self.busTiming)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.trailing)
                                    .font(.system(size: geo.size.width*0.06))
                                    .foregroundColor(Color(red: 219/255, green: 213/255, blue: 244/255, opacity: 1.0))
                                    .accessibility(hidden: true)
                                    Spacer()
                                }
                                .padding(.bottom, 20)
                            }
                            .frame(width: geo.size.width*0.9, height: geo.size.height*0.3)
                            .background(Color(red: 49/255, green: 46/255, blue: 76/255, opacity: 1.0))
                            .accessibilityLabel("bus information")
                            .cornerRadius(10)
                            .position(x: geo.frame(in: .local).midX, y: geo.frame(in: .local).midY*1.65)
                            .onReceive(timer) { time in
                                
                                // retrieve bus information every 10 seconds
                                verifyBusStopbuttonTapped
                            }
                            .onAppear() {
                                
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
                                
                                // retrieve bus information every 10 seconds
                                verifyBusStopbuttonTapped
                            }
                            .shadow(radius: 20)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(" \(self.busNumber) is arriving in \(self.busTiming)")
    //                }
                  
                        Spacer()
                        
                    }
                
                }
                
            }
 
        } else {
            // Fallback on earlier versions
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
