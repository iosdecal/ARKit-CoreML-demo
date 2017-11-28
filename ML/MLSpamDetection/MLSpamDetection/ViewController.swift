//
//  ViewController.swift
//  MLSpamDetection
//
//  Created by Gokul Swamy on 11/24/17.
//  Copyright © 2017 Gokul Swamy. All rights reserved.
//

import UIKit
import CoreML

class ViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var predictionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    @IBAction func pressedPredictButton(_ sender: Any) {
        let text = textField.text
        if let message = text {
            if isSpam(message: message) {
                predictionLabel.text = "Spam"
            } else {
                predictionLabel.text = "Not Spam"
            }
        }
    }
    
    func isSpam(message: String) -> Bool {
        let wordsFile = Bundle.main.path(forResource: "words_ordered", ofType: "txt")
        do {
            let wordsFileText = try String(contentsOfFile: wordsFile!, encoding: String.Encoding.utf8)
            var wordsData = wordsFileText.components(separatedBy: .newlines)
            wordsData.removeLast() // Trailing newline.
            var wordsDict: [String: Int] = [:]
            for (idx, word) in wordsData.enumerated() {
                wordsDict[word] = idx
            }
            
            let posVect = vectorize(message: message, mapping: wordsDict)
            if let vect = posVect {
                let model = SpamDetector()
                let prediction = try model.prediction(message: vect)
                if prediction.label == "ham" {
                    return false
                } else {
                    return true
                }
            }
            
        }
        catch {
            print("ERROR")
        }
        return true
    }
    
    func vectorize(message: String, mapping: [String: Int]) -> MLMultiArray? {
        var message = message
        message = message.lowercased()
        var vector = [Double](repeating: 0.0, count: mapping.count)
        for word in message.split(separator: " "){
            if let index = mapping[String(word)] {
                vector[index] += 1.0
            }
        }
        do {
            let formatted = try MLMultiArray(shape: [NSNumber(integerLiteral: vector.count)], dataType: .double)
            for (idx, elem) in vector.enumerated() {
                formatted[idx] = NSNumber(value: elem)
            }
            return formatted
        } catch {
            return nil
        }
    }


}

