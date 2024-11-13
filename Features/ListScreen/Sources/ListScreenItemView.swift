import SwiftUI
import ListScreenInterface
import Inject

struct ListScreenItemView: View {
    @ObserveInjection var inject
    let item: Item

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.title)
                .font(.headline)
            Text(item.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(item.createdAt, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
        .enableInjection()
    }
}
