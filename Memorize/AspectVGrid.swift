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
            VStack{
                let width:CGFloat = 100
                LazyVGrid(columns: [adaptiveGridItem(width: width)] ){
                    ForEach(items){
                        item in content(item).aspectRatio(aspectRatio, contentMode: .fit)
                    }
                }
                Spacer(minLength: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/)
            }
           
        }
       
    }
    
    private func adaptiveGridItem(width:CGFloat)-> GridItem{
        var item = GridItem(.adaptive(minimum: width))
        item.spacing = 0
        return item
    }
    
}

//struct AspectVGrid_Previews: PreviewProvider {
//    static var previews: some View {
//        AspectVGrid()
//    }
//}
