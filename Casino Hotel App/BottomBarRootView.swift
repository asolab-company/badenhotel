import SwiftUI

enum BottomTab: Int, CaseIterable {
    case map, calc, center, docs, settings

    var asset: String {
        switch self {
        case .map: return "app_btn_menu03"
        case .calc: return "app_btn_menu04"
        case .center: return "app_btn_menu00"
        case .docs: return "app_btn_menu02"
        case .settings: return "app_btn_menu01"
        }
    }
}

struct BottomBarRootView: View {

    @State private var selected: BottomTab = .center
    @State private var topBarTitleState: String = "Baden-Baden Hotels"
    @State private var topBarIconState: String = "app_btn_menu00"

    private func syncTopBar(with tab: BottomTab) {
        switch tab {
        case .map:
            topBarTitleState = "Map Baden-Baden"
            topBarIconState = "app_btn_menu03"
        case .calc:
            topBarTitleState = "Cost Calculation"
            topBarIconState = "app_btn_menu04"
        case .center:
            topBarTitleState = "Baden-Baden Hotels"
            topBarIconState = "app_btn_menu00"
        case .docs:
            topBarTitleState = "News"
            topBarIconState = "app_btn_menu02"
        case .settings:
            topBarTitleState = "Settings"
            topBarIconState = "app_btn_menu01"
        }
    }

    var body: some View {
        GeometryReader { geo in
            let topInset = geo.safeAreaInsets.top
            let bottomInset = geo.safeAreaInsets.bottom

            ZStack {
                VStack {
                    Text("selected=\(selected.rawValue)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.top, 4)
                    Spacer()
                }
                .allowsHitTesting(false)

                VStack(spacing: 0) {
                    VStack {

                        Spacer()
                        HStack {
                            Image(topBarIconState)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 30, height: 30)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(topBarTitleState)
                                    .foregroundColor(.white)
                                    .font(
                                        .system(
                                            size: Device.isSmall ? 20 : 24,
                                            weight: .heavy
                                        )
                                    )
                            }
                            .padding(.leading, 10)

                            Spacer()
                        }
                        .padding(.bottom, 12)
                        .padding(.horizontal)
                    }
                    .frame(height: 50 + topInset)
                    .frame(maxWidth: .infinity)

                    .background(
                        Rectangle()
                            .fill(Color(hex: "0F0D13"))

                            .ignoresSafeArea(.container, edges: .top)
                    )

                    TabView(selection: $selected) {
                        MapScreen()
                            .tag(BottomTab.map)

                        CostCalculatorView()
                            .tag(BottomTab.calc)

                        PlacesListView()
                            .tag(BottomTab.center)

                        NewsListView()
                            .tag(BottomTab.docs)

                        Setting()
                            .tag(BottomTab.settings)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    CustomBottomBar(
                        selected: $selected,
                        bottomInset: bottomInset
                    )
                }
            }
            .ignoresSafeArea()
        }
        .onAppear {
            syncTopBar(with: selected)
        }
        .onChange(of: selected) { newValue in
            syncTopBar(with: newValue)
            print(
                "✅ selected changed -> \(newValue) | title=\(topBarTitleState) | icon=\(topBarIconState)"
            )
        }
        .background(
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "180F22"),
                        Color(hex: "383164"),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

            }

        )
    }
}

struct CustomBottomBar: View {

    @Binding var selected: BottomTab
    let bottomInset: CGFloat

    private let barColor = Color.init(hex: "00031B")
    private let iconOff = Color(hex: "#6E67A9")
    private let iconOn = Color(hex: "#FFA600")

    var body: some View {
        ZStack(alignment: .top) {

            Rectangle()
                .fill(barColor)
                .frame(height: 80 + bottomInset)
                .allowsHitTesting(false)
                .zIndex(0)

            centerButton
                .offset(y: -10)
                .zIndex(1)

            HStack {
                tabButton(.map)
                Spacer()
                tabButton(.calc)

                Spacer().frame(width: Device.isSmall ? 100 : 120)

                tabButton(.docs)
                Spacer()
                tabButton(.settings)
            }
            .padding(.horizontal, Device.isSmall ? 10 : 20)
            .padding(.top, 10)
            .zIndex(2)
        }

    }

    private func tabButton(_ tab: BottomTab) -> some View {
        Button {
            selected = tab
            print("👆 tab tap -> \(tab)")
        } label: {
            Image(tab.asset)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundColor(selected == tab ? iconOn : iconOff)
                .frame(width: 40, height: 40)
                .frame(width: 56, height: 56)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var centerButton: some View {
        Button {
            selected = .center
            print("👆 center tap")
        } label: {
            ZStack {
                let isOn = selected == .center

                Circle()
                    .fill(
                        RadialGradient(
                            colors: isOn
                                ? [Color(hex: "FFC21A"), Color(hex: "EF8F00")]
                                : [Color(hex: "786BBA"), Color(hex: "5A5186")],
                            center: .center,
                            startRadius: 2,
                            endRadius: 46
                        )
                    )
                    .overlay(
                        Circle()
                            .stroke(Color(hex: "00031B"), lineWidth: 14)
                    )
                    .frame(
                        width: Device.isSmall ? 80 : 100,
                        height: Device.isSmall ? 80 : 100
                    )
                    .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 6)

                Image(BottomTab.center.asset)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(
                        selected == .center
                            ? Color(hex: "9F3700") : Color(hex: "281F59")
                    )
                    .frame(width: 30, height: 30)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview("BottomBarRootView") {
    BottomBarRootView()
}
