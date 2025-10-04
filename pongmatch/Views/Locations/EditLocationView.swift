import SwiftUI

struct EditLocationView : View {
    @EnvironmentObject var auth:AuthViewModel
    let location:Location
    
    var body: some View {
        Text("Edit Location View")
    }
}

/*#Preview {
    let auth = AuthViewModel()
    auth.user = User.me()
    auth.api = FakeApi("2|69n4MjMi5nzY8Q2zGlwL7Wvg7M6d5jb0PaCyS2Yla68afa64")
    
    return NavigationStack {
        EditLocationView(Location.fake())
    }.environmentObject(auth)
}*/
