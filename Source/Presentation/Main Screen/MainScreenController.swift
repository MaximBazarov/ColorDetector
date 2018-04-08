//
//  MainScreenController.swift
//  ColorDetector
//
//  Created by Maxim Bazarov on 4/4/18.
//  Copyright © 2018 Maxim Bazarov. All rights reserved.
//

import FunctionalFoundation
import UIKit

class MainScreenController {
    
    static func instantiateScreen() -> MainScreenViewController {
        let screen = UIStoryboard(name: "MainScreenViewController", bundle: Bundle(for: MainScreenViewController.self)).instantiateInitialViewController() as! MainScreenViewController
        let controller = MainScreenController(screen: screen)
        let onViewLoaded = Command<UIView>(action: controller.attachCoordinator)
        screen.model = MainScreenViewController.ViewModel(previewLayer: nil, colorStream: nil, didLoad: onViewLoaded)
        return screen
    }
    
    // MARK: - Scrren Assemblying -
    
    private weak var screen: MainScreenViewController!
    private var captureService: CaptureService?
    private var colorDetector: ColorDetector?
    
    private var dispose: (()->Void)?
    deinit {
        dispose?()
    }
    
    private init(screen: MainScreenViewController) {
        self.screen = screen
    }
    
    private func attachCoordinator(to view: UIView) {
        let cropFrame = CGRect.init(
            x: view.center.x-15, y: view.center.y-15,
            width: 30, height: 30
        )
        
        CaptureService.startSession(preview: view.bounds).onComplete{ service in
            self.captureService = service
            self.colorDetector = ColorDetector(cropRect: cropFrame)
            self.dispose = self.captureService?.imagesStream.subscribe { [weak self] image in
                guard let image = image else { return }
                self?.colorDetector?.detectColor(forImage: image)
            }
            self.setupScreen()
        }
    }
    
    private func setupScreen() {
        guard let previewLayer = self.captureService?.previewLayer else { return }
        guard let colorStream = self.colorDetector?.colorStream else { return }
        DispatchQueue.main.async {
            self.screen?.model = MainScreenViewController.ViewModel(
                previewLayer: previewLayer, colorStream: colorStream,
                didLoad: Command<UIView>(action: self.attachCoordinator))
        }
    }
    
}
