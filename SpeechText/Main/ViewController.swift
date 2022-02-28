//
//  ViewController.swift
//

import UIKit
import Speech

final class ViewController: UIViewController{

    // MARK: - IBOutlets

    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var outputTextView: UITextView!
    
    @IBOutlet weak var recognizeButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!

    // MARK: - Properties
    private var words : [WordModel] = []
    private let recognizer : SpeechRecognized = SpeechRecognized()
    private let text: String = Constants.text
    private var isRecognation : Bool = false {
        didSet {
            if isRecognation {
                recognizeButton.backgroundColor = .red
                recognizeButton.setTitle("Stop", for: .normal)
                recognizer.start()
            }
            else {
            recognizeButton.backgroundColor = .green
            recognizeButton.setTitle("Start", for: .normal)
                recognizer.stop()
            }
    }
    }
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        parseText()
        recognizer.delegate = self
        recognizer.requestMethods{ [weak self ] success in
            self?.recognizeButton.isEnabled = success
        }
    }

    // MARK: - Private methods

    private func configureView() {
        inputTextView.layer.cornerRadius = 5
        inputTextView.autocorrectionType = .no
        inputTextView.attributedText = text.attributed

        outputTextView.layer.cornerRadius = 5
        outputTextView.autocorrectionType = .no
        outputTextView.text = ""

        recognizeButton.layer.cornerRadius = 8
        recognizeButton.shadow()
        recognizeButton.isEnabled = false

        resetButton.layer.cornerRadius = 8
    }
    private func parseText(){
        words = text.splitToWords()
    }
    private func findWord (_ word : String, treeshhold : Float = 0.80 ) -> [WordModel] {
        var machedWords : [WordModel] = []
        for mainWord in words {
            var result = mainWord
            if word == mainWord.text {
                result.score = 1
                machedWords.append(mainWord)
            } else {
                let score = word.levenshteinScore(to: mainWord.text)
                if score >= treeshhold {
                    result.score = score
                    machedWords.append(mainWord)
                }
            }
        }
        return machedWords
    }
    private func highlifgt(words : [WordModel]) {
        let attributted = NSMutableAttributedString(string: text)
        words.forEach{
            attributted.addAttribute(.backgroundColor, value: UIColor.green , range: NSRange(location: $0.offset, length: $0.text.count))
        }
        attributted.addAttribute(.font, value: UIFont.systemFont(ofSize : 14), range: NSRange(location: 0, length: text.count))
        inputTextView.attributedText = attributted
    }

    // MARK: - IBActions

    @IBAction func recognizeButtonTap(_ sender: Any) {
        isRecognation.toggle()
    }

    @IBAction func resetButtonTap(_ sender: Any) {
        inputTextView.attributedText = text.attributed
        outputTextView.text = ""
        parseText()
    }

    @IBAction func onScreenTap(_ sender: Any) {
        view.endEditing(true)
    }
}
extension ViewController : SpeechRecognizerDelegate {
    func output(result: SFSpeechRecognitionResult) {
        guard result.isFinal else {
            outputTextView.text = result.bestTranscription.formattedString
            return
        }
        let words = result.bestTranscription.segments.compactMap({ $0.substring})
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let word = words.last else {
                return
            }
            self.highlifgt(words: self.findWord(word))
        }
        
    }
}

