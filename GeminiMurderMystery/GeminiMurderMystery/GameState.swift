//
//  GameState.swift
//  GeminiMurderMystery
//
//  Created by Anup D'Souza on 13/02/24.
//

import Foundation

enum GameState {
    case start
    case story
    case questioning
    case result
    
    func image() -> String {
        switch self {
        case .start:
            return "manor"
        case .story:
            return "story"
        case .questioning:
            return "questioning"
        case .result:
            return "result"
        }
    }
}

struct MurderMystery: Codable {
    let plot: String
    let culprit: String
    var questions: [Question]
}

struct Question: Codable {
    var question: String
    var clue: String
    var responses: [String]
    var selectedResponse: String? = nil
}
