import SwiftUI

struct GroupsView : View {
        
    @EnvironmentObject private var auth: AuthViewModel
    
    @State var fetchingGroups = ApiAction()
    @State var groups:[PMGroup] = []
    @State var showCreateGroup:Bool = false
    @State private var newGroupToNavigate: PMGroup? = nil
    
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
        .navigationDestination(isPresented: Binding(
            get: { newGroupToNavigate != nil },
            set: { active in if !active { newGroupToNavigate = nil } }
        )) {
            if let group = newGroupToNavigate {
                GroupView(group: group)
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
        .sheet(isPresented: $showCreateGroup) {
            CreateGroupSheet(
                isPresented: $showCreateGroup,
                onCreated: { newGroup in
                    // Add to list and navigate
                    groups.append(newGroup)
                    newGroupToNavigate = newGroup
                }
            )
            .environmentObject(auth)
        }
    }
}

private struct CreateGroupSheet: View {
    @EnvironmentObject var auth: AuthViewModel
    
    @Binding var isPresented: Bool
    var onCreated: (PMGroup) -> Void

    @State private var name = ""
    @State private var description = ""
    @State private var isPrivate = true
    @State private var isCreating = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                    Toggle("Private group", isOn: $isPrivate)
                }
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .disabled(isCreating)
            .navigationTitle("Create Group")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createGroup()
                    }
                    .disabled(
                        name.trimmingCharacters(in: .whitespaces).isEmpty ||
                        description.trimmingCharacters(in: .whitespaces).isEmpty  ||
                        isCreating
                    )
                }
            }
            .overlay {
                if isCreating {
                    ZStack {
                        Color.black.opacity(0.1).ignoresSafeArea()
                        ProgressView()
                    }
                }
            }
        }
    }

    func createGroup() {
        errorMessage = nil
        isCreating = true
        Task {
            do {
                let group = try await auth.api.createGroup(
                    name: name.trimmingCharacters(in: .whitespaces),
                    description: description.trimmingCharacters(in: .whitespaces).isEmpty ? nil : description,
                    isPrivate: isPrivate
                )
                isCreating = false
                isPresented = false
                // Delay to allow sheet to dismiss before navigating
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    onCreated(group)
                }
            } catch {
                errorMessage = error.localizedDescription
                isCreating = false
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

