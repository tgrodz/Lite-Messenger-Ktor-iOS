import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MessengerViewModel()
    
    var body: some View {
        MessengerRootView(viewModel: viewModel)
    }
}
