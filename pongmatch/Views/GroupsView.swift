import SwiftUI

struct GroupsView : View {
        
    @EnvironmentObject private var auth: AuthViewModel
    
    @State var fetchingGroups = ApiAction()
    @State var groups:[PMGroup] = []
    @State var showCreateGroup:Bool = false
    
    var body: some View {
        List {
            if let error = fetchingGroups.errorMessage {
                Text("\(error)")
                    .foregroundColor(.red)
            }
            
            if fetchingGroups.loading {
                ProgressView()
            } else {
                
                if groups.isEmpty {
                    ContentUnavailableView {
                        Label("You are not a member of any groups yet", systemImage: "person.2")
                    } description: {
                        Text("Create or join a group to start playing with friends!")
                    } actions:{
                        Button("Create group") {
                            showCreateGroup = true
                        }
                    }
                }
                
                
                ForEach(groups, id:\.id) { group in
                    NavigationLink {
                        GroupView(group: group)
                    } label: {
                        HStack(spacing: 12) {
                            GroupImage(group: group)
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
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("", systemImage: "plus") {
                    showCreateGroup = true
                }
            }
            
            ToolbarItem(placement: .topBarTrailing ){
                ShareLink(item: URL(string: Pongmatch.appStoreUrl)!) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
        }
    }
}

struct GroupImage:View {
    let group:PMGroup
    let size:Double
    
    init(group:PMGroup, size:Double = 40) {
        self.group = group
        self.size = size
    }
    
    var body: some View {
        AsyncImage(url: Images.group(group.photo)) { image in
            image
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
        } placeholder: {
            ZStack {
                Circle().fill(Color.gray.opacity(0.2))
                Image(systemName: "person.3.fill")
                    .foregroundColor(.gray)
            }
            .frame(width: size, height: size)
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

