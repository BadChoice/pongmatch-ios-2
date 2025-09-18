import SwiftUI

struct FinalResult: View {
    let result:[Int]?
    
    init(_ result:[Int]?) {
        self.result = result
    }
    
    var body: some View {
        HStack {
            if let result, result.count > 0  {
                Text("\(result[0]) - \(result[1])")
            } else {
                Text("VS")
            }
        }
        .font(.largeTitle.bold())
    }
}

#Preview {
    VStack(spacing:20) {
        FinalResult([11,8])
        FinalResult(nil)
        FinalResult([2,11])
    }
}
