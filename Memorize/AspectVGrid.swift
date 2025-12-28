//
//  AspectVGrid.swift
//  Memorize
//
//  Created by hank.zhao on 2021/9/4.
//

import SwiftUI

struct AspectVGrid<Item,ItemView>: View  where  ItemView:View, Item:Identifiable{

    var items : [Item]
    var aspectRatio : CGFloat
    var content : (Item)->ItemView
    
    init(items: [Item], aspectRatio:CGFloat,  @ViewBuilder content: @escaping(Item)->ItemView ) {
        self.items = items
        self.aspectRatio = aspectRatio
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                let width = widthThatFits(itemCount: items.count, in: geometry.size, itemAspectRatio: aspectRatio)
                LazyVGrid(columns: [adaptiveGridItem(width: width)], spacing: 0) {
                    ForEach(items) { item in
                        content(item)
                            .aspectRatio(aspectRatio, contentMode: .fit)
                    }
                }
                Spacer(minLength: 0)
            }
        }
    }
    
    private func adaptiveGridItem(width: CGFloat) -> GridItem {
        var item = GridItem(.adaptive(minimum: max(width, 50)))
        item.spacing = 0
        return item
    }
    
    private func widthThatFits(itemCount: Int, in size: CGSize, itemAspectRatio: CGFloat) -> CGFloat {
        guard itemCount > 0, size.width > 0 else { return 0 }
        var columnCount = 1
        var rowCount = itemCount
        repeat {
            let itemWidth = size.width / CGFloat(columnCount)
            let itemHeight = itemWidth / itemAspectRatio
            if CGFloat(rowCount) * itemHeight <= size.height {
                break
            }
            columnCount += 1
            rowCount = (itemCount + (columnCount - 1)) / columnCount
        } while columnCount <= itemCount
        columnCount = min(columnCount, max(1, itemCount))
        return floor(size.width / CGFloat(columnCount))
    }
    
}

//struct AspectVGrid_Previews: PreviewProvider {
//    static var previews: some View {
//        AspectVGrid()
//    }
//}
