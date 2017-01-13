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
        var digit = sender.currentTitle!
        
        if digit == "." {
            if userIsInTheMiddleOfFloatingPointNummer {
                return
            }
            if !userIsInTheMiddleOfTyping {
                digit = "0."
            }
            userIsInTheMiddleOfFloatingPointNummer = true
        }
        
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    

    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
            historyDisplay.text = brain.description + (brain.isPartialResult ? " …" : " =")
        }
    }
    
    //brain is used for the user input to be converted to answers
    private var brain = CalculatorBrain()
    

    @IBAction func performOperation(_ sender: UIButton) {
        if  userIsInTheMiddleOfTyping {
            //the number displayed before the user taps an operation key is 
            //saved under setOperand.
            brain.setOperand(operand: displayValue) //makes accumulator = displayValue
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            //if user taps a operation icon, perform that operation.
            brain.performOperation(symbol: mathematicalSymbol)
        }
        displayValue = brain.result //displays result of .performOperation
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

