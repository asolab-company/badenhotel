import SwiftUI

struct NewsItem: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let subtitle: String
}

struct NewsListView: View {

    private let items: [NewsItem] = [
        NewsItem(
            imageName: "n_1",
            title: "Baden-Baden Casino Reports Strong Growth in Spring Season",
            subtitle:
                "The iconic Casino Baden-Baden announced a significant rise in visitor numbers this spring, crediting its renovated gaming halls and new digital roulette tables. Management says the casino is attracting a younger international audience while maintaining its historic charm."
        ),
        NewsItem(
            imageName: "n_2",
            title:
                "Cultural Gala Held at Casino Baden-Baden Draws European Celebrities",
            subtitle:
                "Last weekend, Casino Baden-Baden hosted a glamorous charity gala featuring musicians, actors, and philanthropists from across Europe. The event raised funds for regional art programs and highlighted the casino’s role as a cultural hub, not just a gaming destination."
        ),
        NewsItem(
            imageName: "n_3",
            title: "Baden-Baden Casino Launches Gourmet Festival",
            subtitle:
                "In an effort to expand its culinary offerings, Casino Baden-Baden has introduced a month-long Gourmet Festival, inviting award-winning local chefs to create exclusive menus. Visitors can enjoy themed dining nights combining haute cuisine with live entertainment."
        ),
    ]

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 18) {
                    ForEach(items) { item in
                        NewsCardLinkView(item: item)
                    }
                }
                .padding(.horizontal, 5)
                .padding(.bottom, 24)
            }
            .background(
                LinearGradient(
                    colors: [Color(hex: "180F22"), Color(hex: "383164")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct NewsCardLinkView: View {
    let item: NewsItem

    var body: some View {
        NavigationLink {
            NewsDetailsView(item: item)
        } label: {
            NewsCardView(item: item)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct NewsDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    let item: NewsItem

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "180F22"), Color(hex: "383164")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        Image(item.imageName)
                            .resizable()
                            .scaledToFill()
                            .padding(.top)
                            .clipped()

                        VStack(alignment: .leading, spacing: 14) {
                            Text(item.title)
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .heavy))

                            Text(item.subtitle)
                                .foregroundColor(.white.opacity(0.92))
                                .font(.system(size: 15, weight: .regular))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    }
                }
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)

        .toolbarBackground(.visible, for: .navigationBar)
    }
}

struct NewsCardView: View {

    let item: NewsItem

    var body: some View {
        ZStack(alignment: .bottom) {

            VStack(alignment: .leading, spacing: 10) {
                Image(item.imageName)
                    .resizable()
                    .scaledToFill()
                Text(item.title)
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .heavy))
                    .lineLimit(3)

                Text(item.subtitle)
                    .foregroundColor(.white.opacity(0.9))
                    .font(.system(size: 15, weight: .regular))
                    .lineLimit(2)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [
                        Color(hex: "2B2547").opacity(0.00),
                        Color(hex: "2B2547").opacity(0.92),
                        Color(hex: "2B2547").opacity(0.98),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                )
            )
        }
        .frame(maxWidth: .infinity)
        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 8)
    }
}

#Preview("NewsListView") {
    NewsListView()
        .preferredColorScheme(.dark)
}

#Preview("NewsDetailsView") {
    NavigationStack {
        NewsDetailsView(
            item: NewsItem(
                imageName: "n_1",
                title:
                    "Baden-Baden Casino Reports Strong Growth in Spring Season",
                subtitle:
                    "The iconic Casino Baden-Baden announced a significant rise in visitor numbers this spring, crediting its renovated gaming halls and new digital roulette tables. Management says the casino is attracting a younger international audience while maintaining its historic charm."
            )
        )
    }
    .preferredColorScheme(.dark)
}
