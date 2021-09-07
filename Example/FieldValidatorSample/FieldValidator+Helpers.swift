//
//  FieldValidator+Overlay.swift
//  FieldValidatorSample
//
//  Created by Bartolomeo Sorrentino on 17/08/20.
//  Copyright © 2020 bsorrentino. All rights reserved.
//

import SwiftUI

struct ValidatorMessageModifier: ViewModifier {
    
    var message:String?
    
    var msg: some View {
        HStack {
            Text( message ?? "")
            .fontWeight(.light)
            .font(.footnote)
            .foregroundColor(Color.red)
            
            if message != nil  {
                Image( systemName: "exclamationmark.triangle")
                    .foregroundColor(Color.red)
                    .font(.footnote)
            }
        }
    }

    func body(content: Content) -> some View {
        return content.overlay( msg, alignment: .bottom )
    }
}


