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

    // GPS
    @StateObject private var viewModel = ContentViewModel()
    @State private var coordinates = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    @State private var currentLat: Double = 0.0
    @State private var currentLong: Double = 0.0

    // BusArrival
    @State private var busArrivalResponses = BusArrivalInfo(metadata: "", busStopCode: "", services: [])
    @State private var busTimings = "not yet retrieved from api"
    @State private var busServices = ["315"] //["9", "10"]

    // BusStop
    @State private var busStopResponses = BusStopInfo(metadata: "", busStops: [])
    @State private var busStopNearest = "retrieving..."
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
    
    // Notification
    @State private var feedback = UINotificationFeedbackGenerator()
    @State private var showPopup: Bool = false
    @State private var selectedPicture = Int.random(in: 0...3) //accesiblilty

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

        Spacer()

        // Bus Stop
        VStack {
            Button("Check Bus Stop") {
                self.busStopCode = BusStopApi().calculateNearestBusStop(busStops: self.busStops, currentLocationLat: currentLat, currentLocationLong: currentLong)
                self.busStopNearest = "Nearest bus stop is: \(busStopCode)"

            }
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
            Text(self.busStopNearest)
        }

        Spacer()

        // Bus Service
        VStack {
            Button("Check Bus Time") {
                BusArrivalApi().loadData(busStopCode: self.busStopCode, busServices: self.busServices) { item in
    //                self.busArrivalResponses = item
    //                self.busSvcNum = item.services[0].svcNum

                    self.busTimings = ""
                    print(item)

                    for svc in self.busServices {
                        self.busTimings += "Bus \(svc) is coming in \(item[svc] ?? "NIL") minutes..\n"
                    }
                }
            }
            .onReceive(timer) { input in
                BusArrivalApi().loadData(busStopCode: self.busStopCode, busServices: self.busServices) { item in
    //                self.busArrivalResponses = item
    //                self.busSvcNum = item.services[0].svcNum

                    self.busTimings = ""
                    print(item)

                    for svc in self.busServices {
                        self.busTimings += "Bus \(svc) is coming in \(item[svc] ?? "NIL") minutes..\n"
                    }
                }
            }
            Text(self.busTimings)
        }

        Spacer()
        
        // Testing Accessibility Labels
        let labels = ["Request Permission", "chicken"]
        Button("Request Permission") {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    print("All set!")
                    feedback.prepare()
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
        }.onTapGesture{selectedPicture = 1}
        .accessibilityLabel(labels[selectedPicture] )
        .accessibilityAddTraits(.isButton)
        Spacer()

        // Pop up & slide in notification here
        Button("Schedule Notification") {
           // IF APP ACTIVE
           feedback.prepare()
           DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
               showPopup = true
               feedback.notificationOccurred(.success)
           }
            // IF APP INACTIVE/ background
            let content = UNMutableNotificationContent()
            content.title = "Your Bus is Arriving!"
            content.subtitle = self.busTimings
            content.sound = UNNotificationSound.default //plays sound
            feedback.notificationOccurred(.success) //vibrates buzz
            // show this notification five seconds from now
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
            // choose a random identifier
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            // add our notification request
            UNUserNotificationCenter.current().add(request)
        }
        //POP UP IF APP ACTIVE
        .popup(isPresented: $showPopup, with: $busTimings) { item in
            VStack(spacing: 20) {
                TextField("Name", text: self.$busTimings)
                Button {
                    showPopup = false
                } label: {
                    Text("Dismiss Popup")
                }
            }
            .frame(width: 300)
            .padding()
            .background(Color.gray)
            .cornerRadius(8)
        }
        Spacer()
    }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

}
