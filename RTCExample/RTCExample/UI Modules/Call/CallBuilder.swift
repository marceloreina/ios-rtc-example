//
//  CallBuilder.swift
//  RTCExample
//
//  Created by Marcelo Reina on 01/08/2018.
//  Copyright © 2018 Marcelo Reina. All rights reserved.
//

import Foundation
import UIKit

struct CallBuilder {
    
    static func build(rtcClient: RTCClientProtocol) -> UIViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle(for: CallViewController.self))
        
        let viewControllerIdentifier = CallViewController.storyboardId
        guard let callViewController = storyBoard.instantiateViewController(withIdentifier: viewControllerIdentifier) as? CallViewController else {
            Log.shared.error("No view controller found for \(viewControllerIdentifier)")
            fatalError()
        }
        
        let presenter = CallPresenter(viewDelegate: callViewController, rtcClient: rtcClient)
        callViewController.presenter = presenter
        
        return callViewController
    }
}
