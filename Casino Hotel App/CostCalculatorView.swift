import SwiftUI

struct CostCalculatorView: View {

    @State private var checkIn: Date = Calendar.current.startOfDay(for: .now)
    @State private var checkOut: Date = {
        let today = Calendar.current.startOfDay(for: .now)
        return Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today
    }()

    @State private var adults: Int = 2
    @State private var childs: Int = 0

    @State private var wifi: Bool = false
    @State private var tv: Bool = false
    @State private var ac: Bool = true

    private enum DateField: String, Identifiable {
        case checkIn
        case checkOut

        var id: String { rawValue }

        var title: String {
            switch self {
            case .checkIn: return "Check-in Date"
            case .checkOut: return "Departure Date"
            }
        }
    }

    @State private var activeDateField: DateField? = nil

    private let basePerNight: Double = 100.0
    private let extraAdultFactor: Double = 0.5
    private let extraServiceFactor: Double = 0.2

    private var nights: Int {
        let start = Calendar.current.startOfDay(for: checkIn)
        let end = Calendar.current.startOfDay(for: checkOut)
        let d =
            Calendar.current.dateComponents([.day], from: start, to: end).day
            ?? 0
        return max(1, d)
    }

    private func normalizeDatesIfNeeded() {
        if checkOut <= checkIn {
            checkOut =
                Calendar.current.date(byAdding: .day, value: 1, to: checkIn)
                ?? checkIn
        }
    }

    private var selectedServicesCount: Int {
        [wifi, tv, ac].filter { $0 }.count
    }

    private var totalCost: Int {
        let safeAdults = max(1, adults)
        let extraAdults = max(0, safeAdults - 1)

        let nightly =
            basePerNight
            + (Double(extraAdults) * basePerNight * extraAdultFactor)
        let nightlyWithServices =
            nightly
            * (1.0 + (Double(selectedServicesCount) * extraServiceFactor))
        let total = nightlyWithServices * Double(nights)

        return Int(total.rounded())
    }

    var body: some View {
        ZStack {

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    dateRow(title: "Check-in Date", date: $checkIn) {
                        activeDateField = .checkIn
                    }
                    dateRow(title: "Departure Date", date: $checkOut) {
                        activeDateField = .checkOut
                    }

                    stepRow(title: "Adults", value: $adults, minValue: 1)
                    stepRow(title: "Childs", value: $childs, minValue: 0)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Additional services:")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .regular))
                            .padding(.top, 10)

                        serviceRow(icon: "wifi", title: "WiFi", isOn: $wifi)
                        serviceRow(icon: "tv", title: "TV", isOn: $tv)
                        serviceRow(icon: "snowflake", title: "AC", isOn: $ac)
                    }
                    .padding(.top, 8)

                    costFooter
                        .padding(.top, 8)

                    Spacer(minLength: 16)
                }
                .padding(.horizontal, 16)
                .padding(.top, 18)
            }
            .sheet(item: $activeDateField) { field in
                let binding: Binding<Date> = {
                    switch field {
                    case .checkIn: return $checkIn
                    case .checkOut: return $checkOut
                    }
                }()

                VStack(spacing: 16) {
                    Text(field.title)
                        .font(.system(size: 18, weight: .semibold))
                        .padding(.top, 8)

                    DatePicker(
                        "",
                        selection: binding,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .onChange(of: binding.wrappedValue) { _ in
                        normalizeDatesIfNeeded()
                    }

                    Button {
                        activeDateField = nil
                    } label: {
                        Text("Done")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(
                                RoundedRectangle(
                                    cornerRadius: 12,
                                    style: .continuous
                                )
                                .fill(Color(hex: "FFA600"))
                            )
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                }
                .padding(16)
                .presentationDetents([
                    .height(
                        UIScreen.main.bounds.height
                            * (UIScreen.main.bounds.height < 750 ? 0.72 : 0.62)
                    )
                ])
                .presentationDragIndicator(.visible)
            }
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color(hex: "0F0D13"),
                Color(hex: "2A2353"),
                Color(hex: "0F0D13"),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private func cardBackground() -> some ShapeStyle {
        LinearGradient(
            colors: [
                Color(hex: "6660A0").opacity(0.3),
                Color(hex: "6660A0").opacity(0.3),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func dateRow(
        title: String,
        date: Binding<Date>,
        onTap: @escaping () -> Void
    ) -> some View {
        GeometryReader { geo in
            let w = geo.size.width
            let isSmall = w < 360
            let dateW = min(180, w * 0.46)

            HStack(spacing: 12) {
                Text(title)
                    .foregroundColor(Color(hex: "6660A0"))
                    .font(.system(size: isSmall ? 15 : 17, weight: .regular))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .minimumScaleFactor(0.85)

                Spacer(minLength: 8)

                ZStack {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(Color(hex: "6660A0").opacity(0.3))

                    Text(
                        date.wrappedValue,
                        format: .dateTime.day().month().year()
                    )
                    .foregroundColor(.white)
                    .font(.system(size: isSmall ? 16 : 18, weight: .regular))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .padding(.horizontal, 10)
                }
                .frame(width: dateW, height: 40)
            }
            .padding(.leading)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(cardBackground())
            )
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
        }
        .frame(height: 40)
    }

    private func stepRow(title: String, value: Binding<Int>, minValue: Int)
        -> some View
    {
        GeometryReader { geo in
            let w = geo.size.width
            let isSmall = w < 360
            let btn = min(40.0, max(32.0, w * 0.12))
            let valueW = min(70.0, max(44.0, w * 0.18))

            HStack(spacing: 12) {
                Text(title)
                    .foregroundColor(Color(hex: "6660A0"))
                    .font(.system(size: isSmall ? 15 : 17, weight: .regular))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Spacer(minLength: 8)

                stepButton(
                    symbol: "minus",
                    enabled: value.wrappedValue > minValue,
                    size: btn
                ) {
                    value.wrappedValue = max(minValue, value.wrappedValue - 1)
                }

                Text("\(value.wrappedValue)")
                    .foregroundColor(.white)
                    .font(.system(size: isSmall ? 16 : 18, weight: .regular))
                    .frame(width: valueW)

                stepButton(symbol: "plus", enabled: true, size: btn) {
                    value.wrappedValue += 1
                }
            }
            .padding(.leading)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(cardBackground())
            )
        }
        .frame(height: 40)
    }

    private func stepButton(
        symbol: String,
        enabled: Bool,
        size: CGFloat,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(hex: "FFA600").opacity(enabled ? 1.0 : 0.45))
                    .frame(width: size, height: size)

                Image(systemName: symbol)
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }

    private func serviceRow(icon: String, title: String, isOn: Binding<Bool>)
        -> some View
    {
        Button {
            isOn.wrappedValue.toggle()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.white)
                    .frame(width: 34)

                Text(title)
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .regular))

                Spacer()

                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.85), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isOn.wrappedValue {
                        Circle()
                            .fill(Color(hex: "FFA600"))
                            .frame(width: 24, height: 24)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .heavy))
                                    .foregroundColor(.white)
                            )
                    }
                }
                .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16)
            .frame(height: 60)
            .background(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(cardBackground())
            )
        }
        .buttonStyle(.plain)
    }

    private var costFooter: some View {
        HStack {
            Text("Cost:")
                .foregroundColor(Color(hex: "FFA600"))
                .font(.system(size: 20, weight: .heavy))

            Spacer()

            Text("\(totalCost)")
                .foregroundColor(.white)
                .font(.system(size: 22, weight: .heavy))
        }
        .padding(.horizontal, 18)
        .frame(height: 56)
        .background(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "8A5D2B").opacity(0.85),
                            Color(hex: "6E4A2A").opacity(0.85),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
    }
}

#Preview("CostCalculatorView") {

    CostCalculatorView()

}
