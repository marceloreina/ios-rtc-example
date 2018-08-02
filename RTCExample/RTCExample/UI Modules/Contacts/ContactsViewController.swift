//
//  ViewController.swift
//  RTCExample
//
//  Created by Marcelo Reina on 30/07/2018.
//  Copyright © 2018 Marcelo Reina. All rights reserved.
//

import UIKit

protocol ContactsPresenterView: class {
    func showContactList(contacts: [SocketUser])
    func showViewController(viewController: UIViewController)
}

class ContactsViewController: UIViewController {
    
    static let storyboardId: String = String(describing: ContactsViewController.self)
    let userCellIdentifier: String = "UserCell"
    
    var presenter: ContactsPresenterProtocol!
    
    @IBOutlet weak var onlineUsersTableView: UITableView!
    private var onlineUsers: [SocketUser] = [SocketUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Online Contacts"
        presenter.connect(username: "iOS Client")
    }
    
}

extension ContactsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return onlineUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = onlineUsers[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: userCellIdentifier, for: indexPath)
        cell.textLabel?.text = user.alias
        cell.detailTextLabel?.text = user.id
        return cell
    }
}

extension ContactsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let targetUser = onlineUsers[indexPath.row]
        presenter.call(target: targetUser)
    }
}

extension ContactsViewController: ContactsPresenterView {
    
    func showContactList(contacts: [SocketUser]) {
        onlineUsers = contacts
        onlineUsersTableView.reloadData()
    }
    
    func showViewController(viewController: UIViewController) {
        present(viewController, animated: true) {
            Log.shared.debug("\(viewController) presented!")
        }
    }
    
}

