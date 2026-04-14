import SwiftUI

struct ActivityRowView: View {
    let activity: Activity
    let store: AppDataStore

    var body: some View {
        HStack(spacing: 12) {
            // Category badge
            Circle()
                .fill(activity.category.color.opacity(0.15))
                .frame(width: 42, height: 42)
                .overlay {
                    Text(activity.category.emoji)
                        .font(.headline)
                }

            // Name + date
            VStack(alignment: .leading, spacing: 3) {
                Text(activity.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(TempoColor.ink)
                    .lineLimit(1)
                Text(AppDataStore.formatDisplayDate(activity.completionDate))
                    .font(.caption)
                    .foregroundStyle(TempoColor.slate)
            }

            Spacer()

            // Stats
            VStack(alignment: .trailing, spacing: 3) {
                Text(String(format: "%.1f mi", activity.distanceMiles))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(TempoColor.primary)
                Text("\(store.formatPace(activity.avgPaceSecondsPerMile))/mi")
                    .font(.caption)
                    .foregroundStyle(TempoColor.slate)
            }
        }
    }
}
