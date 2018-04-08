//
//  SpeechService.swift
//  ColorDetector
//
//  Created by Maxim Bazarov on 4/4/18.
//  Copyright © 2018 Maxim Bazarov. All rights reserved.
//

import AVFoundation

class SpeechSynthesizer {

    private static let synthesizer = AVSpeechSynthesizer()
    
    public static func speak(_ text: String) {
        guard !synthesizer.isSpeaking else { return }
        let speechUtterance = AVSpeechUtterance(string: text)
        synthesizer.speak(speechUtterance)
    }
    
}
