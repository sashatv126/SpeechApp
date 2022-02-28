//
//  SpeechRecognized.swift
//  SpeechText
//
//  Created by Владимир on 26.02.2022.
//

import Foundation
import Speech

protocol  SpeechRecognizible {
    var delegate : SpeechRecognizerDelegate? { get set }
    func requestMethods(complition: ((Bool) -> Void)?)
    func start()
    func stop()
}
protocol SpeechRecognizerDelegate : AnyObject {
    func output(result : SFSpeechRecognitionResult)
}

final class SpeechRecognized : SpeechRecognizible {
//MARK: -Propertises
    weak var delegate : SpeechRecognizerDelegate?
    private var recognzer : SFSpeechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU"))!
    private var request : SFSpeechAudioBufferRecognitionRequest?
    private var task : SFSpeechRecognitionTask?
    private var engine : AVAudioEngine = AVAudioEngine()
//MARK: -Public method
    func requestMethods(complition: ((Bool) -> Void)?) {
        recognationMicrophone {[weak self] success in
            if success {
                self?.recognationMedia{success in
                    complition?(success)
                }
            }  else {
                complition?(false)
            }
        }
    }
    func start() {
        guard !engine.isRunning else {
            return
        }
        do {
            try startRecognition()
        } catch {

        }
    }
    func stop() {
        guard engine.isRunning else {
            return
        }
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        request?.endAudio()
    }
//MARK: -Private method
    private func recognationMicrophone(complition: ((Bool) -> Void)?) {
        AVAudioSession.sharedInstance().requestRecordPermission{success in
            OperationQueue.main.addOperation {
                complition?(success)
            }
        }
    }
    private func recognationMedia(complition: ((Bool) -> Void)?) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            let success = authStatus == .authorized
            OperationQueue.main.addOperation {
                complition?(success)
            }
        }
    }
    private func startRecognition() throws {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.record)
        try? session.setActive(true, options: .notifyOthersOnDeactivation)
        let node = engine.inputNode
        request = SFSpeechAudioBufferRecognitionRequest()
        guard let request = request else {
            fatalError("SFSpeechAudioBufferRecognitionRequest unable to create ")
        }
        request.shouldReportPartialResults = true
        request.requiresOnDeviceRecognition = true
        task = recognzer.recognitionTask(with: request) {[weak self] result, error in
            guard let self = self else {
                return
            }
            var isFinal : Bool = false
            if let result = result {
                isFinal = result.isFinal
                self.delegate?.output(result : result)
                
            }
            if error != nil || isFinal {
                self.engine.stop()
                self.request = nil
                self.task = nil
                node.removeTap(onBus: 0)
            }
        }
        let format = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: format) {[weak self] buffer, _ in
            self?.request?.append(buffer)
        }
        engine.prepare()
        try engine.start()
    }
}
