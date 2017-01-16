//
//  Operations.swift
//  Calculator Demo
//
//  Created by Parankush Bhardwaj on 1/9/17.
//  Copyright © 2017 Parankush Bhardwaj. All rights reserved.
//
import Foundation
class CalculatorBrain {
    
    private var accumulator = 0.0
    private var internalProgram = [AnyObject]()
    var description: String = ""
    var variableValues: Dictionary<String, Double> = ["M": 0.0]
    
    
    
    func setOperand(operand: Double) {
        accumulator = operand                           //used for operations
        internalProgram.append(operand as AnyObject)    //used for storage
        description += String(format:"%g",operand)      //used for description
    }
    
    func setOperand(variableName: String) {
        if let operand = variableValues[variableName] {
            accumulator = operand                       //used to store a variable
            internalProgram.append(variableName as AnyObject)//used for storage
            description += variableName                 //used for description
        }
    }
    
    
    //the number we were waitig for is the accumulator, the pending number is the first operand, and the symbol (ex:+,=,*,etc.) is the binaryFunntion()
    private var pending: PendingBinaryOperationInfo?    //
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        
    }

    //ex: accumuator = 5 + 3 [see 'operations' for details on evaluations]
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    //used for clearing calculator display and history
    private func clear() {
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
        description = ""
    }
    
    //used to undo most recent operation or number tapped
    func undo() {
        internalProgram.removeLast()
        storage = internalProgram as CalculatorBrain.PropertyList
    }
    
    //used in touchDigit for variables
    var isPartialResult: Bool {
        return pending != nil
    }
    
    //will hold the result, changes after performOperation() is used
    var result: Double {
        return accumulator
    }
    
    // converts obj to string for variables and description
    private func convertObjTOStr(obj: AnyObject) -> String {
        if let operand = obj as? Double {
            return String(format:"%g", operand)
        } else if let operation = obj as? String {
            return operation
        }
        return " "
    }
    
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryIperation((Double, Double) -> Double)
        case Equals
        case Clear
    }
    
    //dictionary that holds the math function to do for each button operation
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.Constant(M_PI),
        "±" : Operation.UnaryOperation({-$0}),
        "√" : Operation.UnaryOperation(sqrt),
        "cos" : Operation.UnaryOperation(cos),
        "sin" : Operation.UnaryOperation(sin),
        "%" : Operation.UnaryOperation({$0 / 100}),
        "×" : Operation.BinaryIperation({$0 * $1}),
        "÷" : Operation.BinaryIperation({$0 / $1}),
        "+" : Operation.BinaryIperation({$0 + $1}),
        "-" : Operation.BinaryIperation({$0 - $1}),
        "c" : Operation.Clear,
        "=" : Operation.Equals
    ]
    
    //below, we will put the dictionary into use
    func performOperation(symbol: String) {
        if let operation = operations[symbol] {
            var preInput: String = ""
            if internalProgram.count > 0 {
                preInput = convertObjTOStr(obj: internalProgram[internalProgram.count - 1])
            }
            switch operation {
            case .Constant(let value):
                accumulator = value
                description += symbol
            case .UnaryOperation(let function):
                if isPartialResult {
                    let rangeOfPreinput = description.range(of: preInput)
                    description.removeSubrange(rangeOfPreinput!)
                    description = description + symbol + "(" + String(format: "%g", accumulator) + ")"
                } else {
                    if symbol != "±" {
                        description = symbol + "(" + description + ")"
                    }
                    else {
                        if description[description.startIndex] != "-" {
                            description = "-(" + description + ")"
                        }
                        else {
                            description.remove(at: description.startIndex)
                        }
                    }
                }
                accumulator = function(accumulator)
            case .BinaryIperation(let function):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                description += symbol
            case .Equals:
                if  preInput == "+" || preInput == "-" || preInput == "×" || preInput == "÷" {
                    description += String(format: "%g", accumulator)
                }
                executePendingBinaryOperation()
            case .Clear:
                clear()
            }
        }
        internalProgram.append(symbol as AnyObject)
    }
    

    
    typealias PropertyList = AnyObject
    var storage : PropertyList {
        get {
            return internalProgram as CalculatorBrain.PropertyList
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand: operand)
                    } else if let operationOrOperand = op as? String {
                        if operations[operationOrOperand] != nil {
                            performOperation(symbol: operationOrOperand)
                        }
                        else {
                            setOperand(variableName: operationOrOperand)
                        }
                    }
                }
            }
        }
    }

}

