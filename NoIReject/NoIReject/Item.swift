//
//  Moment.swift
//  NoIReject
//
//  Created by ZhilanGuo on 2026/4/4.
//

import Foundation
import SwiftData

enum MomentType: String, Codable, CaseIterable {
    case uncomfortable = "uncomfortable"
    case excited = "excited"
}

@Model
final class Moment {
    var date: Date
    var typeRaw: String
    var intensity: Int  // 1–20
    var tags: [String]
    var note: String

    var type: MomentType {
        get { MomentType(rawValue: typeRaw) ?? .uncomfortable }
        set { typeRaw = newValue.rawValue }
    }

    var score: Int {
        type == .excited ? intensity : -intensity
    }

    init(date: Date = Date(), type: MomentType, intensity: Int, tags: [String] = [], note: String = "") {
        self.date = date
        self.typeRaw = type.rawValue
        self.intensity = intensity
        self.tags = tags
        self.note = note
    }
}

let predefinedTags = ["Work", "Family", "Gym", "Health", "Social", "Study", "Travel", "Food"]

func dailyEmoji(for score: Int) -> String {
    if score < -20 { return "😰" }
    if score <  -5 { return "😔" }
    if score <=  5 { return "😐" }
    if score <  20 { return "😊" }
    return "🤩"
}
