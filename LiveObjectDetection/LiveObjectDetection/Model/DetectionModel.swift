//
//  DetectionModel.swift
//  LiveObjectDetection
//
//  Created by Md. Faysal Ahmed on 13/8/25.
//

import Foundation
import Vision

struct DetectionModel: Identifiable {
    let id: String
    let objName: String
    let confidenceRate: VNConfidence
    let area: CGRect
}
