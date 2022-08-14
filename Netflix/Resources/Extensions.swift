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
}
