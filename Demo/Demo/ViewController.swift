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
        
        StuckMonitor.shared.stuckHappening = { callstack in
            print(callstack.all)
        }
        
        
        CrashMonitor.shared.crashHappening = { type in
            switch type {
            case .exception(let exception, let callStack):
                print("-------------exception name: \(exception.name), reason: \(exception.reason), userInfo: \(exception.userInfo)")
                print(callStack.joined(separator: "\n"))
                print("-------------")
                let callStack = exception.callStackSymbols.joined(separator: "\n")
//                DBManager.shared.insertCrash(title: <#T##String#>, callStack: callStack, date: Date())
            case .singal(let code, let name, let callStack):
                print("-------------singal code: \(code), name: \(name)")
                print(callStack.all)
                print("-------------")
            }
            
        }
        
//        let aView = UIView()
//        let bView = UIView()
//
//        view.addSubview(aView)
//                aView.translatesAutoresizingMaskIntoConstraints = false
//        aView.leadingAnchor.constraint(equalTo: bView.leadingAnchor).isActive = true
    }


}
