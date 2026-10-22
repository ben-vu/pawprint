//
//  DogNotesField.swift
//  Pawprint
//
//  Created by Benjamin Vu on 22/10/2026.
//
//  A labelled multi-line text box, styled like DogFormField, for the longer
//  care notes (feeding, medical, behaviour).
//

import SwiftUI

struct DogNotesField<Field: Hashable>: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var focus: FocusState<Field?>.Binding
    let field: Field

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(PawprintTheme.font(.caption, weight: .bold))
                .foregroundStyle(PawprintTheme.textSecondary)
                .textCase(.uppercase)
            TextField(placeholder, text: $text, axis: .vertical)
                .lineLimit(2...6)
                .focused(focus, equals: field)
                .padding(14)
                .frame(minHeight: 72, alignment: .topLeading)
                .background(PawprintTheme.surfaceRaised, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .foregroundStyle(PawprintTheme.textPrimary)
                .accessibilityLabel(label)
        }
    }
}
