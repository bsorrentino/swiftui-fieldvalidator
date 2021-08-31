//
//  FormWithValidator2.swift
//  FieldValidatorSample
//
//  Created by Bartolomeo Sorrentino on 29/08/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//
import SwiftUI
import Combine

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


struct FormWithValidatorV2 : View {
    
    struct PasswordToggleField : View {
        @Binding var value:String
        @Binding var hidden:Bool
        
        var body: some View {
            Group {
                if( hidden ) {
                    SecureField( "give me the password", text:$value)
                }
                else {
                    TextField( "give me the password", text:$value)
                }
            }
        }
    }

    @EnvironmentObject var item:DataItem // data model reference

    @StateObject var usernameValid = FieldChecker2<String>() // validation state of username field
    @StateObject var passwordValid = FieldChecker2<String>() // validation state of password field
    @State var passwordHidden = true
        
    /**
        
     */
    
    func username() -> some View {

        TextField( "give me the email",
                   text: $item.username.onValidate(checker: usernameValid) { v in
                        // validation closure where ‘v’ is the current value
                        if( v.isEmpty ) {
                            return "email cannot be empty"
                        }
                        if( !v.isEmail() ) {
                            return "email is not in correct format"
                        }
                        return nil
                   }, onCommit: submit)
                .autocapitalization(.none)
                .padding( .bottom, 25 )
                .modifier( ValidatorMessageModifier(message: usernameValid.errorMessage))

    }
    
    func passwordToggle() -> some View  {
        
        HStack {
            PasswordToggleField( value:$item.password.onValidate( checker: passwordValid ) { v in
                    if( v.isEmpty ) {
                        return "password cannot be empty"
                    }
                    return nil
                }, hidden:$passwordHidden )
            .autocapitalization(.none)
            .padding( .bottom, 25  )
            
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
            
        }.modifier( ValidatorMessageModifier(message: usernameValid.errorMessage))
        
        
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
            
            Section(header: Text("Credentials")) {
                username()
                passwordToggle()
            } // end of section
            
            Section {
                
                HStack {
                    Spacer()
                    Button( "Submit", action: submit )
                    // enable button only if username and password are validb
                    .disabled( !self.isValid )
                    Spacer()

                }
            } // end of section
            
        } // end of form
       .navigationBarTitle( Text( "Sample Form" ), displayMode: .inline  )
        } // NavigationView
    }
}

#if DEBUG
struct FormVithValidatorV2_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FormWithValidatorV1()
                .environment(\.colorScheme, .light)
                .environmentObject( DataItem() )
            FormWithValidatorV1()
                .environment(\.colorScheme, .dark)
                .environmentObject( DataItem() )
         }

        
    }
}
#endif
