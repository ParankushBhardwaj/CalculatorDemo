//
//  ViewController.swift
//  Calculator Demo
//
//  Created by Parankush Bhardwaj on 1/9/17.
//  Copyright © 2017 Parankush Bhardwaj. All rights reserved.
//  this is a demo.
//

import UIKit

class ViewController: UIViewController {
    
    //display is what the user sees
    @IBOutlet weak var display: UILabel!
    
    
    private var userIsInTheMiddleOfTyping = false {
        didSet {
            if !userIsInTheMiddleOfTyping {
                userIsInTheMiddleOfFloatingPointNummer = false
            }
        }
    }
    
    private var userIsInTheMiddleOfFloatingPointNummer = false

    
    @IBOutlet weak var historyDisplay: UILabel!
    
    
    //touchDigit is a function of use touching one of nine numbers and a .
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            if digit != "." || !userIsInTheMiddleOfFloatingPointNummer {
                let textCurrentlyInDisplay = display.text
                display.text = textCurrentlyInDisplay! + digit
                if digit == "." { userIsInTheMiddleOfFloatingPointNummer = true}
            }
        } else {
            if !brain.isPartialResult {
                containsVariable = false
            }
            if digit != "0" {
                userIsInTheMiddleOfTyping = true
            }
            if digit == "." {
                display.text = "0" + digit
                userIsInTheMiddleOfFloatingPointNummer = true
            }
            else {
                display.text = digit
            }
        }
    }
    

    //brain is used for the user input to be converted to answers
    private var brain = CalculatorBrain()

    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(format: "%g", newValue)
            historyDisplay.text = brain.description + (brain.isPartialResult ? " …" : " =")
        }
    }
    
    

    @IBAction func performOperation(_ sender: UIButton) {
        
        if userIsInTheMiddleOfTyping {
            
            if !containsVariable {
                brain.setOperand(operand: displayValue)
            }
            
            userIsInTheMiddleOfTyping = false
        }
        
        if let mathematicalSymbol = sender.currentTitle {
            //if user taps a operation icon, perform that operation.
            brain.performOperation(symbol: mathematicalSymbol)
        }
        displayValue = brain.result //displays result of .performOperation
    }
    
    
    private var key = "M"
    private var containsVariable = false
    
    @IBAction func setVariable(_ sender: UIButton) {
        
        let value = Double(display.text!)
        brain.variableValues[key] = value
        
        let variableProgram = brain.storage
        brain.storage = variableProgram
        displayValue = brain.result
        brain = CalculatorBrain() //used so that history is reset after variable init
    }
    
    @IBAction func setOperandVariable(_ sender: UIButton) {
        if let value = brain.variableValues[key] {
            displayValue = value
        }
        brain.setOperand(variableName: sender.currentTitle!)
        containsVariable = true
        userIsInTheMiddleOfTyping = false
    }
    
    
    @IBAction func Undo(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            var displayText = display.text!
            displayText.remove(at: displayText.index(before: displayText.endIndex))
            display.text = displayText
        } else {
            brain.undo()
        }
    }
    


    //this is used to store the result on display
    var savedProgram: CalculatorBrain.PropertyList?
    @IBAction func save() {
        savedProgram = brain.storage
    }
    
    
    //this extracts the stored value from brain and puts it back on the display.
    @IBAction func restore() {
        if savedProgram != nil {
            brain.storage = savedProgram!
            displayValue = brain.result
        }
    }
    
    
    @IBAction func clear(_ sender: UIButton) {
        brain = CalculatorBrain()
        display.text = "0"
        historyDisplay.text = " "
    }
    
}

