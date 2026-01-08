import SwiftUI

struct Loading: View {
    var onFinish: () -> Void
    @State private var progress: CGFloat = 0.0
    @State private var isFinished = false
    @State private var timer: Timer? = nil

    private let duration: Double = 1.5
    private var barWidth: CGFloat { UIScreen.main.bounds.width - 100 }

    var body: some View {
        ZStack {

            VStack(spacing: 28) {

                Spacer()

                Image("app_ic_logo")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 70)
                Spacer()
                VStack(spacing: 10) {
                    Text("\(Int(progress * 100))%")
                        .foregroundColor(.white)
                        .font(.custom("blippo", size: 18))
                        .padding(.top)

                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(hex: "6660A0"))
                            .frame(width: barWidth, height: 2)

                        Capsule()
                            .fill(Color(hex: "#FFFFFF"))
                            .frame(
                                width: max(
                                    0,
                                    min(barWidth * progress, barWidth)
                                ),
                                height: 2
                            )
                    }

                }
                .offset(y: -51)

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

        }
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

                Image("loading_bg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

            }

        )
        .onAppear {
            startProgress()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func startProgress() {
        progress = 0
        timer?.invalidate()

        let stepCount = 100
        let interval = duration / Double(stepCount)
        var tick = 0

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true)
        { t in
            tick += 1
            progress = min(1.0, CGFloat(tick) / CGFloat(stepCount))

            if tick >= stepCount {
                t.invalidate()
                isFinished = true
                onFinish()
            }
        }

        RunLoop.main.add(timer!, forMode: .common)
    }
}

#Preview {
    Loading {
        print("Finished")
    }
}
