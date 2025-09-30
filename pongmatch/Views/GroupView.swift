import SwiftUI

the select the user we can use the SearchUsersView
    @EnvironmentObject var auth:AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State var group:PMGroup
    @State var users:[User] = []
    @State var showConfirmDismissAlert = false
    @State var showConfirmDeleteGroup = false
    
    @StateObject var joiningGroup = ApiAction()
    
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
                            EditGroupView(group: $group)
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
            
            if group.user.status == .invited {
                joinSection
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
                            showConfirmDismissAlert.toggle()
                        } label: {
                            Label("Leave Group", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .alert("Leave Group", isPresented: $showConfirmDismissAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Leave", role: .destructive) {
                leaveGroup()
            }
        } message: {
            Text("Are you sure you want to leave this group?")
        }
    }
    
    private var joinSection : some View {
        Section {
            HStack {
                Spacer()
                Button {
                    showConfirmDismissAlert.toggle()
                } label: {
                    Text("Leave")
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                        .foregroundColor(.red)
                }
                .disabled(joiningGroup.loading)
                .buttonStyle(.plain)
                

                Spacer().frame(width: 60)
                
                Button {
                    joinGroup()
                } label: {
                    Text("JOIN")
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                }
                .disabled(joiningGroup.loading)
                
                .buttonStyle(.plain)
                
                Spacer()
            }
            .contentShape(Rectangle())
        }
    }
    
    private func joinGroup(){
        Task{
            let _ = await joiningGroup.run {
                group = try await auth.api.join(group: group)
            }
        }
    }
    
    private func leaveGroup(){
        Task {
            let didLeave = await joiningGroup.run {
                try await auth.api.leave(group: group)
            }
            
            if didLeave {
                dismiss()
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
