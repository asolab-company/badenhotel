import SwiftUI

struct Setting: View {

    @Environment(\.openURL) private var openURL
    @State private var showShare = false

    var body: some View {
        ZStack(alignment: .top) {

            VStack(spacing: 0) {

                SettingsRow(
                    icon: "app_ic_share",
                    title: "Share app",
                    action: { showShare = true }
                ).padding(.top, 20)

                SettingsRow(
                    icon: "app_ic_terms",
                    title: "Terms and Conditions",
                    action: { openURL(Data.terms) }
                )

                SettingsRow(
                    icon: "app_ic_privacy",
                    title: "Privacy",
                    action: { openURL(Data.policy) }
                )

                Spacer()

            }

        }
        .sheet(isPresented: $showShare) {
            ShareSheet(items: Data.shareItems)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }

    }

}

private struct SettingsRow: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)

                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "ffffff"))
            }
            .padding(.horizontal, 20)
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .background(Color(hex: "6660A0").opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
        .padding(.vertical, 6)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
    }
    func updateUIViewController(
        _ vc: UIActivityViewController,
        context: Context
    ) {}
}

#Preview {
    Setting()
}
