//
//  ContentView.swift
//  FieldValidator
//
//  Created by softphone on 15/10/2019.
//  Copyright © 2019 bsorrentino. All rights reserved.
//

import SwiftUI
import Combine

class DataItem: ObservableObject { // observable object
 
    @Published var username:String = "test" // observable property
    @Published var password:String = "" // observable property
 
}

struct ContentView : View {

    
    var body: some View {
        
        NavigationView {
        TabView {
            FormWithValidatorV2()
                 .tabItem {
                     Label("Form validator v2", systemImage: "list.dash")
                 }

             FormWithValidatorV1()
                 .tabItem {
                     Label("Form validator v1", systemImage: "square.and.pencil")
                 }
        }
        .environmentObject( DataItem() )
        .navigationBarTitle( Text( "FieldValidator Samples" ), displayMode: .inline  )
        } // NavigationView
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        
    }
}
#endif
