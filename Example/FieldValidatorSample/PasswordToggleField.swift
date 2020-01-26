//
//  ContentView+Password.swift
//  FieldValidatorSample
//
//  Created by Bartolomeo Sorrentino on 26/01/2020.
//  Copyright © 2020 bsorrentino. All rights reserved.
//

import SwiftUI
import Combine


struct PasswordToggleField : View {
    typealias Validator = (String) -> String?
    
    @Binding var hidden:Bool
    
    @ObservedObject var field:FieldValidator<String>
    
    init( value:Binding<String>, checker:Binding<FieldChecker>, hidden:Binding<Bool>, validator:@escaping Validator ) {
        self.field = FieldValidator(value, checker:checker, validator:validator )
        self._hidden = hidden
    }

    var body: some View {
        
        VStack {
            Group {
                if( hidden ) {
                    SecureField( "give me the password", text:$field.value)
                }
                else {
                    TextField( "give me the password", text:$field.value)
                }
            }
        }
        .onAppear {
            self.field.doValidate()
        }

    }
}

