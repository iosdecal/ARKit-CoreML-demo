//
//  TicTacToe.swift
//  ARTicTacToe
//
//  Created by Gokul Swamy on 11/24/17.
//  Copyright © 2017 Gokul Swamy. All rights reserved.
//

import Foundation

func getBestMove(board: [String]) -> Int {
    var bestScore = 11
    var bestMove = -1
    
    for i in 0 ..< board.count {
        if board[i] == "" {
            var newBoard = board
            newBoard[i] = "O"
            
            let qValue = minimax(player: "X", board: newBoard)
            if qValue < bestScore {
                bestScore = qValue
                bestMove = i
            }
        }
    }
    return bestMove
}

//AI is O, trying to minimize score
func minimax(player: String, board: [String]) -> Int {
    if XWon(board: board) {
        return 10
    }
    if OWon(board: board) {
        return -10
    }
    if boardFull(board: board) {
        return 0
    }
    else {
        if player == "X" {
            var bestScore = -11
            for i in 0 ..< board.count {
                if board[i] == "" {
                    var newBoard = board
                    newBoard[i] = "X"
                    let qValue = minimax(player: "O", board: newBoard)
                    if qValue > bestScore {
                        bestScore = qValue
                    }
                }
            }
            return bestScore
        } else {
            var bestScore = 11
            for i in 0 ..< board.count {
                if board[i] == "" {
                    var newBoard = board
                    newBoard[i] = "O"
                    let qValue = minimax(player: "X", board: newBoard)
                    if qValue < bestScore {
                        bestScore = qValue
                    }
                }
            }
            return bestScore
        }
    }
}

func boardFull(board: [String]) -> Bool {
    for cell in board {
        if cell == "" {
            return false
        }
    }
    return true
}

func XWon(board: [String]) -> Bool {
    return
        ("X" == board[0] && board[0] == board[1] && board[1] == board[2]) ||
        ("X" == board[3] && board[3] == board[4] && board[4] == board[5]) ||
        ("X" == board[6] && board[6] == board[7] && board[7] == board[8]) ||
        ("X" == board[0] && board[0] == board[3] && board[3] == board[6]) ||
        ("X" == board[1] && board[1] == board[4] && board[4] == board[7]) ||
        ("X" == board[2] && board[2] == board[5] && board[5] == board[8]) ||
        ("X" == board[0] && board[0] == board[4] && board[4] == board[8]) ||
        ("X" == board[2] && board[2] == board[4] && board[4] == board[6])
}

func OWon(board: [String]) -> Bool {
    return
        ("O" == board[0] && board[0] == board[1] && board[1] == board[2]) ||
        ("O" == board[3] && board[3] == board[4] && board[4] == board[5]) ||
        ("O" == board[6] && board[6] == board[7] && board[7] == board[8]) ||
        ("O" == board[0] && board[0] == board[3] && board[3] == board[6]) ||
        ("O" == board[1] && board[1] == board[4] && board[4] == board[7]) ||
        ("O" == board[2] && board[2] == board[5] && board[5] == board[8]) ||
        ("O" == board[0] && board[0] == board[4] && board[4] == board[8]) ||
        ("O" == board[2] && board[2] == board[4] && board[4] == board[6])
}

