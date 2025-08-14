//
//  Ext+VNConfidence.swift
//  LiveObjectDetection
//
//  Created by Md. Faysal Ahmed on 14/8/25.
//

import Foundation
import Vision

extension VNConfidence {
    var perchentage: String {
        String(format: "%d%%", Int(self * 100))
    }
}
