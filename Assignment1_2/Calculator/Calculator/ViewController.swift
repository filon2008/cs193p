//
//  ViewController.swift
//  Calculator
//
//  Created by 吴辰敦 on 15/12/12.
//  Copyright © 2015年 吴辰敦. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var display: UILabel!

    @IBOutlet weak var history: UILabel!

    var userIsInTheMiddleOfTypingNumber = false

    var brain = CalculatorBrain()

    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingNumber {
            if digit != "." || display.text!.rangeOfString(digit) == nil {
                display.text = display.text! + digit
            }
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingNumber = true
        }
    }

    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingNumber {
            enter()
        }
        if let operation = sender.currentTitle {
            displayValue = brain.performOperation(operation)
        }
        history.text = brain.description + "="
    }
    
    @IBAction func clear() {
        display.text = " "
        brain.clear()
        userIsInTheMiddleOfTypingNumber = false
        history.text = ""
    }

    @IBAction func enter() {
        userIsInTheMiddleOfTypingNumber = false
        if let operand = displayValue {
            displayValue = brain.pushOperand(operand)
        }
        history.text = brain.description + "="
    }
    
    @IBAction func appendmemory() {
        if userIsInTheMiddleOfTypingNumber {
            enter()
        }
        displayValue = brain.pushOperand("M")
        history.text = brain.description + "="
    }
    
    @IBAction func toMemory() {
        if let operand = displayValue {
            displayValue = brain.setVariable("M", value: operand)
            userIsInTheMiddleOfTypingNumber = false
        }
    }
    var displayValue: Double? {
        get {
            if let displayText = display.text {
                return NSNumberFormatter().numberFromString(displayText)?.doubleValue
            } else {
                return nil
            }
        }
        set {
            if newValue != nil {
                display.text = "\(newValue!)"
                //userIsInTheMiddleOfTypingNumber = false
            } else {
                display.text = " "
            }
        }
    }
}

