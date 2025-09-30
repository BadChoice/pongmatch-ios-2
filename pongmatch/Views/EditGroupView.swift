import SwiftUI

struct EditGroupView : View {
    @Binding var group: PMGroup
    
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    @Previewable @State var group = PMGroup.fake()
    EditGroupView(group: $group)
}
