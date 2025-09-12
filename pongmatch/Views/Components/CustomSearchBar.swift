import SwiftUI

struct CustomSearchBar: View {
    
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            
            TextField("Search", text: $text)
                .textFieldStyle(.plain)
                .padding(.vertical, 10)
        }
        .padding(.horizontal)
        .background(.ultraThinMaterial)
        .padding(.vertical, 2)
        .glassEffect(.regular.interactive())
        .clipShape(.capsule)
        .padding()
        //.shadow(radius: 4)
    }
}


#Preview {
    @Previewable @State var searchText = ""
    Group {
        CustomSearchBar(text: $searchText)
    }.background(.secondary)
        
}
