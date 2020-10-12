//
//  ViewController.swift
//  Demo
//
//  Created by duodian on 2020/10/9.
//

import UIKit
import DinergateBrain

struct Test: Decodable {
    let value: Int
}
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        DinergateBrain.shared.start()
        
        CrashMonitor.shared.crashHappening = { type in
            switch type {
            case .exception(let exception):
                print("-------------exception name: \(exception.name), reason: \(exception.reason), userInfo: \(exception.userInfo)")
                print(exception.callStackSymbols.joined(separator: "\n"))
                print("-------------")
                let callStack = exception.callStackSymbols.joined(separator: "\n")
//                DBManager.shared.insertCrash(title: <#T##String#>, callStack: callStack, date: Date())
            case .singal(let code, let name):
                print("-------------singal code: \(code), name: \(name)")
                print(Thread.callStackSymbols.joined(separator: "\n"))
                print("-------------")
            }
            
        }
        
        let aView = UIView()
        let bView = UIView()
        
        view.addSubview(aView)
        aView.translatesAutoresizingMaskIntoConstraints = false
        aView.leadingAnchor.constraint(equalTo: bView.leadingAnchor).isActive = true
    }


}

