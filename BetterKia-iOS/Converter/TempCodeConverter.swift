//
//  TempCodeConverter.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 16.02.23.
//

import Foundation

struct TempCodeConverter {
    static func floatRange(start: Float, stop: Float, step: Float) -> [Float] {
        var ranges: [Float] = []
        var i = start
        while i <= stop {
          ranges.append(i)
          i += step
        }
        return ranges
      }
    
    // Converts a hex code to a float in celsius
    static func tempCodeToCelsius(code: String) -> Float {
        // create a range
        let start: Float = 14
        let end: Float = 30
        let step: Float = 0.5
        let tempRange = floatRange(start: start, stop: end, step: step)

        // get the index
        guard let tempIndex = Int(code.dropLast(), radix: 16) else {
          return 0.0 // or throw an error, depending on your use case
        }

        // return the relevant celsius temp
        return tempRange[tempIndex]
      }
}
