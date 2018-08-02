//
//  Log.swift
//  RTCExample
//
//  Created by Marcelo Reina on 30/07/2018.
//  Copyright © 2018 Marcelo Reina. All rights reserved.
//

import Foundation
import SwiftyBeaver

struct Log {
    static let shared = SwiftyBeaver.self
    
    static func setup() {
        let console = ConsoleDestination()
        shared.addDestination(console)
    }
}
