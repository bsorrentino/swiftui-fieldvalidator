//
//  FormWithValidator2.swift
//  FieldValidatorSample
//
//  Created by Bartolomeo Sorrentino on 29/08/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import SwiftUI
import Combine


struct PasswordToggleFieldV2 : View {
    @Binding var value:String
    var hidden:Bool

    var body: some View {
        if( hidden ) {
            SecureField( "give me the password", text: $value)
        }
        else {
            TextField( "give me the password", text: $value)
        }
    }
}

func usernameValididator( _ v:String ) -> String? {
    // validation closure where ‘v’ is the current value
                              
       if( v.isEmpty ) {
           return "email cannot be empty"
       }
       if( !v.isEmail() ) {
           return "email is not in correct format"
       }

       return nil
}

func passwordValididator( _ v:String ) -> String? {
    // validation closure where ‘v’ is the current value
                              
    if( v.isEmpty ) {
        return "password cannot be empty"
    }
    return nil
}

struct FormWithValidatorV2 : View {
    @EnvironmentObject var item:DataItem// data model reference
    
    @StateObject var username = FieldValidatorX<String>( debounceInMills: 700, validator: usernameValididator )
    @StateObject var password = FieldValidatorX<String>( validator: passwordValididator)
    @State var passwordHidden = true
      
    
    func usernameView() -> some View {

        TextField( "give me the email",
                   text: $item.username,
                   onCommit: submit)
            .autocapitalization(.none)
            .padding( .bottom, 25 )
            .overlay( ValidatorMessageInline( message: username.errorMessageOrNilAtBeginning ), alignment: .bottom)

    }
    
    func passwordToggleView() -> some View  {
        
        HStack {
            PasswordToggleFieldV2( value:$item.password, hidden:passwordHidden )
            .autocapitalization(.none)
            .padding( .bottom, 25  )
            .overlay( ValidatorMessageInline( message: password.errorMessage/*OrNilAtBeginning*/ ),alignment: .bottom)

            Button( action: { self.passwordHidden.toggle() }) {
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
        password.valid && username.valid
    }
    
    func submit() {
        if( isValid ) {
            print( "\nusername:\(item.username)\npassword:\(item.password)")
        }
    }
    
    var body: some View {
        
        NavigationView {
        Form {
            
            Section(header: Text("Credentials")) {
                
                usernameView()
                
                passwordToggleView()
                
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
       .navigationBarTitle( Text( "Sample Form" ), displayMode: .inline  )
        .onAppear {
            username.bind(to: item.$username )
            password.bind(to: item.$password )
        }
        } // NavigationView
    }
}




struct FormWithValidator2_Previews: PreviewProvider {
    static var previews: some View {
        FormWithValidatorV2()
    }
}
