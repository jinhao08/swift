//
//  CalculatorBrain.swift
//  Calculator3
//
//  Created by Hao Jin on 4/14/15.
//  Copyright (c) 2015 Hao Jin. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    // "Printable" is a protocol
    private enum Op: Printable
    {
        case Operand(Double)
        case OperandString(String)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .OperandString(let operandString):
                    return operandString
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
                
            }
        }
    }
    
    var description: String {
        get {
            var formulation = ""
            var historyOps = historyStack
            println("\(historyStack)")
            var count = historyOps.count
            while count > 0 {
                //                println(count)
                let (result, newFormulation, remainder) = searchFormulation(historyOps, formulation: "")
                historyOps = remainder
                if newFormulation != nil {
                    formulation = newFormulation! + "," + formulation
                    count = remainder.count
                } else {
                    break
                }
            }
            if formulation.rangeOfString(",") != nil {
                return dropLast(formulation)
            } else {
                return formulation
            }
        }
    }
    
    private func searchFormulation(ops: [Op], formulation: String) -> (result: Double?, formulation: String?, remainingOps: [Op]) {
        //        println("formulation in search: " + formulation)
        
        if !ops.isEmpty {
            var remainingOps = ops
            var currentFormulation = formulation
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                var operandFormulationString = "\(operand)"
                if abs(operand - M_PI) < 1e-8 {
                    operandFormulationString = "π"
                }
                return (operand, operandFormulationString, remainingOps)
            case .OperandString(let operandString):
                return (variableValues[operandString], operandString, remainingOps)
            case .UnaryOperation(let symbol, let operation):
                let operandEvaluation = searchFormulation(remainingOps, formulation: currentFormulation)
                if let operand = operandEvaluation.result {
                    return (operation(operand), symbol + operandEvaluation.formulation!, operandEvaluation.remainingOps)
                }
            case .BinaryOperation(let symbol, let operation):
                let op1Evaluation = searchFormulation(remainingOps, formulation: currentFormulation)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = searchFormulation(op1Evaluation.remainingOps, formulation: op1Evaluation.formulation!)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), "(" + op2Evaluation.formulation! + symbol + op1Evaluation.formulation! + ")", op2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil, nil, ops)
    }
    
    private var opStack = [Op]()
    
    private var historyStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("×", *))
        knownOps["÷"] = Op.BinaryOperation("÷") { $1 / $0 }
        knownOps["+"] = Op.BinaryOperation("+", +)
        knownOps["−"] = Op.BinaryOperation("−") { $1 - $0 }
        knownOps["√"] = Op.UnaryOperation("√", sqrt)
        knownOps["sin"] = Op.UnaryOperation("sin") { sin($0) }
        knownOps["cos"] = Op.UnaryOperation("cos") { cos($0) }
        knownOps["±"] = Op.UnaryOperation("±") { $0 * (-1) }
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList { // guaranteed to be PropertyList
        get {
            return opStack.map {
                 $0.description
            }
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .OperandString(let operandString):
                return (variableValues[operandString], remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func pushOperand(operand: Double) -> Double?{
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    var variableValues: Dictionary<String, Double> = [String:Double]()
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.OperandString(symbol))
        historyStack.append(Op.OperandString(symbol))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double?{
        if let operation = knownOps[symbol] {
            opStack.append(operation)
            historyStack.append(operation)
        }
        return evaluate()
    }
    
    func pushOperandHistory(operand: Double) {
        historyStack.append(Op.Operand(operand))
    }
    
    func clearStack() {
        opStack.removeAll(keepCapacity: false)
    }
    
    func clearHistoryStack() {
        historyStack.removeAll(keepCapacity: false)
    }
    
    func setVariable(newValue: Double) {
        variableValues["M"] = newValue
        self.evaluate()
    }
    
    func clearMemory(key: String) {
        variableValues.removeValueForKey(key)
    }
    
}








