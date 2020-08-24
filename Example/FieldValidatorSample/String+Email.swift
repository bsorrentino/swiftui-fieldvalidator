//
//  String+Email.swift
//  FieldValidatorSample
//
//  Created by Bartolomeo Sorrentino on 24/08/20.
//  Copyright © 2020 bsorrentino. All rights reserved.
//

import Foundation

let __firstpart = "[A-Z0-9a-z]([A-Z0-9a-z._%+-]{0,30}[A-Z0-9a-z])?"
let __serverpart = "([A-Z0-9a-z]([A-Z0-9a-z-]{0,30}[A-Z0-9a-z])?\\.){1,5}"
let __emailRegex = "\(__firstpart)@\(__serverpart)[A-Za-z]{2,8}"
let __emailPredicate = NSPredicate(format: "SELF MATCHES %@", __emailRegex)

extension String {
    func isEmail() -> Bool {
        return __emailPredicate.evaluate(with: self)
    }
}
