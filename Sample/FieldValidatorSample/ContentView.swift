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



struct FormWithValidator : View {

    @EnvironmentObject var item:DataItem // data model reference

    @State var usernameValid = FieldChecker() // validation state of username field
    @State var passwordValid = FieldChecker() // validation state of password field

    func username() -> some View {
        VStack {
            TextFieldWithValidator( title:"username",
                                value: $item.username, checker:$usernameValid ) { v in
                         // validation closure where ‘v’ is the current value
                                                   
                            if( v.isEmpty ) {
                                return "username cannot be empty"
                            }
                            
                            return nil
                    }
                    .padding(.all)
                    .border( usernameValid.valid ? Color.clear : Color.red )
                    .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0))
                    .autocapitalization(.none)
            if( !usernameValid.valid  ) {
                Text( usernameValid.errorMessage ?? "" )
                    .fontWeight(.light)
                    .font(.footnote)
                    .foregroundColor(Color.red)

            }

        }

    }
    
    func password() -> some View {
        VStack {
            SecureFieldWithValidator( title:"password",
                                    value: $item.password, checker:$passwordValid ) { v in
                              // validation closure where ‘v’ is the current value
                                 
                                 if( v.isEmpty ) {
                                     return "password cannot be empty"
                                 }
                                 
                                 return nil
                         }
                        .padding(.all)
                        .border( passwordValid.valid ? Color.clear : Color.red )
                        .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0))
                        .autocapitalization(.none)
            if( !passwordValid.valid  ) {
                Text( passwordValid.errorMessage ?? "" )
                    .fontWeight(.light)
                    .font(.footnote)
                    .foregroundColor(Color.red)

            }

        }

    }

var body: some View {
  
  Form {


   Section {

        username()
        password()

   } // end of section

   Section {

    Button( "Submit" ) {
    }
    // enable button only if username and password are valid
   .disabled( !(passwordValid.valid && usernameValid.valid) )
   } // end of section

  } // end of form
 }
}

#if DEBUG
struct FormVithValidator_Previews: PreviewProvider {
    static var previews: some View {
        FormWithValidator()
            .environmentObject( DataItem() )
    }
}
#endif
