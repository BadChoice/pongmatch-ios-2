import SwiftUI

struct GroupView : View {
    @EnvironmentObject var auth:AuthViewModel
    
    let group:PMGroup
    @State var users:[User] = []
    
    var body: some View {
        List {
            Section {
                HStack (spacing: 10) {
                    GroupImage(group: group, size:60)
                    VStack (alignment: .leading) {
                        Text("\(group.name)").font(.title.bold()).foregroundStyle(.primary)
                        Text("\(group.usersCount) members").foregroundStyle(.secondary)
                    }
                    if group.user.isAdmin {
                        Spacer()
                        NavigationLink {
                            //GroupEditView(group: group)
                        } label: {
                            Image(systemName: "pencil")
                        }
                        .frame(width: 40)
                        .navigationLinkIndicatorVisibility(.hidden)
                    }
                }
                    
                if let description = group.description, !description.isEmpty {
                    Text("\(group.description ?? "")")
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
            }
            
            if users.isEmpty {
                Section {
                    Text("No members")
                }
            } else {
                Section {
                    ForEach(users.indices, id:\.self) { index in
                        NavigationLink {
                            FriendView(user: users[index])
                        } label: {
                            HStack(spacing: 12) {
                                Text("\(index+1)")
                                    .font(.title3.bold())
                                UserView(user: users[index])
                            }
                        }
                    }
                }
            }
        }
        .task {
            users = (try? await auth.api.groupUsers(group)) ?? []
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    if group.user.isAdmin {
                        Button {
                            // Add members
                        } label: {
                            Label("Invite Members", systemImage: "person.badge.plus")
                        }
                        
                        Button(role: .destructive) {
                            // Delete group
                        } label: {
                            Label("Delete Group", systemImage: "trash")
                        }
                    }
                    else {
                        Button {
                            // Leave group
                        } label: {
                            Label("Leave Group", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
    }
}


#Preview {
    let auth = AuthViewModel()
    auth.api = Api("2|69n4MjMi5nzY8Q2zGlwL7Wvg7M6d5jb0PaCyS2Yla68afa64")
    
    return NavigationStack {
        GroupView(group: PMGroup.fake())
    }.environmentObject(auth)
}

