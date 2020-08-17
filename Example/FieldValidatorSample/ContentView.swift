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

enum PasswordType: Int, Hashable {
    
    case classic
    case toggle

    var text:String {
        switch( self ) {
            case .classic: return "classic"
            case .toggle: return "toggle"
        }
    }

}


struct FormWithValidator : View {

    @EnvironmentObject var item:DataItem // data model reference

    @State var usernameValid = FieldChecker() // validation state of username field
    @State var passwordValid = FieldChecker() // validation state of password field
    @State var passwordHidden = true
    @State var passwordType:PasswordType = .classic
    
   func passwordTypePicker() -> some View {
       
       Picker( selection: $passwordType, label: EmptyView() ) {
           Text(PasswordType.classic.text).tag(PasswordType.classic)
           Text(PasswordType.toggle.text).tag(PasswordType.toggle)
       }
       .pickerStyle(SegmentedPickerStyle())

   }
    
    func username() -> some View {
        VStack {
            TextFieldWithValidator( title: "username",
                                value: $item.username,
                                checker: $usernameValid,
                                onCommit: submit) { v in
                         // validation closure where ‘v’ is the current value
                                                   
                            if( v.isEmpty ) {
                                return "username cannot be empty"
                            }
                            
                            return nil
                    }
                    .autocapitalization(.none)
                    .padding( EdgeInsets(top:5, leading: 0, bottom: 25, trailing: 0) )
                    .overlay( ValidatorMessageInline( message: usernameValid.errorMessage )
                        ,alignment: .bottom)

        }

    }
    
    func passwordToggle() -> some View  {
        
        HStack {
            PasswordToggleField( value:$item.password,
                                 checker:$passwordValid,
                                 hidden:$passwordHidden ) { v in
                                    if( v.isEmpty ) {
                                        return "password cannot be empty"
                                    }
                                    return nil
            }
            .autocapitalization(.none)
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
        .padding( EdgeInsets(top:5, leading: 0, bottom: 25, trailing: 0) )
        .overlay( ValidatorMessageInline( message: passwordValid.errorMessage )
            ,alignment: .bottom)
        
        
 
    }
    
    func password() -> some View {
        
        SecureFieldWithValidator( title: "give me the password",
                                value: $item.password,
                                checker: $passwordValid,
                                onCommit: submit) { v in
                          // validation closure where ‘v’ is the current value
                             
                             if( v.isEmpty ) {
                                 return "password cannot be empty"
                             }
                             
                             return nil
                     }
                    .padding( EdgeInsets(top:5, leading: 0, bottom: 25, trailing: 0) )
                    .overlay( ValidatorMessageInline( message: passwordValid.errorMessage )
                        ,alignment: .bottom)

        

    }

    var isValid:Bool {
        passwordValid.valid && usernameValid.valid
    }
    
    func submit() {
        if( isValid ) {
            print( "submit:\nusername:\(self.item.username)\npassword:\(self.item.password)")
        }
    }
    
    var body: some View {
        
        NavigationView {
        Form {
            
            Section {
                
                username()
                
                if( self.passwordType == .classic  ) {
                    password()
                }
                else {
                    passwordToggle()
                }
                
            } // end of section
            
            Section {
                
                Button( "Submit" ) {
                    
                    self.submit()
                }
                    // enable button only if username and password are valid
                    .disabled( !self.isValid )
            } // end of section
            
        } // end of form
           .navigationBarTitle( Text( "Sample Form" ), displayMode: .inline  )
            .navigationBarItems(trailing: passwordTypePicker() )
        } // NavigationView
    }
}

#if DEBUG
struct FormVithValidator_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FormWithValidator()
                .environment(\.colorScheme, .light)
                .environmentObject( DataItem() )
            FormWithValidator()
                .environment(\.colorScheme, .dark)
                .environmentObject( DataItem() )
         }

        
    }
}
#endif
