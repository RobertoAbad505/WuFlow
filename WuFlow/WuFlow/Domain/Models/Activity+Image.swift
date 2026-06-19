//
//  Activity+Image.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 6/17/26.
//
import UIKit


extension Activity {
    var uiImage: UIImage? {
        ImageStore.shared.load(from: imagePath)
    }
}
