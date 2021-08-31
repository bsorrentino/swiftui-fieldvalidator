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
// MARK:  FIELD VALIDATION
//
@available(iOS 13, *)
public class FieldChecker2<T : Hashable> : ObservableObject {
    
    internal var numberOfCheck = 0
    @Published fileprivate(set) var errorMessage:String?

    internal var boundSub:AnyCancellable?
    fileprivate var subject = PassthroughSubject<T,Never>()
    
    public var isFirstCheck:Bool { numberOfCheck == 0 }

    public var valid:Bool {
         self.errorMessage == nil
    }
    
    public init( errorMessage:String? = nil ) {
        self.errorMessage = errorMessage
    }
    
    fileprivate func bind( to value:T, andValidateWith validator:@escaping(T) -> String? ) {
        if boundSub == nil  {
//            print( "bind( to: )")
            boundSub = subject.debounce(for: .milliseconds(700), scheduler: RunLoop.main)
                        .sink {
//                            print( "validate: \($0)" )
                            self.errorMessage = validator( $0 )
                            self.numberOfCheck += 1
                            
                        }
            // First Validation
            self.errorMessage = validator( value )
        }
    }
    
    fileprivate func doValidate( value newValue:T ) -> Void {
        self.subject.send(newValue)
        
    }

}

extension Binding where Value : Hashable {
    
    func onValidate( checker:FieldChecker2<Value>, debounceInMills:Int = 0, validator:@escaping (Value) -> String? ) -> Binding<Value> {
        
        DispatchQueue.main.async {
            checker.bind(to: self.wrappedValue, andValidateWith: validator)
        }
        return Binding(
            get: { self.wrappedValue },
            set: { newValue in
                
                if( newValue != self.wrappedValue) {
                    checker.doValidate(value: newValue )
                }
                self.wrappedValue = newValue
            }
        )
    }
}

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
