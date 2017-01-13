//
//  Operations.swift
//  Calculator Demo
//
//  Created by Parankush Bhardwaj on 1/9/17.
//  Copyright © 2017 Parankush Bhardwaj. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    //accumulators are used to accumulate the result of long operations
    private var accumulator = 0.0
    private var currentPrecedence = Int.max
    
    
    var description: String {
        get {
            if pending == nil {
                return descriptionAccumulator
            } else {
                return pending!.descriptionFunction(pending!.descriptionOperand,
                                                    pending!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator : "")
            }
        }
    }
    
    
    private var descriptionAccumulator = "0" {
        didSet {
            if pending == nil {
                currentPrecedence = Int.max
            }
        }
    }
    
    
    private var internalProgram = [AnyObject]()
    //this is an array of AnyObject, which allows it to have
    //doubles and strings within the array (operations and operands)
    
    
    func setOperand(operand: Double) {
        accumulator = operand //used for calculations
        internalProgram.append(operand as AnyObject) //used for storage
        descriptionAccumulator = String(format: "%g", operand)
    }
    
    
    func setOperand(variableName: String) {
            
    }
    
    
    var variableValues = [String(), Double()] as AnyObject
    
    
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "√" : Operation.UnaryOperation(sqrt, { "√(" + $0 + ")"}),
        "∛" : Operation.UnaryOperation(cbrt, { "√(" + $0 + ")"}),
        "cos": Operation.UnaryOperation(cos, { "√(" + $0 + ")"}),
        "sin": Operation.UnaryOperation(sin, { "√(" + $0 + ")"}),
        "±" : Operation.UnaryOperation({ -$0 }, { "-(" + $0 + ")"}),
        "×" : Operation.BinaryOperation(*, { $0 + " × " + $1 }, 1),
        "÷" : Operation.BinaryOperation(/, { $0 + " ÷ " + $1 }, 1),
        "+" : Operation.BinaryOperation(+, { $0 + " + " + $1 }, 0),
        "-" : Operation.BinaryOperation(-, { $0 + " - " + $1 }, 0),
        "=" : Operation.Equals
    ]
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double, (String) -> String)
        case BinaryOperation((Double, Double) -> Double, (String, String) -> String, Int)
        case Equals
    }
    
    
    //the number we were waitig for is the accumulator, the pending number is the first operand, and the symbol (ex:+,=,*,etc.) is the binaryFunntion()
    //ex: accumuator = 5 + 3 [see 'operations' for details on evaluations]
    private func executePendingBinaryOperation()
    {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            descriptionAccumulator = pending!.descriptionFunction(pending!.descriptionOperand, descriptionAccumulator)
            pending = nil
        }
    }
    
    
    private var pending: PendingBinaryOperationInfo?
    //its optional because its nil unless user types a mathematical symbol
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
        
    }
    
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol as AnyObject) //used for storage
        if let operation = operations[symbol] {
            switch operation {
                
            case .Constant(let value):
                accumulator = value
                descriptionAccumulator = symbol
                //converts a single math symbol to its double value
                
            case .UnaryOperation(let operationSymbol, let descriptionFunction):
                accumulator = operationSymbol(accumulator)
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)
               //solves operations for a single number (sqrt, cos, etc.)
                //ex: accumulator = sqrt(4)
                //ex: accumulator = cos(45)
                
            case .BinaryOperation(let operationSymbol, let descriptionFunction, let precedence):
                executePendingBinaryOperation()
                if currentPrecedence < precedence {
                    descriptionAccumulator = "(" + descriptionAccumulator + ")"
                }
                currentPrecedence = precedence
                pending = PendingBinaryOperationInfo(
                    binaryFunction: operationSymbol, firstOperand: accumulator,
                    descriptionFunction: descriptionFunction,
                    descriptionOperand: descriptionAccumulator)
                
                //does operations for two numbers.
                //stores symbol and first number (ex: '5 + ...')
                //to evaluate it, we wait for an equal button to be pressed
                //while we wait, symbol and first number is stored in pendingBin...
                
                
            case .Equals:
                executePendingBinaryOperation()
                
            }
        }
    }
    
    
    typealias PropertyList = AnyObject //used to highlight that program is AnyObject
    
    var storage: PropertyList {
        get{
            return internalProgram as CalculatorBrain.PropertyList
        }
        set{
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand: operand)
                    }
                    else if let operation = op as? String {
                        performOperation(symbol: operation)
                    }
                }
            }
            
        }
    }
    
    func clear() {
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
    }
    
    
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    
}

