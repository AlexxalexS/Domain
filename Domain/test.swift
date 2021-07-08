//
//  test.swift
//  Domain
//
//  Created by Mac on 21.06.2021.
//

import SwiftUI


//struct test: View {
//    @State var domains: Domains?
//    @State var domainNames = [String]()
//    @State var test = ["asd", "dfg", "hjk"]
//    
//    var body: some View {
//        
//        List(domainNames, id: \.self) { test in
//            Text("\(test)")
//
//        }
//        .onAppear() {
//            print("loading...")
//            Api().getPosts(mask: "***", zone: "ru", length: "4", list: "all", no_digit: false, no_dash: false, no_alpha: false) { (domains) in
//                self.domainNames = domains.response.items.map {$0.domain}
//                print(domainNames)
//            }
//        }
//    }
//}
//
//struct test_Previews: PreviewProvider {
//    static var previews: some View {
//        test()
//    }
//}
