//
//  ViewController.swift
//  Calculator
//
//  Created by 李茂琦 on 4/26/16.
//  Copyright © 2016 Li Maoqi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var display: UILabel!
    @IBOutlet weak var discription: UILabel!
    
    private var userIsInTheMiddleOfTyping: Bool = false
    
    private var brain = CalculatorBrain()
    
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    @IBAction private func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            if digit == "." {
                if textCurrentlyInDisplay.rangeOfString(".") == nil {
                    display!.text = textCurrentlyInDisplay + digit
                }
            } else {
                display!.text = textCurrentlyInDisplay + digit
            }
        } else {
            display.text = digit
        }
        
        userIsInTheMiddleOfTyping = true
    }

    @IBAction private func performOperation(sender: UIButton) {
        
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        
        displayValue = brain.result
        
        if brain.isPartialResult {
            discription.text = brain.discription + "..."
        } else {
            discription.text = brain.discription + "="
        }
    }

}