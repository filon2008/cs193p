//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by 吴辰敦 on 15/12/15.
//  Copyright © 2015年 吴辰敦. All rights reserved.
//

import Foundation

class CalculatorBrain : CustomStringConvertible
{
    private enum Op: CustomStringConvertible {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, Int, (Double, Double) -> Double)
        case NullaryOperation(String, () -> Double)
        case Variable(String)
        var description: String {
            switch self {
            case .Operand(let operand):
                return "\(operand)"
            case .UnaryOperation(let symbol, _):
                return symbol
            case .BinaryOperation(let symbol, _, _):
                return symbol
            case .NullaryOperation(let symbol, _):
                return symbol
            case .Variable(let symbol):
                return symbol
            }
        }
        var precedence: Int {
            switch self {
            case .BinaryOperation(_, let precedence, _):
                return precedence
            default:
                return Int.max
            }
        }
    }
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    var variableValues = [String:Double]()

    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("×", 1, *))
        learnOp(Op.BinaryOperation("÷", 1) { $1 / $0 })
        learnOp(Op.BinaryOperation("+", 0, +))
        learnOp(Op.BinaryOperation("−", 0) { $1 - $0 })
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.NullaryOperation("π") { M_PI })
    }

    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, _, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            case .NullaryOperation(_, let operation):
                return (operation(), remainingOps)
            case .Variable(let symbol):
                return (variableValues[symbol], remainingOps)
            }
        }
        return(nil, ops)
    }

    func evaluate() -> Double? {
        let (result, _) = evaluate(opStack)
        return result
    }
    
    func pushOperand(operand : Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(operand : String) -> Double? {
        opStack.append(Op.Variable(operand))
        return evaluate()
    }
    func performOperation(symbol : String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    func clear() {
        opStack.removeAll()
        variableValues.removeAll()
    }
    func setVariable(variableName : String, value variableValue : Double) -> Double? {
        variableValues[variableName] = variableValue;
        return evaluate()
    }
    private func describe(ops: [Op]) -> (description: String, precedence: Int, remainningOps: [Op]) {
        if !ops.isEmpty {
            var remainningOps = ops
            let op = remainningOps.removeLast()
            switch op {
            case .Operand(let operand):
                return ("\(operand)", op.precedence, remainningOps)
            case .UnaryOperation(let symbol, _):
                let operandDescription = describe(remainningOps)
                return(symbol + "(" + operandDescription.description + ")", op.precedence, operandDescription.remainningOps)
            case .BinaryOperation(let symbol, let precedence, _):
                let op1Description = describe(remainningOps)
                let op2Description = describe(op1Description.remainningOps)
                var description1 = op1Description.description
                var description2 = op2Description.description
                if precedence > op1Description.precedence || (precedence == op1Description.precedence && (op.description == "−" || op.description == "÷")) {
                    description1 = "(" + description1 + ")"
                }
                if precedence > op2Description.precedence {
                    description2 = "(" + description2 + ")"
                }
                return (description2 + symbol + description1, op.precedence, op2Description.remainningOps)
            case .NullaryOperation(let symbol, _):
                return (symbol, op.precedence, remainningOps)
            case .Variable(let symbol):
                return (symbol, op.precedence, remainningOps)
            }
        }
        return ("?", Int.max, ops)
    }
    var description : String {
        var enumatedescrption = describe(opStack)
        var result = enumatedescrption.description
        while !enumatedescrption.remainningOps.isEmpty {
            enumatedescrption = describe(enumatedescrption.remainningOps)
            result = enumatedescrption.description + "," + result
        }
        return result
    }
}