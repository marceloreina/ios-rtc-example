//
//  ContactsBuilder.swift
//  RTCExample
//
//  Created by Marcelo Reina on 30/07/2018.
//  Copyright © 2018 Marcelo Reina. All rights reserved.
//

import Foundation
import UIKit

struct ContactsBuilder {
    
    static func buildModule() -> UIViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle(for: ContactsViewController.self))
        
        let viewControllerIdentifier = ContactsViewController.storyboardId
        guard let contatctsViewController = storyBoard.instantiateViewController(withIdentifier: viewControllerIdentifier) as? ContactsViewController else {
            Log.shared.error("No view controller found for \(viewControllerIdentifier)")
            fatalError()
        }
        
        let socket = Socket()
        let presenter = ContactsPresenter(socket: socket, delegate: contatctsViewController)
        contatctsViewController.presenter = presenter

        return contatctsViewController
    }
}
