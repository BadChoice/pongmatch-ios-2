// ComboBadgeView.swift
import SwiftUI

struct ComboBadgeView: View {
    let combo: ScoreCombo?
        
    var body: some View {
        if let combo {
            Text("\(combo.description)")
        } else {
            Spacer().frame(height: 30)
        }
    }
}

