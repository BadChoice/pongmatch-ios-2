import SwiftUI

struct GroupsView : View {
        
    @EnvironmentObject private var auth: AuthViewModel
    
    @State var fetchingGroups = ApiAction()
    @State var groups:[PMGroup] = []
    
    var body: some View {
        List {
            if let error = fetchingGroups.errorMessage {
                Text("\(error)")
                    .foregroundColor(.red)
            }
            
            if fetchingGroups.loading {
                ProgressView()
            } else {
                ForEach(groups, id:\.id) { group in
                    NavigationLink {
                        EmptyView()
                    } label: {
                        HStack(spacing: 12) {
                            AsyncImage(url: Images.group(group.photo)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            } placeholder: {
                                ZStack {
                                    Circle().fill(Color.gray.opacity(0.2))
                                    Image(systemName: "person.3.fill")
                                        .foregroundColor(.gray)
                                }
                                .frame(width: 40, height: 40)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(group.name)
                                    .font(.headline)
                                Text("\(group.usersCount) members")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .task {
            let _ = await fetchingGroups.run {
                groups = try await auth.api.groups()
            }
        }
    }
    
}

#Preview {
    let auth = AuthViewModel()
    auth.api = Api("2|69n4MjMi5nzY8Q2zGlwL7Wvg7M6d5jb0PaCyS2Yla68afa64")
    
    return NavigationStack {
        GroupsView()
    }.environmentObject(auth)
}

