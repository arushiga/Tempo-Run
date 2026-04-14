import SwiftUI

struct ActivityRowView: View {
    let activity: Activity
    let store: AppDataStore

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(activity.category.color.opacity(0.12))
                .frame(width: 42, height: 42)
                .overlay {
                    Image(systemName: iconName(for: activity.category))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(activity.category.color)
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(activity.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(TempoColor.ink)
                    .lineLimit(1)
                Text(AppDataStore.formatDisplayDate(activity.completionDate))
                    .font(.caption).foregroundStyle(TempoColor.slate)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(String(format: "%.1f mi", activity.distanceMiles))
                    .font(.subheadline.weight(.semibold)).foregroundStyle(TempoColor.primary)
                Text("\(store.formatPace(activity.avgPaceSecondsPerMile))/mi")
                    .font(.caption).foregroundStyle(TempoColor.muted)
            }
        }
    }

    private func iconName(for category: RunCategory) -> String {
        switch category {
        case .easy:
            "figure.run"
        case .tempo:
            "bolt.fill"
        case .long:
            "road.lanes"
        case .race:
            "flag.checkered"
        }
    }
}
