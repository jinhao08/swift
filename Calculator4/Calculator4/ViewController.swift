//
//  ViewController.swift
//  Calculator3
//
//  Created by Hao Jin on 4/12/15.
//  Copyright (c) 2015 Hao Jin. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var equation: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false
    
    // Model
    var brain = CalculatorBrain()
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if digit == "π" {
            brain.pushOperandHistory(M_PI)
            enter()
            displayValue = M_PI
            userIsInTheMiddleOfTypingANumber = false
            brain.pushOperand(displayValue!)
        } else {
            if userIsInTheMiddleOfTypingANumber {
                var text = display.text!
                if digit == "." && text.rangeOfString(".") != nil {
                } else {
                    display.text = display.text! + digit
                }
            } else {
                display.text = digit
                userIsInTheMiddleOfTypingANumber = true
            }
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = nil
            }
        }
        displayEquation(brain.description)
        userIsInTheMiddleOfTypingANumber = false
    }
    
    // Change sign
    @IBAction func changeSign() {
        if userIsInTheMiddleOfTypingANumber {
            if display.text!.rangeOfString("-") != nil {
                display.text = dropFirst(display.text!)
            } else {
                display.text = "-" + display.text!
            }
        } else {
            if let result = brain.performOperation("±") {
                displayValue = result
            } else {
                displayValue = nil
            }
        }
    }
    
    @IBAction func enter() {
        if userIsInTheMiddleOfTypingANumber == true {
            brain.pushOperandHistory(displayValue!)
        }
        if let result = brain.pushOperand(displayValue!) {
            displayValue = result
        } else {
            displayValue = nil
        }
        displayEquation(brain.description)
        userIsInTheMiddleOfTypingANumber = false
    }
    
    // Computed property
    var displayValue: Double? {
        get {
            return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
        }
        set {
            if newValue == nil {
                display.text = " "
            } else {
                // Be careful newValue is an optional too, need to unwrapp it before assigning it to a string variable
                display.text = "\(newValue!)"
            }
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
    func displayEquation(equ: String) {
        equation.text = "Equation: " + equ + " ="
    }
    
    // "C" button
    @IBAction func clear() {
        display.text = " "
        equation.text = "Equation:"
        brain.clearStack()
        brain.clearHistoryStack()
        brain.clearMemory("M")
        userIsInTheMiddleOfTypingANumber = false
    }
    
    // Backspace button
    @IBAction func backspace() {
        if userIsInTheMiddleOfTypingANumber {
            if count(display.text!) == 1 {
                display.text = " "
                userIsInTheMiddleOfTypingANumber = false
            } else {
                display.text = dropLast(display.text!)
            }
        }
    }
    @IBAction func setMemory() {
        if displayValue != nil {
            userIsInTheMiddleOfTypingANumber = false
            brain.setVariable(displayValue!)
            displayEquation(brain.description)
        }
    }
    @IBAction func addMemory() {
        brain.pushOperand(displayValue!)
        brain.pushOperandHistory(displayValue!)
        brain.pushOperand("M")
        displayEquation(brain.description)
        userIsInTheMiddleOfTypingANumber = false
    }
}














