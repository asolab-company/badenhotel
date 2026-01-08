import CoreLocation
import MapKit
import SwiftUI

struct PlaceItem: Identifiable {
    let id = UUID()

    let heroImage: String
    let rating: Double

    let title: String
    let typeLine: String
    let description: String

    let galleryImages: [String]
    let address: String
}

struct PlaceView: View {
    let item: PlaceItem

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            PlaceCardView(item: item, showsMap: true)
        }
        .background(
            LinearGradient(
                colors: [Color(hex: "180F22"), Color(hex: "383164")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationTitle(item.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)

        .toolbarBackground(.visible, for: .navigationBar)
    }
}

private struct PlaceCardView: View {
    let item: PlaceItem
    let showsMap: Bool

    @State private var displayedHeroImage: String? = nil

    @State private var userRating: Int = 0
    private var ratingKey: String {

        "place_user_rating_\(item.title)"
    }

    @State private var mapCoordinate: CLLocationCoordinate2D? = nil
    @State private var mapRegion: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 48.7606, longitude: 8.2398),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )

    var body: some View {
        VStack(spacing: 0) {

            ZStack(alignment: .topTrailing) {
                Image(displayedHeroImage ?? item.heroImage)
                    .resizable()
                    .scaledToFill()

                    .clipped()

                ratingBadge(item.rating)
                    .padding(.top, 14)
                    .padding(.trailing, 14)
            }.padding(.top)

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .heavy))
                    .lineLimit(2)

                Text(item.typeLine)
                    .foregroundColor(Color(hex: "00C2FF"))
                    .font(.system(size: 15, weight: .regular))
                    .lineLimit(1)

                Text(item.description)
                    .foregroundColor(.white)
                    .font(.system(size: 15, weight: .regular))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(infoGradient)

            HStack(spacing: 0) {
                ForEach(
                    Array(item.galleryImages.prefix(3).enumerated()),
                    id: \.offset
                ) { _, img in
                    Image(img)
                        .resizable()
                        .scaledToFill()

                        .frame(maxWidth: .infinity)
                        .clipped()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.18)) {
                                displayedHeroImage = img
                            }
                        }
                }
            }
            if showsMap {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Rate this hotel")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)

                    GeometryReader { geo in
                        HStack(spacing: 5) {
                            ForEach(1...5, id: \.self) { index in
                                Image(systemName: "star.fill")
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundColor(
                                        index <= userRating
                                            ? Color(hex: "FFC21A")
                                            : Color(hex: "6A66A8")
                                    )
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation(
                                            .easeInOut(duration: 0.12)
                                        ) {
                                            userRating = index
                                        }
                                    }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let x = max(
                                        0,
                                        min(value.location.x, geo.size.width)
                                    )
                                    let step = geo.size.width / 5.0
                                    let newValue = Int(ceil(x / step))
                                    let clamped = max(0, min(5, newValue))
                                    if clamped != userRating {
                                        userRating = clamped
                                    }
                                }
                        )
                    }
                    .frame(height: 44)
                }.padding(.horizontal, 18)
                    .padding(.top)
            }

            HStack(spacing: 12) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "4B931D"))

                Text(item.address)
                    .foregroundColor(Color(hex: "6660A0"))
                    .font(.system(size: 15, weight: .medium))
                    .lineLimit(2)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(infoGradient)

            if showsMap {

                VStack(spacing: 0) {
                    if let coord = mapCoordinate {
                        Map(
                            coordinateRegion: $mapRegion,
                            annotationItems: [MapPinItem(coordinate: coord)]
                        ) { pin in
                            MapMarker(coordinate: pin.coordinate)
                        }
                        .frame(height: 300)

                    } else {
                        Map(coordinateRegion: $mapRegion)
                            .frame(height: 300)

                    }
                }

                .padding(.top, 10)
                .padding(.bottom, 14)

            }
        }
        .onAppear {

            userRating = UserDefaults.standard.integer(forKey: ratingKey)

            if showsMap {
                geocodeAddressIfNeeded()
            }
        }
        .onChange(of: userRating) { newValue in
            UserDefaults.standard.set(newValue, forKey: ratingKey)
        }
    }

    private struct MapPinItem: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
    }

    private func geocodeAddressIfNeeded() {
        guard mapCoordinate == nil else { return }

        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(item.address) { placemarks, error in
            guard error == nil else { return }
            guard let coord = placemarks?.first?.location?.coordinate else {
                return
            }

            DispatchQueue.main.async {
                mapCoordinate = coord
                mapRegion = MKCoordinateRegion(
                    center: coord,
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.005,
                        longitudeDelta: 0.005
                    )
                )
            }
        }
    }

    private var infoGradient: some View {
        LinearGradient(
            colors: [
                Color(hex: "2B2547").opacity(0.85),
                Color(hex: "2B2547").opacity(0.96),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func ratingBadge(_ rating: Double) -> some View {
        HStack(spacing: 5) {
            Image(systemName: "star.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(hex: "FFC21A"))

            Text(String(format: "%.1f", rating))
                .font(.system(size: 16, weight: .heavy))
                .foregroundColor(Color(hex: "FFC21A"))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.white, lineWidth: 1)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.black.opacity(0.65))
                )
        )
    }
}

struct PlacesListView: View {
    private let items = PlacesLocalData.items

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    ForEach(items) { item in
                        NavigationLink {
                            PlaceView(item: item)
                        } label: {
                            PlaceCardView(item: item, showsMap: false)
                        }
                        .buttonStyle(.plain)
                    }
                }

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

        }
    }
}

struct PlacesLocalData {
    static let items: [PlaceItem] = [
        PlaceItem(
            heroImage: "h_1_1",
            rating: 5.0,
            title: "Maison Messmer Baden-Baden",
            typeLine: "Luxury hotel",
            description:
                "Prestigious historic-style hotel with spacious rooms, gourmet dining, a large spa (800 m²), pool, and excellent service.",
            galleryImages: ["h_1_2", "h_1_3", "h_1_4"],
            address: "Werderstraße 1, 76530 Baden-Baden, Germany"
        ),
        PlaceItem(
            heroImage: "h_2_1",
            rating: 5.0,
            title: "Brenners Park-Hotel & Spa",
            typeLine: "Luxury spa hotel",
            description:
                "One of Germany’s most famous luxury hotels. Offers world-class spa facilities, elegant rooms, and a scenic park setting. 10–12 minutes’ walk to the casino.",
            galleryImages: ["h_2_2", "h_2_3", "h_2_4"],
            address: "Schillerstraße 4/6, 76530 Baden-Baden, Germany"
        ),
        PlaceItem(
            heroImage: "h_3_1",
            rating: 5.0,
            title: "Roomers Baden-Baden",
            typeLine: "Design & lifestyle hotel",
            description:
                "Modern luxury hotel with rooftop bar, outdoor pool, spa, and vibrant nightlife atmosphere. Very close to the city center.",
            galleryImages: ["h_3_2", "h_3_3", "h_3_4"],
            address: "Lange Str. 100, 76530 Baden-Baden, Germany"
        ),
        PlaceItem(
            heroImage: "h_4_1",
            rating: 4.0,
            title: "Hotel Belle Epoque",
            typeLine: "Boutique hotel",
            description:
                "Elegant Belle-Époque-style villa with antique interiors, peaceful gardens, and charming rooms. 5–7 minutes’ walk to the casino.",
            galleryImages: ["h_4_2", "h_4_3", "h_4_4"],
            address: "Maria-Viktoria-Str. 2C, 76530 Baden-Baden, Germany"
        ),
        PlaceItem(
            heroImage: "h_5_1",
            rating: 4.0,
            title: "Der Kleine Prinz",
            typeLine: "Boutique hotel",
            description:
                "Romantic historic hotel inspired by “The Little Prince,” with themed rooms, fine dining, and cozy atmosphere. Near Kurpark and casino.",
            galleryImages: ["h_5_2", "h_5_3", "h_5_4"],
            address: "Lichtentaler Str. 36, 76530 Baden-Baden, Germany"
        ),
        PlaceItem(
            heroImage: "h_6_1",
            rating: 4.0,
            title: "Radisson Blu Badischer Hof",
            typeLine: "Historic spa hotel",
            description:
                "Located in a former monastery, with an indoor/outdoor thermal pool, wellness area, and large rooms. 10 min by foot to the casino.",
            galleryImages: ["h_6_2", "h_6_3", "h_6_4"],
            address: "Lange Str. 47, 76530 Baden-Baden, Germany"
        ),
        PlaceItem(
            heroImage: "h_7_1",
            rating: 4.0,
            title: "Leonardo Royal Hotel Baden-Baden",
            typeLine: "Comfort + wellness hotel",
            description:
                "Spacious rooms, balcony views, spa, sauna, and indoor pool. About 15 minutes’ walk from the casino.",
            galleryImages: ["h_7_2", "h_7_3", "h_7_4"],
            address: "Falkenstraße 2, 76530 Baden-Baden, Germany"
        ),
        PlaceItem(
            heroImage: "h_8_1",
            rating: 4.5,
            title: "Hotel Merkur Baden-Baden",
            typeLine: "Classic city hotel",
            description:
                "Clean, modern rooms, good breakfast, and excellent central location just 5 minutes from casino.",
            galleryImages: ["h_8_2", "h_8_3", "h_8_4"],
            address: "Merkurstraße 8–10, 76530 Baden-Baden, Germany"
        ),
        PlaceItem(
            heroImage: "h_9_1",
            rating: 4.5,
            title: "Hotel am Markt",
            typeLine: "Traditional guesthouse hotel",
            description:
                "Charming, quiet hotel in the Old Town with friendly atmosphere. About 6 minutes from casino by foot.",
            galleryImages: ["h_9_2", "h_9_3", "h_9_4"],
            address: "Marktplatz 18, 76530 Baden-Baden, Germany"
        ),
        PlaceItem(
            heroImage: "h_10_1",
            rating: 4.5,
            title: "Casino Baden-Baden",
            typeLine: "Historic Casino & Spa Resort",
            description:
                "World’s most beautiful casino in a Bell Epoque palace with luxury spa facilities.",
            galleryImages: ["h_10_2", "h_10_3", "h_10_4"],
            address: "Kaiserallee 1, 76530 Baden-Baden, Germany"
        ),
    ]
}

#Preview("PlaceDetailsView") {
    PlaceView(item: PlacesLocalData.items.last!)

}

#Preview("PlacesListView") {
    PlacesListView()

}
