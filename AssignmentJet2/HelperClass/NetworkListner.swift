//
//  NetworkListner.swift
//  AssignmentJet2
//
//  Created by Apple on 21/07/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class NetworkListner : NSObject {

static  let shared = NetworkListner()

var reachabilityStatus: Reachability.Connection = .unavailable
let reachability = try! Reachability()

var isNetworkAvailable : Bool {
    return reachabilityStatus != .unavailable
}



func startNWListner() {
    
    NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
    
    reachability.whenReachable = { reachability in
        if reachability.connection == .wifi {
            print("Reachable via WiFi")
        } else {
            print("Reachable via Cellular")
        }
    }
    reachability.whenUnreachable = { _ in
        print("Not reachable")
    }
    
    do {
        try reachability.startNotifier()
    } catch {
        print("Unable to start notifier")
    }
}

@objc func reachabilityChanged(note: Notification) {
    
    let reachability = note.object as! Reachability
    
    switch reachability.connection {
    case .wifi:
        print("Reachable via WiFi")
    case .cellular:
        print("Reachable via Cellular")
    case .unavailable:
        print("Network not reachable")
    case .none:
        print("Network none")
    }
 }


}
