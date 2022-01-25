//
//  Button.swift
//  Speech to Text
//
//  Created by Joel Joseph on 3/22/20.
//  Copyright © 2020 Joel Joseph. All rights reserved.
//

import Speech
import SwiftUI
import Foundation

struct SpeechButton: View {
    
    @State var isPressed:Bool = false
    @State var actionPop:Bool = false
    
//A property wrapper type that can read and write a value managed by SwiftUI.
//    SwiftUI manages the storage of any property you declare as a state. When the state value changes, the view invalidates its appearance and recomputes the body. Use the state as the single source of truth for a given view.
//
//    A State instance isn’t the value itself; it’s a means of reading and writing the value. To access a state’s underlying value, use its variable name, which returns the wrappedValue property value.
    
    @EnvironmentObject var swiftUISpeech:SwiftUISpeech
    
//    An environment object invalidates the current view whenever the observable object changes. If you declare a property as an environment object, be sure to set a corresponding model object on an ancestor view by calling its environmentObject(_:) modifier.
    
    var body: some View {
        
        Button(action:{// Button
            if(self.swiftUISpeech.getSpeechStatus() == "Denied - Close the App"){// checks status of auth if no auth pop up error
                self.actionPop.toggle()
            }else{
                withAnimation(.spring(response: 0.4, dampingFraction: 0.3, blendDuration: 0.3)){self.swiftUISpeech.isRecording.toggle()}// button animation
                self.swiftUISpeech.isRecording ? self.swiftUISpeech.startRecording() : self.swiftUISpeech.stopRecording()
            }
        }){
            Image(systemName: "waveform")// Button Image
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.white)
                .background(swiftUISpeech.isRecording ? Circle().foregroundColor(.red).frame(width: 85, height: 85) : Circle().foregroundColor(.blue).frame(width: 70, height: 70))
        }.actionSheet(isPresented: $actionPop){
            ActionSheet(title: Text("ERROR: - 1"), message: Text("Access Denied by User"), buttons: [ActionSheet.Button.destructive(Text("Reinstall the Appp"))])// Error catch if the auth failed or denied reinstall the app to run again (maybe)
        }
    }
}

struct Button_Previews: PreviewProvider {
    static var previews: some View {
        SpeechButton().environmentObject(SwiftUISpeech())
    }
}
