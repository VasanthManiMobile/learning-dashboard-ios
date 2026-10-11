import SwiftUI

struct ContentView: View {

    @State private var isLoggedIn = false

    var body: some View {
        Group {
            if isLoggedIn {
                DashboardUIView()
            } else {
                LoginUIView {
                    isLoggedIn = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
