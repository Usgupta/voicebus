//
//  aSwiftUIView.swift
//  GPS_TEST
//
//  Created by prispearls on 5/4/22.
//

import SwiftUI

struct DetailView: View {
    var choice: String // receive data from contentView
    
    var body: some View {
        Text("You chose \(choice)") // receive data from contentView
    }
}

struct DetailView_Previews: PreviewProvider {
    
    static let choice = "chicken"
    static var previews: some View {
        DetailView(choice: choice)
    }
}
