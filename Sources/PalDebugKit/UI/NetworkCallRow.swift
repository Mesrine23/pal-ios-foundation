#if canImport(UIKit)
import SwiftUI

/// A single network-call row — status · method · URL — shared by the Logs and Mocks tabs.
struct NetworkCallRow: View {

    let entry: NetworkLogEntry

    var body: some View {
        HStack(spacing: 10) {
            Text(entry.statusCode.map(String.init) ?? "—")
                .font(.caption.monospacedDigit().bold())
                .foregroundStyle(color)
                .frame(width: 38, alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.method).font(.caption.bold())
                Text(entry.url).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
            }
        }
    }

    private var color: Color {
        guard let code = entry.statusCode else { return .secondary }
        switch code {
        case 200..<300: return .green
        case 300..<400: return .blue
        case 400..<500: return .orange
        default: return .red
        }
    }
}
#endif
