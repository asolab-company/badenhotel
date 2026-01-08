import CoreLocation
import MapKit
import SwiftUI

struct MapScreen: View {

    struct Place: Identifiable, Equatable {
        let id = UUID()
        let title: String
        let subtitle: String
        let address: String
        let kind: Kind
        var coordinate: CLLocationCoordinate2D?

        enum Kind {
            case hotel
            case casino
        }

        static func == (lhs: Place, rhs: Place) -> Bool {

            let lhsCoord = lhs.coordinate
            let rhsCoord = rhs.coordinate

            let coordEqual: Bool
            switch (lhsCoord, rhsCoord) {
            case (nil, nil):
                coordEqual = true
            case (let l?, let r?):
                coordEqual =
                    abs(l.latitude - r.latitude) < 0.000001
                    && abs(l.longitude - r.longitude) < 0.000001
            default:
                coordEqual = false
            }

            return lhs.title == rhs.title
                && lhs.subtitle == rhs.subtitle
                && lhs.address == rhs.address
                && lhs.kind == rhs.kind
                && coordEqual
        }
    }

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 48.7606,
            longitude: 8.2398
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 0.08,
            longitudeDelta: 0.08
        )
    )

    @State private var places: [Place] = []
    @State private var didStartGeocoding = false

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: placesWithCoords) {
            place in
            MapAnnotation(coordinate: place.coordinate!) {
                VStack(spacing: 4) {
                    Image(
                        systemName: place.kind == .casino
                            ? "suit.club.fill" : "bed.double.fill"
                    )
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(
                        Circle().fill(Color.black.opacity(0.75))
                    )

                    Text(place.title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 10).fill(
                                Color.black.opacity(0.70)
                            )
                        )
                        .lineLimit(1)
                }
            }
        }
        .ignoresSafeArea()

        .onAppear {
            if !didStartGeocoding {
                didStartGeocoding = true
                seedPlacesIfNeeded()
                geocodeAllPlacesIfNeeded()
            }
        }
    }

    private var placesWithCoords: [Place] {
        places.filter { $0.coordinate != nil }
    }

    private func seedPlacesIfNeeded() {
        guard places.isEmpty else { return }

        places = [
            Place(
                title: "Maison Messmer",
                subtitle: "5★ Luxury hotel",
                address: "Werderstraße 1, 76530 Baden-Baden, Germany",
                kind: .hotel,
                coordinate: nil
            ),
            Place(
                title: "Brenners Park-Hotel & Spa",
                subtitle: "5★ Luxury spa",
                address: "Schillerstraße 4/6, 76530 Baden-Baden, Germany",
                kind: .hotel,
                coordinate: nil
            ),
            Place(
                title: "Roomers Baden-Baden",
                subtitle: "5★ Design hotel",
                address: "Lange Straße 100, 76530 Baden-Baden, Germany",
                kind: .hotel,
                coordinate: nil
            ),
            Place(
                title: "Hotel Belle Epoque",
                subtitle: "4★ Boutique",
                address: "Maria-Viktoria-Straße 2C, 76530 Baden-Baden, Germany",
                kind: .hotel,
                coordinate: nil
            ),
            Place(
                title: "Der Kleine Prinz",
                subtitle: "4★ Boutique",
                address: "Lichtentaler Straße 36, 76530 Baden-Baden, Germany",
                kind: .hotel,
                coordinate: nil
            ),
            Place(
                title: "Radisson Blu Badischer Hof",
                subtitle: "4★ Historic spa",
                address: "Lange Straße 47, 76530 Baden-Baden, Germany",
                kind: .hotel,
                coordinate: nil
            ),
            Place(
                title: "Leonardo Royal Hotel",
                subtitle: "4★ Wellness",
                address: "Falkenstraße 2, 76530 Baden-Baden, Germany",
                kind: .hotel,
                coordinate: nil
            ),
            Place(
                title: "Hotel Merkur",
                subtitle: "4★ City hotel",
                address: "Merkurstraße 8-10, 76530 Baden-Baden, Germany",
                kind: .hotel,
                coordinate: nil
            ),
            Place(
                title: "Hotel am Markt",
                subtitle: "4★ Guesthouse",
                address: "Marktplatz 18, 76530 Baden-Baden, Germany",
                kind: .hotel,
                coordinate: nil
            ),
            Place(
                title: "Casino Baden-Baden",
                subtitle: "Historic casino",
                address: "Kaiserallee 1, 76530 Baden-Baden, Germany",
                kind: .casino,
                coordinate: nil
            ),
        ]
    }

    private func geocodeAllPlacesIfNeeded() {
        let geocoder = CLGeocoder()

        func geocodeNext(_ index: Int) {
            guard index < places.count else { return }

            if places[index].coordinate != nil {
                geocodeNext(index + 1)
                return
            }

            let addr = places[index].address
            geocoder.geocodeAddressString(addr) { placemarks, error in

                defer {

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        geocodeNext(index + 1)
                    }
                }

                guard error == nil,
                    let loc = placemarks?.first?.location?.coordinate
                else {
                    return
                }

                DispatchQueue.main.async {
                    places[index].coordinate = loc
                }
            }
        }

        geocodeNext(0)
    }
}

#Preview("MapScreen") {
    MapScreen()
}

#Preview("MapScreen - Dark") {
    MapScreen()
        .preferredColorScheme(.dark)
}
