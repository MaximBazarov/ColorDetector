//
//  Coordinator.swift
//  ColorDetector
//
//  Created by Maxim Bazarov on 4/4/18.
//  Copyright © 2018 Maxim Bazarov. All rights reserved.
//

import UIKit

class Coordinator {
    
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func presentMainScreen() {
        let screen = MainScreenController.instantiateScreen()
        window.rootViewController = screen
        window.makeKeyAndVisible()
    }
}
