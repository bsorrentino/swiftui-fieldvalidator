//
//  FieldValidator.swift
//
//
//  Created by Bartolomeo Sorrentino on 16/06/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import Combine


// MARK:  FIELD VALIDATION

@available(iOS 13.0, *)
public struct FieldChecker {
    
    public var errorMessage:String?
    
    public var valid:Bool {
         self.errorMessage == nil
     }
    public init( errorMessage:String? = nil ) {
        self.errorMessage = errorMessage
    }
}

@available(iOS 13.0, *)
public class FieldValidator<T> : ObservableObject where T : Hashable {
    public typealias Validator = (T) -> String?
    
    @Binding private var bindValue:T
    @Binding private var checker:FieldChecker
    
    @Published public var value:T
    {
        willSet {
            self.doValidate(newValue)
        }
        didSet {
            self.bindValue = self.value
        }
    }
    private let validator:Validator
    
    public var isValid:Bool {
        self.checker.valid
    }
    
    public var errorMessage:String? {
        self.checker.errorMessage
    }
    
    public init( _ value:Binding<T>, checker:Binding<FieldChecker>, validator:@escaping Validator  ) {
        self.validator = validator
        self._bindValue = value
        self.value = value.wrappedValue
        self._checker = checker
    }
    
    public func doValidate( _ newValue:T? = nil ) -> Void {
                
        self.checker.errorMessage =
                        (newValue != nil) ?
                            self.validator( newValue! ) :
                            self.validator( self.value )
    }
}


// MARK:  FORM FIELD

@available(iOS 13.0, *)
public struct TextFieldWithValidator : View {
    // specialize validator for TestField ( T = String )
    public typealias Validator = (String) -> String?
    
    var title:String?
    
    @ObservedObject var field:FieldValidator<String>
    
    public init( title:String = "", value:Binding<String>, checker:Binding<FieldChecker>, validator:@escaping Validator ) {
        self.title = title;
        self.field = FieldValidator(value, checker:checker, validator:validator )
        
    }

    public var body: some View {
        VStack {
            TextField( title ?? "", text: $field.value )
                .onAppear { // run validation on appear
                    self.field.doValidate()
                }
        }
    }
}

@available(iOS 13.0, *)
public struct SecureFieldWithValidator : View {
    // specialize validator for TestField ( T = String )
    public typealias Validator = (String) -> String?
    
    var title:String?
    
    @ObservedObject var field:FieldValidator<String>
    
    public init( title:String = "", value:Binding<String>, checker:Binding<FieldChecker>, validator:@escaping Validator ) {
        self.title = title;
        self.field = FieldValidator(value, checker:checker, validator:validator )
        
    }

    public var body: some View {
        VStack {
            SecureField( title ?? "", text: $field.value )
                .onAppear { // run validation on appear
                    self.field.doValidate()
                }
        }
    }
}
