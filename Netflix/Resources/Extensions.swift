//
//  Extensions.swift
//  Netflix
//
//  Created by Umut Can on 14.08.2022.
//

import Foundation

extension String {
    func capitaliazeFirstLetter() -> String {
        return self.prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    func maxLength(length: Int) -> String {
        var str = self
        let nsString = str as NSString
        if nsString.length >= length {
            str = nsString.substring(with:
                NSRange(
                 location: 0,
                 length: nsString.length > length ? length : nsString.length)
            )
        }
        return  str
    }
}
