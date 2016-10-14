//
//  ViewController.swift
//  Calculator
//
//  Created by 李茂琦 on 4/26/16.
//  Copyright © 2016 Li Maoqi. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {

    @IBOutlet fileprivate weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    fileprivate var userIsInTheMiddleOfTyping: Bool = false {
        didSet {
            if !userIsInTheMiddleOfTyping {
                userIsInTheMiddleOfFloatingPointNumber = false
            }
        }
    }
    
    fileprivate var userIsInTheMiddleOfFloatingPointNumber = false
    
    fileprivate var brain = CalculatorBrain()
    
    fileprivate var displayValue: Double {
        get {
            return NumberFormatter().number(from: display.text!)!.doubleValue
        }
        set {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 6
            display.text = formatter.string(from: NSNumber(value: newValue))
            history.text = brain.description + (brain.isPartialResult ? " ⋯" : " =")
        }
    }
    
    @IBAction fileprivate func touchDigit(_ sender: UIButton) {
        var digit = sender.currentTitle!
        
        if digit == "." {
            if userIsInTheMiddleOfFloatingPointNumber {
                return
            }
            if !userIsInTheMiddleOfTyping {
                digit = "0."
            }
            userIsInTheMiddleOfFloatingPointNumber = true
        }
        
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
        }
        
        userIsInTheMiddleOfTyping = true
    }
    @IBAction fileprivate func clear(_ sender: UIButton) {
        brain.clear()
        display.text = "0"
        history.text = "⋯"
        userIsInTheMiddleOfTyping = false
    }

    @IBAction func undo() {
        if userIsInTheMiddleOfTyping {
            if display.text != "" {
                var currentDisplay = display.text!
                currentDisplay.remove(at: currentDisplay.characters.index(currentDisplay.endIndex, offsetBy: -1))
                if currentDisplay == "" {
                    display.text = "0"
                    userIsInTheMiddleOfTyping = false
                } else {
                    display.text = currentDisplay
                }
            }
        } else {
            brain.undo()
            history.text = brain.description
        }
    }
    
    @IBAction fileprivate func performOperation(_ sender: UIButton) {
        
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        
        displayValue = brain.result
        
    }

}
