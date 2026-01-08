import SwiftUI

struct WelcomeView: View {
    var onContinue: () -> Void = {}

    var body: some View {
        ZStack(alignment: .top) {

            GeometryReader { geo in
                VStack {
                    Spacer()

                    VStack(spacing: 5) {

                        Image("app_girl")
                            .resizable()
                            .scaledToFit()

                        Group {
                            Text("Welcome to Baden-Baden ✨")
                                .foregroundColor(Color(hex: "ffffff"))
                                .font(
                                    .system(
                                        size: Device.isSmall ? 20 : 24,
                                        weight: .heavy
                                    )
                                )

                            Text("• Discover top casino hotels 🏨")
                                .foregroundColor(Color(hex: "FFC800"))
                                .font(
                                    .system(
                                        size: Device.isSmall ? 16 : 18,
                                        weight: .heavy
                                    )
                                )

                            Text(
                                "curated stays for every taste."
                            )
                            .foregroundColor(Color(hex: "ffffff"))
                            .font(
                                .system(
                                    size: Device.isSmall ? 12 : 14,
                                    weight: .regular
                                )
                            )
                            .multilineTextAlignment(.leading)

                            Text("• Experience luxury & fun 🎲💎")
                                .foregroundColor(Color(hex: "FFC800"))
                                .font(
                                    .system(
                                        size: Device.isSmall ? 16 : 18,
                                        weight: .heavy
                                    )
                                )

                            Text(
                                "spas, gaming, and nightlife."
                            )
                            .foregroundColor(Color(hex: "ffffff"))
                            .font(
                                .system(
                                    size: Device.isSmall ? 12 : 14,
                                    weight: .regular
                                )
                            )
                            .multilineTextAlignment(.leading)

                            Text("• Explore local gems 🌿♨️")
                                .foregroundColor(Color(hex: "FFC800"))
                                .font(
                                    .system(
                                        size: Device.isSmall ? 16 : 18,
                                        weight: .heavy
                                    )
                                )

                            Text(
                                "dining, attractions, and insider tips."
                            )
                            .foregroundColor(Color(hex: "ffffff"))
                            .font(
                                .system(
                                    size: Device.isSmall ? 12 : 14,
                                    weight: .regular
                                )
                            )
                            .multilineTextAlignment(.leading)
                            .padding(.bottom)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Button(action: { onContinue() }) {
                            ZStack {
                                Text("Start Your Journey")
                                    .font(.system(size: 20, weight: .semibold))
                                HStack {
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(
                                            .system(size: 18, weight: .bold)
                                        )
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(BtnStyle(height: Device.isSmall ? 40 : 56))
                        .padding(.bottom, 8)

                        TermsFooter().padding(
                            .bottom,
                            Device.isSmall ? 20 : 60
                        )
                    }
                    .padding(.horizontal, 30)

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }.ignoresSafeArea()
            .background(
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(hex: "000000"),
                            Color(hex: "000000"),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()

                    Image("app_ic_welcome")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()

                }

            )
    }
}

private struct TermsFooter: View {
    var body: some View {
        VStack(spacing: 2) {
            Text("By Proceeding You Accept")
                .foregroundColor(Color.init(hex: "6660A0"))
                .font(.footnote)

            HStack(spacing: 0) {
                Text("Our ")
                    .foregroundColor(Color.init(hex: "6660A0"))
                    .font(.footnote)

                Link("Terms Of Use", destination: Data.terms)
                    .font(.footnote)
                    .foregroundColor(Color.init(hex: "FFA600"))

                Text(" And ")
                    .foregroundColor(Color.init(hex: "6660A0"))
                    .font(.footnote)

                Link("Privacy Policy", destination: Data.policy)
                    .font(.footnote)
                    .foregroundColor(Color.init(hex: "FFA600"))

            }
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }
}

#Preview {
    WelcomeView {
        print("Finished")
    }
}
