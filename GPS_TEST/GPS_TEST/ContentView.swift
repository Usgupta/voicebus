//
//  ContentView.swift
//  GPS_TEST
//
//  Created by Gerald on 18/2/22.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    @StateObject private var viewModel = ContentViewModel()
    @State private var coordinates = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    var body: some View {
//        Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
//            .ignoresSafeArea()
//            .accentColor(Color(.systemPink))
//            .onAppear {
//                viewModel.checkIfLocationServicesIsEnabled()
//            }
        
        Button("Retrieve coordinates!") {
            viewModel.checkIfLocationServicesIsEnabled()
            coordinates = viewModel.retrieveUserLocation()
        }
        .onAppear {
            viewModel.checkIfLocationServicesIsEnabled()
        }
        
        Text("Latitude: \(coordinates.latitude)")
        Text("Longitude: \(coordinates.longitude)")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
