// SomeViewSection.swift

import RxDataSources

struct MyStorageSectionData {
    var items: [Item]
}

extension MyStorageSectionData: SectionModelType {
    typealias Item = StorageData
    
    init(original: MyStorageSectionData, items: [StorageData]) {
        self = original
        self.items = items
    }
}
