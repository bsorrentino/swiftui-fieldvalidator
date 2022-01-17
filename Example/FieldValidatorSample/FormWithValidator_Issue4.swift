//
//  FormWithValidator2.swift
//  FieldValidatorSample
//
//  Created by Bartolomeo Sorrentino on 29/08/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//
import SwiftUI
import Combine

public class FieldChecker3<T : Hashable> : FieldChecker2<T> {

    public private(set) var validator:(T) -> String?

    public init( errorMessage:String? = nil, validator:@escaping(T) -> String? ) {
        self.validator = validator
        super.init( errorMessage: errorMessage )
    }

}

extension FormWithValidator_Issue4 {
    
    class ViewModel: NSObject, ObservableObject {
        
        @Published var username:String = "" // observable property
        @Published var password:String = "" // observable property

        // validation state of username field
        @NestedObservableObject var usernameValid = FieldChecker3<String>() { v in
            // validation closure where ‘v’ is the current value
            if( v.isEmpty ) {
                return "value cannot be empty"
            }
            return nil
        }
        
        @NestedObservableObject var passwordValid = FieldChecker2<String>()
        
        /*
        // @ref https://stackoverflow.com/a/58406402/521197
        private var cancellableSet: Set<AnyCancellable> = []
        
        override init() {
            super.init()
            usernameValid.objectWillChange.sink { [weak self] in
                self?.objectWillChange.send()
            }.store(in: &cancellableSet)
            passwordValid.objectWillChange.sink { [weak self] in
                self?.objectWillChange.send()
            }.store(in: &cancellableSet)
        }
        */
    }
}

struct FormWithValidator_Issue4 : View {
 
    @StateObject var viewModel = ViewModel()
    
    func username() -> some View {

        TextField( "give me the email",
                   text: $viewModel.username.onValidate(checker: viewModel.usernameValid,
                                                        debounceInMills: 500,
                                                        validator:viewModel.usernameValid.validator),
                   onCommit: submit)
                .autocapitalization(.none)
                .padding( .bottom, 25 )
                .modifier( ValidatorMessageModifier(message: viewModel.usernameValid.errorMessage))
    }
    
    func passwordToggle() -> some View  {
        
        HStack {
            SecureField( "give me the password",
                         text: $viewModel.password.onValidate( checker: viewModel.passwordValid ) { v in
                            if( v.isEmpty ) {
                                return "password cannot be empty \(viewModel.username)"
                            }
                            return nil
            })
            .autocapitalization(.none)
            .padding( .bottom, 25  )
                        
        }.modifier( ValidatorMessageModifier(message: viewModel.passwordValid.errorMessage))
        
    }
 
    var isValid:Bool {
        viewModel.passwordValid.valid && viewModel.usernameValid.valid
    }
    
    func submit() {
        if( isValid ) {
            print( "submit:\nusername:\(self.viewModel.username)\npassword:\(self.viewModel.password)")
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
       .navigationBarTitle( Text( "Validation 1.5 Sample" ), displayMode: .inline  )
        } // NavigationView
    }
}
