//
//  ContentView.swift
//  Domain
//
//  Created by Mac on 16.06.2021.
//

import SwiftUI

// Обработка вводимых симовлов в строку домен
class TextBindingManager: ObservableObject {
    @Published var text: [String] = ["", "", "", "", ""] {
        didSet {
            for (index, _) in text.enumerated() {
                if (text[index].count > characterLimit && oldValue[index].count <= characterLimit) {
                    text[index] = oldValue[index]
                }
            }
        }
    }
    
    @Published var domainLength = 3
    
    let characterLimit: Int
    
    init(limit: Int = 1, length: Int = 3){
        characterLimit = limit
        domainLength = length
    }
}

struct ContentView: View {
    // textFields with params(max length: 1)
    @ObservedObject var textBindingManager = TextBindingManager(limit: 1)
    
    // main screen State
    @State var screen = UIScreen.main.bounds.size
    
    // filter view data
    @State var isShowFilter = false
    @State var filterViewState = CGSize.zero
    
    // filter state
    @State var filterDash = false
    @State var filterNumber = false
    @State var filterWords = false
    @State var filterFree = false
    
    //  Data from server
    @State var domainNames = [String]()
    @State var damainCountResult = 0
    
    
    // select domainzone
    @State var selectedDomainZone = ""
    
    // result data
    @State var searchLength = ""
    @State var searchDomainName = ""
    @State var searchZone = ""
    @State var viewDomains = CGSize.zero
    @State var isFind = false
    
    // loader state
    @State var isLoading = false
    
    
    
    var body: some View {
        ZStack {
            ZStack (alignment: .bottom) {
                VStack {
                    
                    HistoryView()
                    
                    
                    ZStack (alignment: .top) {
                        VStack {
                            VStack {
                                Text("Домен")
                                    .font(.system(size: 15, weight: .light))
                                    .foregroundColor(Color(#colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack {
                                    ForEach(0 ..< textBindingManager.domainLength, id: \.self) { index in
                                        TextField("*", text:  $textBindingManager.text[index])
                                            .frame(height: 70)
                                            .background(Color(#colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)))
                                            .multilineTextAlignment(.center)
                                            .cornerRadius(8)
                                    }
                                }
                                
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 36)
                            
                            HStack {
                                Button(action: {
                                    isShowFilter.toggle()
                                }, label: {
                                    Image("filter")
                                    Text("Фильтры")
                                        .font(.system(size: 15, weight: .light))
                                        .foregroundColor(Color.black)
                                })
                                
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                            
                            Button(action: {
                                isLoading = true
                                let input = textBindingManager.text.map {$0}
                                var mask = ""
                                for (index, _) in input.enumerated() {
                                    if (index < textBindingManager.domainLength){
                                        if (input[index] == ""){
                                            mask = mask + "*"
                                        } else {
                                            mask = mask + input[index]
                                        }
                                    }
                                }
                                
                                //print(mask)
                                var list = "all"
                                if (filterFree) {
                                    list = "free"
                                }
                                
                                Api().getPosts(mask: mask, zone: selectedDomainZone, length: String(textBindingManager.domainLength), list: list) { (domains) in
                                    self.domainNames = domains.response.items.map {$0.domain}
                                    self.damainCountResult = domains.response.count
                                    //print(self.domainNames)
                                    isFind = true
                                    viewDomains.height = screen.height - 200
                                    
                                    searchLength = String(textBindingManager.domainLength)
                                    searchZone = selectedDomainZone
                                    searchDomainName = mask
                                    isLoading = false
                                }
                                
                                
                                
                            }, label: {
                                Text("Найти")
                            })
                            .frame(width: 328, height: 48, alignment: .center)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .font(.system(size: 17, weight: .bold))
                            .cornerRadius(8)
                        }
                        .offset(y: 100)
                        HStack (alignment: .top) {
                            VStack (alignment: .leading) {
                                Text("Доменная зона")
                                    .font(.system(size: 15, weight: .light))
                                    .foregroundColor(Color(#colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)))
                                DropDownDomainZone(selected: self.$selectedDomainZone)
                            }
                            Spacer()
                            VStack (alignment: .leading) {
                                Text("Длина")
                                    .font(.system(size: 15, weight: .light))
                                    .foregroundColor(Color(#colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)))
                                DropDownDomainLength(selected: $textBindingManager.domainLength, domains: $textBindingManager.text)
                                    .font(.system(size: 15, weight: .light))
                                    .foregroundColor(Color(#colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)))
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 24)
                        //.padding(.bottom, 32)
                        
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                
                // search result
                VStack {
                    HStack {
                        VStack(alignment: .leading){
                            Text("Длина").font(.system(size: 15)).padding(.bottom, 2)
                            Text("\(searchLength)").font(.system(size: 24, weight: .bold))
                        }.padding(.trailing, 20)
                        VStack(alignment: .leading){
                            Text("Запрос").font(.system(size: 15)).padding(.bottom, 2)
                            Text("\(searchDomainName)").font(.system(size: 24, weight: .bold))
                        }.padding(.trailing, 20)
                        VStack(alignment: .leading){
                            Text("Зона").font(.system(size: 15)).padding(.bottom, 2)
                            Text("\(searchZone)").font(.system(size: 24, weight: .bold))
                        }
                        Spacer()
                        if (viewDomains.height != screen.height - 200) {
                            Button(action: {
                                viewDomains.height = screen.height - 200
                            }, label: {
                                Image("close-gray")
                            })
                        }
                        
                    }.padding(.bottom, 24)
                    
                    HStack {
                        Text("\(damainCountResult) результатов")
                        Spacer()
                    }
                    .padding(.bottom, 16)
                    
                    ScrollView(showsIndicators: false) {
                        ForEach(domainNames, id: \.self) { domain in
                            HStack {
                                Text("\(domain)").font(.system(size: 17, weight: .semibold))
                                Spacer()
                            }
                            .padding(.horizontal ,24)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .cornerRadius(8)
                            .padding(.bottom, 16)
                        }
                    }
                    Spacer()
                }
                .padding(.top, 32)
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(#colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)))
                .cornerRadius(20)
                .ignoresSafeArea(edges: .bottom)
                .offset(y: isFind ? 0 : screen.height)
                .offset(y: viewDomains.height)
                .animation(.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0))
                .onTapGesture {
                    self.viewDomains = .zero
                }
                .gesture(DragGesture()
                            .onChanged { value in
                                self.viewDomains = value.translation
                            }
                            .onEnded { value in
                                if (self.viewDomains.height > 50) {
                                    viewDomains.height = screen.height - 200
                                } else {
                                    self.viewDomains = .zero
                                }
                                
                            }
                )
                // Filter
                VStack {
                    Spacer()
                    HStack {
                        FilterSheet(
                            isShowFilter: $isShowFilter,
                            filterDash: $filterDash,
                            filterNumber: $filterNumber,
                            filterWords: $filterWords,
                            filterFree: $filterFree,
                            dragSize: $filterViewState
                        )
                    }
                    .offset(y: isShowFilter ? 0 : screen.height)
                    .animation(.easeInOut)
                }
                .frame(height: .infinity, alignment: .bottom)
                .frame(maxHeight: .infinity)
                .background(isShowFilter ? Color.black.opacity(0.3) : Color.clear)
                .ignoresSafeArea()
                .gesture(DragGesture()
                            .onChanged { value in
                                self.filterViewState = value.translation
                            }
                            .onEnded { value in
                                if (self.filterViewState.height > 50) {
                                    self.isShowFilter = false
                                }
                                self.filterViewState = .zero
                            }
                )
            }
            
            if isLoading {Loader()}
            
            
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
    
    struct HistoryCard: View {
        var body: some View {
            VStack (alignment: .leading) {
                Text("h00")
                    .font(.system(size: 20, weight: .bold))
                Spacer()
                HStack {
                    VStack (alignment: .leading) {
                        Text("Зона")
                            .font(.system(size: 11, weight: .light))
                        Text(".com")
                            .font(.system(size: 12, weight: .medium))
                    }
                    Spacer()
                    VStack (alignment: .leading) {
                        Text("Длина")
                            .font(.system(size: 11, weight: .light))
                        Text("4")
                            .font(.system(size: 12, weight: .medium))
                    }
                    Spacer()
                }
            }
            .foregroundColor(.white)
            .padding(16)
            .frame(width: 146, height: 95, alignment: .leading)
            .background(
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.6156862745, green: 0.4705882353, blue: 0.8392156863, alpha: 1)), Color(#colorLiteral(red: 0.3058823529, green: 0.2431372549, blue: 0.7058823529, alpha: 1))]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    Image("overlay")
                }
            )
            .cornerRadius(8)
            
        }
    }
    
    struct DropDownDomainZone: View {
        @State var isExpand = false
        @State var options = ["com", "ru", "kz", "net", "org", "me"]
        @Binding var selected: String
        var body: some View {
            ZStack (alignment: .top) {
                HStack {
                    Text("\(selected)").fontWeight(.bold)
                    Spacer()
                    Image(systemName: isExpand ? "chevron.up" : "chevron.down")
                        .resizable()
                        .frame(width: 13, height: 6)
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
                .frame(width: 160)
                .background(Color(#colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)))
                .cornerRadius(8)
                .onTapGesture {
                    withAnimation() {
                        isExpand.toggle()
                    }
                }
                
                
                if isExpand {
                    VStack (spacing: 15) {
                        ForEach (options, id: \.self) { option in
                            Button(action: {
                                selected = option
                                withAnimation() {
                                    isExpand.toggle()
                                }
                            }, label: {
                                Text("\(option)")
                            })
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                    .frame(width: 160)
                    .background(Color(#colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)))
                    .cornerRadius(8)
                    .foregroundColor(Color.black)
                    
                }
            }
            
            .onAppear {
                selected = options[0]
            }
            
        }
    }
    
    struct DropDownDomainLength: View {
        @State var isExpand = false
        @State var options = [3, 4]
        @Binding var selected: Int
        @Binding var domains: [String]
        @State var test: [String] = []
        
        
        var body: some View {
            ZStack (alignment: .top) {
                HStack {
                    Text("\(selected)").fontWeight(.bold).foregroundColor(.black)
                    Spacer()
                    Image(systemName: isExpand ? "chevron.up" : "chevron.down")
                        .resizable()
                        .frame(width: 13, height: 6)
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
                .frame(width: 160)
                .background(Color(#colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)))
                .cornerRadius(8)
                .onTapGesture {
                    withAnimation() {
                        isExpand.toggle()
                    }
                }
                
                if isExpand {
                    VStack (spacing: 15) {
                        ForEach (options, id: \.self) { option in
                            Button(action: {
                                selected = option
                                //domains = []
                                withAnimation() {
                                    isExpand.toggle()
                                }
                                
                            }, label: {
                                Text("\(option)")
                            })
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                    .frame(width: 160)
                    .background(Color(#colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)))
                    .cornerRadius(8)
                    .foregroundColor(Color.black)
                }
            }
            
            .onAppear {
                selected = options[0]
            }
            
        }
        
    }
    
    struct FilterSheet: View {
        @Binding var isShowFilter: Bool
        @State var screen = UIScreen.main.bounds.size
        @Binding var filterDash: Bool
        @Binding var filterNumber: Bool
        @Binding var filterWords: Bool
        @Binding var filterFree: Bool
        @Binding var dragSize: CGSize
        var body: some View {
            HStack {
                VStack {
                    VStack {
                        Spacer()
                        HStack{
                            Spacer()
                            Text("Фильтр")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                            Button(action: {
                                isShowFilter = false
                                filterDash = false
                                filterFree = false
                                filterWords = false
                                filterNumber = false
                            }, label: {
                                Image("Close")
                            })
                        }
                        .padding(.horizontal, 21)
                    }
                    //.frame(maxHeight: .infinity)
                    
                    VStack () {
                        HStack(spacing: 16) {
                            Button(action: {
                                filterDash.toggle()
                            }, label: {
                                Text("Без тире")
                                    .font(.system(size: 17))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(
                                                colors: [filterDash ? Color(#colorLiteral(red: 0.6156862745, green: 0.4705882353, blue: 0.8392156863, alpha: 1)) : Color.clear, filterDash ? Color(#colorLiteral(red: 0.3058823529, green: 0.2431372549, blue: 0.7058823529, alpha: 1)) : Color.clear]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .cornerRadius(30)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(filterDash ? Color.clear : Color(#colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1)), lineWidth: 1)
                                    )
                                    .foregroundColor(filterDash ? Color.white : Color.black)
                                
                            })
                            Button(action: {
                                filterNumber.toggle()
                            }, label: {
                                Text("Без цифр")
                                    .font(.system(size: 17))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(LinearGradient(gradient: Gradient(colors: [filterNumber ? Color(#colorLiteral(red: 1, green: 0.5568627451, blue: 0.5568627451, alpha: 1)) : Color.clear, filterNumber ? Color(#colorLiteral(red: 1, green: 0.7215686275, blue: 0, alpha: 1)) : Color.clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .cornerRadius(30)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(filterNumber ? Color.clear : Color(#colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1)), lineWidth: 1)
                                    )
                                    .foregroundColor(filterNumber ? Color.white : Color.black)
                            })
                            Button(action: {
                                filterWords.toggle()
                            }, label: {
                                Text("Без букв")
                                    .font(.system(size: 17))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(LinearGradient(gradient: Gradient(colors: [filterWords ? Color(#colorLiteral(red: 0.9411764706, green: 0.3725490196, blue: 0.3411764706, alpha: 1)) : Color.clear, filterWords ? Color(#colorLiteral(red: 0.2117647059, green: 0.03529411765, blue: 0.2509803922, alpha: 1)) : Color.clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .cornerRadius(30)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(filterWords ? Color.clear : Color(#colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1)), lineWidth: 1)
                                    )
                                    .foregroundColor(filterWords ? Color.white : Color.black)
                            })
                            Spacer()
                        }
                        HStack(spacing: 16) {
                            Button(action: {
                                filterFree.toggle()
                            }, label: {
                                Text("Только свободные")
                                    .font(.system(size: 17))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(LinearGradient(gradient: Gradient(colors: [filterFree ? Color(#colorLiteral(red: 0.3803921569, green: 0.8117647059, blue: 0.4549019608, alpha: 1)): Color.clear, filterFree ? Color(#colorLiteral(red: 0.3019607843, green: 0.7215686275, blue: 0.4470588235, alpha: 1)) : Color.clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .cornerRadius(30)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(filterFree ? Color.clear : Color(#colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1)), lineWidth: 1)
                                    )
                                    .foregroundColor(filterFree ? Color.white : Color.black)
                                
                            })
                            Spacer()
                        }
                        
                        Spacer()
                        Button(action: {
                            if (filterDash || filterFree || filterWords || filterNumber) {
                                isShowFilter.toggle()
                            }
                        }, label: {
                            Text("Применить")
                        })
                        .frame(width: 328, height: 48, alignment: .center)
                        .background((filterDash || filterFree || filterWords || filterNumber) ? Color.black : Color(#colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)))
                        .foregroundColor(Color.white)
                        .font(.system(size: 17, weight: .bold))
                        .cornerRadius(8)
                        .padding(.bottom, 64)
                    }
                    .frame(maxWidth: .infinity, maxHeight: (screen.height / 2) - self.dragSize.height)
                    //.frame(alignment: .leading)
                    .padding(.bottom)
                    .padding(.horizontal, 21)
                    .padding(.top, 32)
                    .background(Color.white)
                    .ignoresSafeArea(edges: .bottom)
                    .cornerRadius(16)
                }
            }
            
        }
    }
    
    struct HistoryView: View {
        @State var history = []
        
        var body: some View {
            HStack {
                Text("История поиска")
                    .font(.system(size: 24, weight: .bold))
                    .fontWeight(.bold)
                Spacer()
            }
            .padding([.leading, .bottom, .trailing], 24)
            .padding(.top, 32)
            
            if (history.count > 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack (spacing: 8) {
                        ForEach(0 ..< 5) { item in
                            HistoryCard()
                        }
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            Text("Показать все").foregroundColor(.black)
                        })
                        .frame(width: 146, height: 95)
                        .background(Color.white)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal, 21)
                }
                .padding(.bottom, 64)
            } else {
                HStack {
                    Text("История пока пуста")
                        .padding(.bottom, 64)
                        .padding(.horizontal, 24)
                    Spacer()
                }
            }
        }
    }
}

struct Loader: View {
    var body: some View {
        VStack {
            Text("Загрузка")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding(.bottom, 30)
            ProgressView()
                .scaleEffect(2.5)
                .progressViewStyle(CircularProgressViewStyle(tint: Color.black))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.3))
        .ignoresSafeArea()
    }
}
