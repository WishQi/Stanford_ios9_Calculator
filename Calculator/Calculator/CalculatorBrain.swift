//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by 李茂琦 on 4/27/16.
//  Copyright © 2016 Li Maoqi. All rights reserved.
//

import Foundation


func fractorial(_ operand: Double) -> Double {
    if operand <= 1 {
        return 1
    }
    return operand * fractorial(operand - 1)
}

class CalculatorBrain {
    
    fileprivate var accumulator = 0.0
    
    fileprivate var descriptionAccumulator = "0" {
        didSet {
            if pending == nil {
                currentPrecedence = Int.max
            }
        }
    }
    
    fileprivate var internalProgram = [AnyObject]()
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram as CalculatorBrain.PropertyList
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let operation = op as? String {
                        performOperation(operation)
                    }
                }
            }
        }
    }
    
    fileprivate var currentPrecedence = Int.max
    
    var description: String {
        get {
            if pending == nil {
                return descriptionAccumulator
            } else {
                return pending!.descriptionFunction(pending!.descriptionOperand, pending!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator : "")
            }
        }
    }
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
    fileprivate enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String, Int)
        case equals
    }
    
    fileprivate var operations: Dictionary<String, Operation> = [
        "π": Operation.constant( M_PI ),
        "e": Operation.constant( M_E ),
        "√": Operation.unaryOperation( sqrt, {"√(" + $0 + ")"} ),
        "±": Operation.unaryOperation({ -$0 }, {"-" + $0}),
        "ln": Operation.unaryOperation( log, {"ln(" + $0 + ")"} ),
        "log": Operation.unaryOperation( log10, {"log(" + $0 + ")"} ),
        "sin": Operation.unaryOperation( sin, {"sin(" + $0 + ")"} ),
        "cos": Operation.unaryOperation( cos, {"cos(" + $0 + ")"} ),
        "tan": Operation.unaryOperation( tan, {"tan(" + $0 + ")"} ),
        "sinh": Operation.unaryOperation( sinh, {"sinh(" + $0 + ")"} ),
        "cosh": Operation.unaryOperation( cosh, {"cosh(" + $0 + ")"} ),
        "tanh": Operation.unaryOperation( tanh, {"tanh(" + $0 + ")"} ),
        "x²": Operation.unaryOperation( {pow($0, 2)}, {"(" + $0 + ")²"} ),
        "x³": Operation.unaryOperation( {pow($0, 3)}, {"(" + $0 + ")³"} ),
        "10ˣ": Operation.unaryOperation( {pow(10, $0)}, {"10^(" + $0 + ")"} ),
        "eˣ": Operation.unaryOperation( exp, {"e^(" + $0 + ")"} ),
        "x⁻¹": Operation.unaryOperation( {pow($0, -1)}, {"(" + $0 + ")⁻¹"}),
        "x!": Operation.unaryOperation( fractorial, {"(" + $0 + ")!"} ),
        "xʸ": Operation.binaryOperation( {pow($0, $1)}, {$0 + "^" + $1}, 2),
        "+": Operation.binaryOperation( +, {$0 + "+" + $1}, 0 ),
        "−": Operation.binaryOperation( -, {$0 + "-" + $1}, 0 ),
        "×": Operation.binaryOperation( *, {$0 + "×" + $1}, 1 ),
        "÷": Operation.binaryOperation( /, {$0 + "÷" + $1}, 1 ),
        "=": Operation.equals
    ]
    
    fileprivate struct pendingBinaryFunctionInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
    }
    
    fileprivate var pending: pendingBinaryFunctionInfo?
    
    func setOperand(_ operand: Double) {
        internalProgram.append(operand as AnyObject)
        accumulator = operand
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 6
        descriptionAccumulator = formatter.string(from: NSNumber(value: operand))!
    }
    
    func performOperation(_ symbol: String) {
        internalProgram.append(symbol as AnyObject)
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
                descriptionAccumulator = symbol
            case .unaryOperation(let function, let descriptionFunction):
                accumulator = function(accumulator)
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)
            case .binaryOperation(let function, let descriptionFunction, let precedence):
                executePendingBinaryOperation()
                if currentPrecedence < precedence {
                    descriptionAccumulator = "(" + descriptionAccumulator + ")"
                }
                currentPrecedence = precedence
                pending = pendingBinaryFunctionInfo(binaryFunction: function, firstOperand: accumulator, descriptionFunction: descriptionFunction, descriptionOperand: descriptionAccumulator)
            case .equals:
                executePendingBinaryOperation()
            }
        }
    }
    
    func clear() {
        pending = nil
        accumulator = 0.0
        descriptionAccumulator = "0"
    }
    
    func undo(){
        if pending != nil {
            pending = nil
            internalProgram.removeLast()
        }
    }
    
    fileprivate func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            descriptionAccumulator = pending!.descriptionFunction(pending!.descriptionOperand, descriptionAccumulator)
            pending = nil
        }
    }
    
}
