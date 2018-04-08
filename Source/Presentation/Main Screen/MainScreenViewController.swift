//
//  ViewController.swift
//  ColorDetector
//
//  Created by Maxim Bazarov on 4/4/18.
//  Copyright © 2018 Maxim Bazarov. All rights reserved.
//

import UIKit
import AVFoundation
import FunctionalFoundation

class MainScreenViewController: UIViewController {

    struct ViewModel {
        let previewLayer: AVCaptureVideoPreviewLayer?
        let colorStream: Observable<SmartColor?>?
        let didLoad: Command<UIView>?
        
        static let initial = ViewModel(previewLayer: nil, colorStream: nil, didLoad: nil)
    }
    
    var model = ViewModel.initial {
        didSet {
            guard isViewLoaded else { return }
            render()
        }
    }
    
    @IBOutlet weak var crossView: UIImageView!
    private var dispose: (() -> Void)?
    deinit {
        dispose?()
    }
    
    private func render() {
        guard let layer = model.previewLayer else { return }
        layer.removeFromSuperlayer()
        view.layer.insertSublayer(layer, below: crossView.layer)
        dispose = model.colorStream?.subscribe { [weak self] color in
            DispatchQueue.main.async {
                self?.handleColorChange(color)
            }
        }
    }
    
    private var previous: SmartColor?
    func handleColorChange(_ color: SmartColor?) {
        guard let color = color else { return }
        crossView.tintColor = color.value
        if let previous = previous, previous.name == color.name { return }
        SpeechSynthesizer.speak(color.name)
        previous = color
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        model.didLoad?.execute(with: self.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

