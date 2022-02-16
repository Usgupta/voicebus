//
//  ContentView.swift
//  Voicebus
//
//  Created by prispearls on 12/2/22.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
       
        VStack {
       
            NavigationView {
                NavigationLink(destination: SpeechView()) { HStack {
                    Image("gps")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        VStack {
                            Text("VERIFY BUS STOP")
                                .foregroundColor(Color.purple)
                        }.multilineTextAlignment(.leading)
                        .font(.system(size: 30)).padding()
                    }
                }
            }
            .padding([.leading, .bottom, .trailing])
            
            NavigationView {
                NavigationLink(destination: SpeechView()) { HStack {
                    Image("clock")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        VStack {
                            Text("VERIFY BUS TIME")
                                .foregroundColor(Color.purple)
                        }.multilineTextAlignment(.leading)
                        .font(.system(size: 30)).padding()
                    }
                }
            }
            .padding([.leading, .bottom, .trailing])
        
            Spacer()
            Image("voicebus_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 130.0, height: 130.0)
                
                
            }
        }
    }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
