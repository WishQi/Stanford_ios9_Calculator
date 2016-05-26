//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by 李茂琦 on 4/27/16.
//  Copyright © 2016 Li Maoqi. All rights reserved.
//

import Foundation


class CalculatorBrain {
    
    private var accumulator = 0.0
    
    var discription = ""
    
    var isPartialResult: Bool {
        get {
            if pending != nil {
                return true
            } else {
                return false
            }
        }
    }
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.Constant(M_PI),
        "e": Operation.Constant(M_E),
        "%": Operation.UnaryOperation({ $0/100 }),
        "√": Operation.UnaryOperation(sqrt),
        "ln": Operation.UnaryOperation(log),
        "sin": Operation.UnaryOperation(sin),
        "cos": Operation.UnaryOperation(cos),
        "tan": Operation.UnaryOperation(tan),
        "+": Operation.BinaryOperation({ $0 + $1 }),
        "−": Operation.BinaryOperation({ $0 - $1 }),
        "×": Operation.BinaryOperation({ $0 * $1 }),
        "÷": Operation.BinaryOperation({ $0 / $1 }),
        "=": Operation.Equals
    ]
    
    func setOperand(operand: Double) {
        accumulator = operand
        if isPartialResult {
            discription = discription + String(accumulator)
        } else {
            discription = String(operand)
        }
    }
    
    func performOperation(symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                discription = discription + symbol
                accumulator = value
            case .UnaryOperation(let function):
                if isPartialResult {
                    discription = discription + symbol
                } else {
                    discription = symbol + "(" + discription + ")"
                }
                accumulator = function(accumulator)
            case .BinaryOperation(let function):
                discription = discription + symbol
                executePendingBinaryOperation()
                pending = pendingBinaryFunctionInfo(binaryFunction: function, firstOperand: accumulator)
            case .Equals:
                executePendingBinaryOperation()
            }
        }
    }
    
    private struct pendingBinaryFunctionInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    private var pending: pendingBinaryFunctionInfo?
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
}