//
//  DashboardComponents.swift
//  Dashboard feature (Natalie)
//
//  Small reusable pieces used by the Home, Onboarding and Profile screens.
//

import SwiftUI

/// Circular photo or pug fallback for a dog.
struct DogAvatarView: View {
    let photoData: Data?
    var size: CGFloat = 72

    var body: some View {
        Group {
            if let data = photoData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image("PugFront")
                    .resizable()
                    .scaledToFit()
                    .padding(size * 0.12)
                    .background(PawprintTheme.surfaceRaised)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().stroke(PawprintTheme.border.opacity(0.6), lineWidth: 1))
        .accessibilityHidden(true)
    }
}

/// Ring showing how much of today is done.
struct ProgressRingView: View {
    let progress: TodayProgress
    var lineWidth: CGFloat = 10

    var body: some View {
        ZStack {
            Circle()
                .stroke(PawprintTheme.border.opacity(0.4), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress.fraction)
                .stroke(progress.isAllDone ? PawprintTheme.success : PawprintTheme.accent,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.6), value: progress.fraction)
            VStack(spacing: 0) {
                Text("\(progress.completed)/\(progress.total)")
                    .font(PawprintTheme.font(.title3, weight: .heavy))
                    .foregroundStyle(PawprintTheme.textPrimary)
                Text("done")
                    .font(PawprintTheme.font(.caption2, weight: .semibold))
                    .foregroundStyle(PawprintTheme.textSecondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Today's progress")
        .accessibilityValue("\(progress.completed) of \(progress.total) activities done")
    }
}

/// Friendly empty state with a pug.
struct PugEmptyState: View {
    let image: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 10) {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(height: 110)
                .accessibilityHidden(true)
            Text(title)
                .font(PawprintTheme.font(.headline, weight: .semibold))
                .foregroundStyle(PawprintTheme.textPrimary)
            Text(message)
                .font(PawprintTheme.font(.subheadline))
                .foregroundStyle(PawprintTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

/// Labelled text field used across the dog forms.
struct DogFormField<Field: Hashable>: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var focus: FocusState<Field?>.Binding
    let field: Field

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(PawprintTheme.font(.caption, weight: .bold))
                .foregroundStyle(PawprintTheme.textSecondary)
                .textCase(.uppercase)
            TextField(placeholder, text: $text)
                .keyboardType(keyboard)
                .focused(focus, equals: field)
                .padding(.horizontal, 14)
                .frame(minHeight: 48)
                .background(PawprintTheme.surfaceRaised, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .foregroundStyle(PawprintTheme.textPrimary)
                .accessibilityLabel(label)
        }
    }
}

/// Brown pill button used for primary actions.
struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(PawprintTheme.font(.headline, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(minHeight: 52)
                .background(PawprintTheme.accentDeep, in: Capsule())
                .foregroundStyle(PawprintTheme.onAccent)
        }
        .buttonStyle(.plain)
    }
}

/// Label for the photo picker. Lives in its own view so it stays on the main actor.
struct PhotoPickerLabel: View {
    let photoData: Data?
    var size: CGFloat = 108
    let title: String

    var body: some View {
        VStack(spacing: 8) {
            DogAvatarView(photoData: photoData, size: size)
            Text(title)
                .font(PawprintTheme.font(.footnote, weight: .semibold))
                .foregroundStyle(PawprintTheme.accent)
        }
    }
}
