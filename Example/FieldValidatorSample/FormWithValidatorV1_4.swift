//
//  ContentView.swift
//  FieldValidator
//
//  Created by softphone on 15/10/2019.
//  Copyright © 2019 bsorrentino. All rights reserved.
//

import SwiftUI
import Combine

struct FormWithValidatorV1_4 : View {

    @EnvironmentObject var item:DataItem // data model reference

    @State var usernameValid = FieldChecker() // validation state of username field
    @State var passwordValid = FieldChecker() // validation state of password field
    
    @State var passwordToggleValid = FieldChecker() // validation state of password field
    @State var passwordHidden = true
        
    func username() -> some View {

        TextFieldWithValidator( title: "give me the email",
                                value: $item.username,
                                checker: $usernameValid,
                                onCommit: submit) { v in
                         // validation closure where ‘v’ is the current value
                                                   
                            if( v.isEmpty ) {
                                return "email cannot be empty"
                            }
                            if( !v.isEmail() ) {
                                return "email is not in correct format"
                            }

                            return nil
                    }
                    .autocapitalization(.none)
                    .padding( .bottom, 25 )
                    .modifier( ValidatorMessageModifier(message: usernameValid.errorMessageOrNilAtBeginning ) )
                                
    }
    
    func passwordToggle() -> some View  {
        
        HStack {
            PasswordToggleField( value:$item.password,
                                 checker:$passwordToggleValid,
                                 hidden:$passwordHidden ) { v in
                                    if( v.isEmpty ) {
                                        return "password cannot be empty"
                                    }
                                    return nil
            }
            .autocapitalization(.none)
            .padding( .bottom, 25  )
            .modifier( ValidatorMessageModifier(message: passwordToggleValid.errorMessage ) )
            Button( action: {
                self.passwordHidden.toggle()
            }) {
                Group {
                    if( passwordHidden ) {
                        Image( systemName: "eye.slash")
                    }
                    else {
                        Image( systemName: "eye")
                    }
                }
                .foregroundColor(Color.black)
            }
            
        }
        
        
    }
    
    var isValid:Bool {
        passwordToggleValid.valid && usernameValid.valid
    }
    
    func submit() {
        if( isValid ) {
            print( "submit:\nusername:\(self.item.username)\npassword:\(self.item.password)")
        }
    }
    
    var body: some View {
        
        NavigationView {
        Form {
            
            Section(header: Text("Credentials")) {
                
                username()
                
                passwordToggle()
                
            } // end of section
            
            Section {
                
                HStack {
                    Spacer()
                    Button( "Submit" ) {
                        
                        self.submit()
                    }
                    // enable button only if username and password are validb
                    .disabled( !self.isValid )
                    Spacer()

                }
            } // end of section
            
        } // end of form
       .navigationBarTitle( Text( "Validation 1.4 Sample" ), displayMode: .inline  )
        } // NavigationView
    }
}

#if DEBUG
struct FormVithValidatorV1_4_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FormWithValidatorV1_4()
                .environment(\.colorScheme, .light)
                .environmentObject( DataItem() )
            FormWithValidatorV1_4()
                .environment(\.colorScheme, .dark)
                .environmentObject( DataItem() )
         }

        
    }
}
#endif
