//
//  ContentView.swift
//  GPS_TEST
//
//  Created by Gerald on 18/2/22.
//

import SwiftUI
import MapKit

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
//    @State private var busTimings = "not yet retrieved from api .."
//    {
//        didSet {
//            let stringArr = self.busTimings.components(separatedBy: " ")
//            if stringArr.count > 5 {
//
//                print(self.busTimings)
//                print(stringArr)
//                switch(stringArr[4]) {
//
//                case "5", "3", "0": // 5min, 3min, 0min
//                    showPopup = true
//                default:
//                    // do nothing
//                    showPopup = false
//
//                }
//            }
//        }
//    }
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
//    @State private var busStopCode = "not yet retrieved from api"
    
    // Timer
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    @State var texttoaudio = TextToAudio()
    
    // Notification
    @State private var feedback = UINotificationFeedbackGenerator()
    @State private var showPopup: Bool = false
    @State private var selectedPicture = Int.random(in: 0...3) //accesiblilty
    
//
    
    
    fileprivate func verifyBusStopbuttonTapped() {
        //                    self.busStopCode = BusStopApi().calculateNearestBusStop(busStops: self.busStops, currentLocationLat: currentLat, currentLocationLong: currentLong)
        
        let replyMsg = BusStopApi().calculateNearestBusStop(busStops: self.busStops, currentLocationLat: currentLat, currentLocationLong: currentLong)
        var replyArr = replyMsg.components(separatedBy: " ")
        
        
        
        self.texttoaudio.busStopCode = replyArr[0]
        replyArr.remove(at: 0)
        let busStopName = replyArr.joined()
        
        
        
        texttoaudio.verifybusstopbutton = true
        
        texttoaudio.canSpeak.sayThis("Based on your current location, you are currently at \(busStopName)")
        
        print("done speaking")
        self.isShowingDetailView = true
        
        //                    // IF APP ACTIVE
        //                    feedback.prepare()
        //                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        //                        showPopup = true
        //                        feedback.notificationOccurred(.success)
        //                    }
        //                     // IF APP INACTIVE/ background
        //                     let content = UNMutableNotificationContent()
        //                     content.title = "Your Bus is Arriving!"
        //                     content.subtitle = self.busTimings
        //                     content.sound = UNNotificationSound.default //plays sound
        //                     feedback.notificationOccurred(.success) //vibrates buzz
        //                     // show this notification five seconds from now
        //                     let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        //                     // choose a random identifier
        //                     let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        //                     // add our notification request
        //                     UNUserNotificationCenter.current().add(request)
        
    }
    
    fileprivate func VerifyBusTimingTapped() {
        // remove this pls
        //                    self.texttoaudio.showPopup = true
        //
        
        DispatchQueue.main.async {
            //                        texttoaudio = TextToAudio()
            texttoaudio.canSpeak.sayThis(texttoaudio.TTSques["BusNo"]!)
        }
        
        
        BusArrivalApi().loadData(busStopCode: self.texttoaudio.busStopCode, busServices: self.texttoaudio.busservices) { item in
            //                self.busArrivalResponses = item
            //                self.busSvcNum = item.services[0].svcNum
            
            self.texttoaudio.busTimings = ""
            print(item)
            
            for svc in self.texttoaudio.busservices {
                self.texttoaudio.busTimings += "Bus \(svc) is coming in \(item[svc] ?? "NIL") minutes..\n"
            }
            
        }
    }
    
    fileprivate func BusTimingFromApi() {
        BusArrivalApi().loadData(busStopCode: self.texttoaudio.busStopCode, busServices: self.texttoaudio.busservices) { item in
            //                self.busArrivalResponses = item
            //                self.busSvcNum = item.services[0].svcNum
            
            self.texttoaudio.busTimings = ""
            print(item)
            
            for svc in self.texttoaudio.busservices {
                self.texttoaudio.busTimings += "Bus \(svc) is coming in \(item[svc] ?? "NIL") minutes..\n"
            }
            self.showPopup = true
        }
    }
    
    var body: some View {
//        NavigationView{
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
        
        if #available(iOS 15.0, *) {
            ZStack {
                // background
                Color(red: 130/255, green: 124/255, blue: 223/255, opacity: 1.0)
                    .ignoresSafeArea()
                
                // app contents
                VStack {
                    Spacer()
                    
                    // Bus Stop
                    //                NavigationLink(destination: DetailView(choice: "Heads"), isActive: $isShowingDetailView) {}
                    Button {
                        verifyBusStopbuttonTapped()
                        
                    } label: {
                        GeometryReader { geo in
                            HStack {
                                Spacer()
                                VStack {
                                    Spacer()
                                    Image(systemName: "mappin.and.ellipse")
                                        .resizable()
                                        .frame(width: geo.size.width*0.18, height: geo.size.width*0.18)
                                        .padding(.bottom, 10)
                                        .foregroundColor(Color(red: 219/255, green: 213/255, blue: 244/255, opacity: 1.0))
                                    Text("VERIFY\nBUS STOP")
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: geo.size.width*0.1))
                                        .foregroundColor(Color(red: 219/255, green: 213/255, blue: 244/255, opacity: 1.0))
                                    Spacer()
                                }
                                .frame(width: geo.size.width*0.9, height: geo.size.height*0.9)
                                .background(Color(red: 49/255, green: 46/255, blue: 76/255, opacity: 1.0))
                                .cornerRadius(10)
                                Spacer()
                            }
                            .position(x: geo.frame(in: .local).midX, y: geo.frame(in: .local).midY)
                        }
                        
                        
                    }
                    .accessibilityLabel("Press to check your nearest bus stop")
                    //POP UP IF APP ACTIVE
                    //                .popup(isPresented: $showPopup, with: $busTimings) { item in
                    //                    VStack(spacing: 20) {
                    //                        TextField("Name", text: self.$busTimings)
                    //                        Button {
                    //                            showPopup = false
                    //                        } label: {
                    //                            Text("Dismiss Popup")
                    //                        }
                    //                    }
                    //                    .frame(width: 300)
                    //                    .padding()
                    //                    .background(Color.gray)
                    //                    .cornerRadius(8)
                    //                }
                        .shadow(radius: 20)
                        .onAppear {
                            
                            
//                            texttoaudio = TextToAudio(showpopup: self.$showPopup)
                            
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
                    if (showPopup) {
                        Text(self.texttoaudio.busTimings)
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding()
                        Spacer()
                    }
                    
                    Text("wait a few seconds before speaking...") //self.texttoaudio.busservices
                        .fontWeight(.bold)
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 219/255, green: 213/255, blue: 244/255, opacity: 1.0))
                    
                    
                    
                    // Bus Service
                    Button {
                        
                        VerifyBusTimingTapped()
                        
                        
                    } label: {
                        GeometryReader { geo in
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
                                .frame(width: geo.size.width*0.9, height: geo.size.height*0.9)
                                .background(Color(red: 49/255, green: 46/255, blue: 76/255, opacity: 1.0))
                                .cornerRadius(10)
                                Spacer()
                            }
                            .position(x: geo.frame(in: .local).midX, y: geo.frame(in: .local).midY)
                        }
                    }.accessibilityLabel("Press to check the arrival timing of a Bus")
                        .shadow(radius: 20)
                        .onReceive(timer) { input in
                            BusTimingFromApi()
                        }
                    
                    //            Text(self.busTimings)
                    
                    //                Spacer()
                    //            }
                }
                
                // Pop up & slide in notification here
                //        Button("Schedule Notification") {
                //           // IF APP ACTIVE
                //           feedback.prepare()
                //           DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                //               showPopup = true
                //               feedback.notificationOccurred(.success)
                //           }
                //            // IF APP INACTIVE/ background
                //            let content = UNMutableNotificationContent()
                //            content.title = "Your Bus is Arriving!"
                //            content.subtitle = self.busTimings
                //            content.sound = UNNotificationSound.default //plays sound
                //            feedback.notificationOccurred(.success) //vibrates buzz
                //            // show this notification five seconds from now
                //            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
                //            // choose a random identifier
                //            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                //            // add our notification request
                //            UNUserNotificationCenter.current().add(request)
                //        }
                //POP UP IF APP ACTIVE
                //        .popup(isPresented: $showPopup, with: $busTimings) { item in
                //            VStack(spacing: 20) {
                //                TextField("Name", text: self.$busTimings)
                //                Button {
                //                    showPopup = false
                //                } label: {
                //                    Text("Dismiss Popup")
                //                }
                //            }
                //            .frame(width: 300)
                //            .padding()
                //            .background(Color.gray)
                //            .cornerRadius(8)
                //        }
                
                Spacer()
                
            }
            //POP UP IF APP ACTIVE
//            .popup(isPresented: self.$showPopup, with: self.$texttoaudio.busTimings) { item in
//                VStack(spacing: 20) {
//                    Text(self.texttoaudio.busTimings)
//                    //                TextField("Name", text: self.$busTimings)
//                    Button {
//                        self.showPopup = false
//                    } label: {
//                        Text("Dismiss Popup")
//                    }
//                }
//                .frame(width: 300)
//                .padding()
//                .background(Color.gray)
//                .cornerRadius(8)
//            }
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
