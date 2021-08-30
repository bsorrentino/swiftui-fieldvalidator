//
//  FieldValidator.swift
//
//
//  Created by Bartolomeo Sorrentino on 16/06/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import Combine


//
// MARK:  FIELD VALIDATION VERSION 2 
//

@available(iOS 13, *)
public class FieldValidator2<T> : ObservableObject where T : Hashable {
    public typealias Validator = (T) -> String?

    @Published public var value:T
    @Published public var errorMessage:String?
    
    
    public var validator:Validator
    internal var numberOfCheck = 0
    internal var validateSub:AnyCancellable?
    internal var bindSub:AnyCancellable?

    public var isFirstCheck:Bool { numberOfCheck == 1 }

    public var valid:Bool {
         self.errorMessage == nil
     }

    public func bind( to value:Binding<T> ) {
        if let bindSub = self.bindSub {
            bindSub.cancel()
        }
        self.bindSub = self.$value.sink { value.wrappedValue = $0 }
    }

    public func unbind( from value:Binding<T> ) {
        if let bindSub = self.bindSub {
            bindSub.cancel()
        }
        self.bindSub = nil

    }
    
    public init( _ value:T, debounceInMills:Int, validator:@escaping Validator  ) {
        self.value = value
        self.validator = validator
        
        validateSub = self.$value
            .debounce(for: .milliseconds(debounceInMills), scheduler: RunLoop.main)
            //.receive(on: RunLoop.main)
            .sink { [self] v in
                //print( "value updated \(v)" )
                doValidate(value: v)
            }
    }

    public convenience init( _ value:T, validator:@escaping Validator  ) {
        self.init( value, debounceInMills:0, validator:validator )
    }

    public convenience init( _ value:T, debounceInMills debounce:Int = 0  ) {
        self.init( value, debounceInMills:debounce, validator: { (v:T) -> String? in nil }  )
    }


    fileprivate func doValidate( value newValue:T ) -> Void {
        self.errorMessage = self.validator( newValue )
        self.numberOfCheck += 1
    }
    
    public func doValidate() -> Void {
        DispatchQueue.main.async {
            self.errorMessage = self.validator( self.value )
        }
    }
}

extension FieldValidator2 {
    
    var errorMessageOrNilAtBeginning:String?  {
        self.isFirstCheck ? nil : errorMessage
    }
}

//
// MARK:  FIELD VALIDATION VERSION 1 - (DEPRECATED)
//

@available(*, deprecated, message: "Use FieldValidator2 instead")
@available(iOS 13, *)
public struct FieldChecker {
    
    internal var numberOfCheck = 0
    public var errorMessage:String?
    
    public var isFirstCheck:Bool { numberOfCheck == 0 }

    public var valid:Bool {
         self.errorMessage == nil
     }
    public init( errorMessage:String? = nil ) {
        self.errorMessage = errorMessage
    }
    
}

extension FieldChecker {
    
    var errorMessageOrNilAtBeginning:String?  {
        self.isFirstCheck ? nil : errorMessage
    }
}

@available(*, deprecated, message: "Use FieldValidator2 instead")
@available(iOS 13, *)
public class FieldValidator<T> : ObservableObject where T : Hashable {
    public typealias Validator = (T) -> String?
    
    @Binding private var bindValue:T
    @Binding private var checker:FieldChecker
    
    @Published public var value:T
    {
        willSet {
            if( newValue != value) {
                self.doValidate(value: newValue)
            }
        }
        didSet {
            self.bindValue = self.value
        }
    }
    private let validator:Validator
    
    public var isValid:Bool { self.checker.valid }
    
    public var errorMessage:String? { self.checker.errorMessage }
    
    public init( _ value:Binding<T>, checker:Binding<FieldChecker>, validator:@escaping Validator  ) {
        self.validator = validator
        self._bindValue = value
        self.value = value.wrappedValue
        self._checker = checker
    }
    
    fileprivate func doValidate( value newValue:T ) -> Void {
        DispatchQueue.main.async {
            self.checker.errorMessage = self.validator( newValue )
            self.checker.numberOfCheck += 1
        }
    }
    
    public func doValidate() -> Void {
        DispatchQueue.main.async {
            self.checker.errorMessage = self.validator( self.value )
        }
    }

}


// MARK:  FORM FIELD
@available(iOS 13, *)
protocol ViewWithFieldValidator : View {
    var field:FieldValidator<String> {get}
    
}

extension ViewWithFieldValidator {
    
    internal func execIfValid( _ onCommit: @escaping () -> Void ) -> () -> Void {
        return {
            if( self.field.isValid ) {
                onCommit()
            }
        }
    }


}

@available(*, deprecated, message: "Use FieldValidator2 instead")
@available(iOS 13, *)
public struct TextFieldWithValidator : ViewWithFieldValidator {
    // specialize validator for TestField ( T = String )
    public typealias Validator = (String) -> String?

    var title:String?
    var onCommit:() -> Void = {}

    @ObservedObject var field:FieldValidator<String>

    public init( title:String = "",
              value:Binding<String>,
              checker:Binding<FieldChecker>,
              onCommit: @escaping () -> Void,
              validator:@escaping Validator ) {
        self.title = title;
        self.field = FieldValidator(value, checker:checker, validator:validator )
        self.onCommit = onCommit
    }

    public init( title:String = "", value:Binding<String>, checker:Binding<FieldChecker>, validator:@escaping Validator ) {
        self.init( title:title, value:value, checker:checker, onCommit:{}, validator:validator)
    }

    public var body: some View {
        VStack {
            TextField( title ?? "", text: $field.value, onCommit: execIfValid(self.onCommit) )
                .onAppear { // run validation on appear
//                    print("\(type(of: self)) onAppear")
                    self.field.doValidate()
                }
        }
    }
    
}

@available(*, deprecated, message: "Use FieldValidator2 instead")
@available(iOS 13, *)
public struct SecureFieldWithValidator : ViewWithFieldValidator {
    // specialize validator for TestField ( T = String )
    public typealias Validator = (String) -> String?

    var title:String?
    var onCommit:() -> Void

    @ObservedObject var field:FieldValidator<String>

    public init( title:String = "",
              value:Binding<String>,
              checker:Binding<FieldChecker>,
              onCommit: @escaping () -> Void,
              validator:@escaping Validator ) {
        self.title = title;
        self.field = FieldValidator(value, checker:checker, validator:validator )
        self.onCommit = onCommit
    }

    public init( title:String = "", value:Binding<String>, checker:Binding<FieldChecker>, validator:@escaping Validator ) {
        self.init( title:title, value:value, checker:checker, onCommit:{}, validator:validator)
    }

    public var body: some View {
       
        VStack {
            SecureField( title ?? "", text: $field.value, onCommit: execIfValid(self.onCommit) )
                .onAppear { // run validation on appear
//                    print("\(type(of: self)) onAppear")
                    self.field.doValidate()
                }
        }
    }

}
