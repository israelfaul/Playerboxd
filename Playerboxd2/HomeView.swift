import SwiftUI

//Stores submitted games and allows HomeView and AddGameView to access list
class GameStore: ObservableObject {
    @Published var games: [Game] = [] // Stores all the games in array

    func addGame(_ game: Game) {
        games.append(game) //Appends new game to game array
    }
}

//Game structure containing variables
struct Game: Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var imageName: String
    var rating: Int?
    var userReview: String?
}

//Checks if URL provided is valid
extension String {
    var isValidImageURL: Bool {
        return URL(string: self)?.scheme?.hasPrefix("http") == true
    }
}

//Display list of games
struct HomeView: View {
    @ObservedObject var gameStore: GameStore

    var body: some View {
        NavigationView { //Container linking game in list to GameDetailView page
            List(gameStore.games) { game in
                NavigationLink(destination: GameDetailView(game: game)) {
                    HStack {
                        if let url = URL(string: game.imageName) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty: ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                case .failure: Image(systemName: "photo.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                @unknown default: EmptyView()
                                }
                            }
                        } else {
                            Image(systemName: "photo.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                        }

                        VStack(alignment: .leading) {
                            Text(game.title).font(.headline)
                            HStack {
                                ForEach(1..<6) { star in
                                    Image(systemName: (game.rating ?? 0) >= star ? "star.fill" : "star")
                                        .foregroundColor(.yellow)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("Playerboxd")
            .navigationBarItems(trailing: NavigationLink(destination: AddGameView(gameStore: gameStore)) {
                Image(systemName: "plus.circle.fill").font(.title)
            })
        }
    }
}

//Add game page where user inputs data and submits to add to GameStore
struct AddGameView: View {
    @State private var game = Game(title: "", description: "", imageName: "", rating: nil, userReview: nil)
    var gameStore: GameStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            Text("Add Game")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            TextField("Title", text: $game.title)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Description", text: $game.description)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Image URL", text: $game.imageName)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            HStack {
                ForEach(1..<6) { star in
                    Image(systemName: game.rating ?? 0 >= star ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .font(.system(size: 40))
                        .onTapGesture { game.rating = star }
                }
            }
            .padding()

            VStack(alignment: .leading) {
                Text("Your Review:")
                    .font(.headline)
                    .padding(.top)

                TextField("Write your review here", text: Binding(
                    get: { game.userReview ?? "" },
                    set: { game.userReview = $0 }
                ))
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(height: 100)
            }
            .padding()

            Button("Save Game") {
                gameStore.addGame(game)
                dismiss()
            }
            .padding()
        }
        .padding()
    }
}

//View of details provided from inputted data
struct GameDetailView: View {
    var game: Game

    var body: some View {
        VStack {
            if let url = URL(string: game.imageName) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty: ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250)
                            .clipped()
                    case .failure: Text("Image failed to load")
                    @unknown default: EmptyView()
                    }
                }
            } else {
                Text("No image available")
                    .frame(width: 250, height: 400)
                    .background(Color.gray)
            }

            Text(game.title)
                .font(.largeTitle)
                .padding(.top, 16)

            Text(game.description)
                .font(.title2)
                .padding(.top, 8)
                .padding(.horizontal)

            VStack(alignment: .leading) {
                Text("Your Review")
                    .font(.headline)
                    .padding(.top)

                Text(game.userReview ?? "No review available")
                    .padding(.bottom)
            }
            .padding(.leading, 16)
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                ForEach(1..<6) { star in
                    Image(systemName: game.rating ?? 0 >= star ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .font(.system(size: 40))
                }
            }
            .padding(.top, 10)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
