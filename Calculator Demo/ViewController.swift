//
//  ViewController.swift
//  Calculator Demo
//
//  Created by Parankush Bhardwaj on 1/9/17.
//  Copyright © 2017 Parankush Bhardwaj. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var display: UILabel!
    private var userIsInTheMiddleOfTyping = false
    
    
    @IBOutlet weak var historyDisplay: UILabel!
    
    func appendHistory(operandOrOperator: String) {
        if historyDisplay.text != nil {
            historyDisplay.text = historyDisplay.text! + operandOrOperator
        } else {
            historyDisplay.text = operandOrOperator
        }
    }
    
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping && digit != "."  {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        }  else {
            if digit == "." {
                display.text = "0" + digit
            } else {
                display.text = digit
            }
            userIsInTheMiddleOfTyping = true
        }
        appendHistory(operandOrOperator: digit)
    }
    
    
    
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
            //historyDisplay.text = String(newValue)
        }
    }
    
    var savedProgram: CalculatorBrain.PropertyList?
    
    
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    
    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }
    
    private var brain = CalculatorBrain()
    
    
    @IBAction func performOperation(_ sender: UIButton) {
        if  userIsInTheMiddleOfTyping {
            brain.setOperand(operand: displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            appendHistory(operandOrOperator: mathematicalSymbol)
            brain.performOperation(symbol: mathematicalSymbol)
        }
        
        displayValue = brain.result
    }
    
    
    @IBAction func result(_ sender: UIButton) {
        historyDisplay.text = ""
    }
    
    
    
    @IBAction func clear(_ sender: UIButton) {
        displayValue = 0
        historyDisplay.text = ""
        userIsInTheMiddleOfTyping = false
        
    }
    
}

