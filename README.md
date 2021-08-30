## Field Validator Library for SwiftUI

[![Badge w/ Version](https://cocoapod-badges.herokuapp.com/v/FieldValidatorLibrary/badge.png)](https://cocoadocs.org/docsets/FieldValidatorLibrary)
[![Badge w/ Platform](https://cocoapod-badges.herokuapp.com/p/FieldValidatorLibrary/badge.svg)](https://cocoadocs.org/docsets/FieldValidatorLibrary)

[SwiftUI](https://developer.apple.com/documentation/swiftui) [Package](https://swift.org/package-manager/) supporting "Form Validation"

Take a look to [Build field validator for SwiftUI](https://soulsoftware-bsc.blogspot.com/2019/10/build-field-validator-for-swiftui.html) and in folder [Example](Example) for a reference implementation

## Import library

### Swift Package Manager

This Library is compatible with [Swift Package Manager](https://swift.org/package-manager/)

### Cocoapods

This Library is compatible with [Cocoapods](https://cocoapods.org).

In your **Podfile** add
```
pod 'FieldValidatorLibrary', '~> 2.0.0'
```

## Sample

### Version 2

```swift

// validation closure where ‘v’ is the current value
func usernameValididator( _ v:String ) -> String? {
     if( v.isEmpty ) {
         return "email cannot be empty"
     }
     if( !v.isEmail() ) {
         return "email is not in correct format"
     }

     return nil
}

// validation closure where ‘v’ is the current value
func passwordValididator( _ v:String ) -> String? {
    if( v.isEmpty ) {
        return "password cannot be empty"
    }
    return nil
}

struct FormWithValidatorV2 : View {
    @EnvironmentObject var item:DataItem// data model reference

    @StateObject var username = FieldValidator2( "", debounceInMills: 700, validator: usernameValididator )
    @StateObject var password = FieldValidator2( "", validator: passwordValididator)

    func usernameView() -> some View {
        TextField( "give me the email",
                   text: $username.value,
                   onCommit: submit)
        .autocapitalization(.none)
        .padding( .bottom, 25 )
        .overlay( ValidatorMessageInline( message: username.errorMessageOrNilAtBeginning ), alignment: .bottom)
        .onAppear {
            username.doValidate()
        }
        .onChange(of: username.value) {
            item.username = $0
        }
    }

    func passwordToggleView() -> some View  {
        SecureField( "give me the password", text: $password.value )
        .autocapitalization(.none)
        .padding( .bottom, 25  )
        .overlay( ValidatorMessageInline( message: password.errorMessage ),alignment: .bottom)
        .onAppear {
            password.doValidate()
        }
        .onChange(of: password.value) {
            item.password = $0
        }
    }

    var isValid:Bool {
        password.valid && username.valid
    }

    func submit() {
        if( isValid ) {
            print( "submit:\nusername:\(self.username.value)\npassword:\(self.password.value)")
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
                    Button( "Submit" ) { self.submit() }
                    // enable button only if username and password are valid
                    .disabled( !self.isValid )
                    Spacer()
                }
            } // end of section
        } // end of form
       .navigationBarTitle( Text( "Sample Form" ), displayMode: .inline  )
        } // NavigationView
    }
}

```

### Version 1 (Deprecated)

```swift

struct FormWithValidatorV1 : View {

    @EnvironmentObject var item:DataItem // data model reference
    @State var usernameValid = FieldChecker() // validation state of username field
    @State var passwordValid = FieldChecker() // validation state of password field
    @State var passwordToggleValid = FieldChecker() // validation state of password field

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
                    .overlay( ValidatorMessageInline( message: usernameValid.errorMessageOrNilAtBeginning )
                                ,alignment: .bottom)
    }

    func passwordToggle() -> some View  {
      SecureFieldWithValidator(   title: "give me the password"
                                  value:$item.password,
                                  checker:$passwordToggleValid ) { v in

                              if( v.isEmpty ) {
                                  return "password cannot be empty"
                              }
                              return nil
      }
      .autocapitalization(.none)
      .padding( .bottom, 25  )
      .overlay( ValidatorMessageInline( message: passwordToggleValid.errorMessage ),alignment: .bottom)
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
                    Button( "Submit" ) { self.submit() }
                    // enable button only if username and password are valid
                    .disabled( !self.isValid )
                    Spacer()
                }
            } // end of section
        } // end of form
       .navigationBarTitle( Text( "Sample Form" ), displayMode: .inline  )
        } // NavigationView
    }
}

```

![Sample](assets/FieldValidatorLibrarySample.gif)
