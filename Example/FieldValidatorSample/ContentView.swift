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
 
    @Published var username:String = "" // observable property
    @Published var password:String = "" // observable property
 
}

struct ContentView : View {

    
    var body: some View {
        
        NavigationView {
        TabView {
             FormWithValidatorV1()
                 .environmentObject( DataItem() )
                 .tabItem {
                     Label("Form validator", systemImage: "square.and.pencil")
                 }
         }
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
