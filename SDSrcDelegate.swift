//
//  SDSrcDelegate.swift
//  SDSrcDelegate
//
//  Created by 侯仕奇 on 2020/8/13.
//  Copyright © 2020 零下引力. All rights reserved.
//

import UIKit

class SDRowSource: NSObject {
    var cellClass: AnyClass = MHWTableViewCell.self
    var data: Any?
    var didSelect: ((UITableView, IndexPath) -> Void)?
    var tableView: UITableView?
    init(_ cellClass: AnyClass, _ data: Any?) {
        super.init()
        self.cellClass = cellClass
        self.data = data
    }
}

class SDSectionSource: NSObject {
    var headerClass: MHWTableViewHeaderFooterView.Type?
    var headerHeight: CGFloat = 0
    var data: Any?
    var rows: [SDRowSource] = []
    var tableView: UITableView?
    var count: Int {
        rows.count
    }

    subscript(index: Int) -> SDRowSource {
        get {
            rows[index]
        }
        set(newValue) {
            rows[index] = newValue
        }
    }

    func appendRow(_ newRow: SDRowSource?) {
        if let row = newRow {
            row.tableView?.register(row.cellClass, forCellReuseIdentifier: NSStringFromClass(row.cellClass))
            rows.append(row)
        }
    }

    func appendRow(_ closure: (SDRowSource) -> Void) {
        let row = SDRowSource(MHWTableViewCell.self, NSStringFromClass(MHWTableViewCell.self))
        closure(row)
        rows.append(row)
    }

    func remove(at: Int) {
        rows.remove(at: at)
    }

    func removeAll() {
        rows.removeAll()
    }
}

class SDSrcDelegate: NSObject, UITableViewDataSource, UITableViewDelegate {
    private var src: [SDSectionSource] = []
    var tableView: UITableView?
    init(tableView: UITableView) {
        super.init()
        self.tableView = tableView
        tableView.delegate = self
        tableView.dataSource = self
    }

    func appendSection(_ newSection: SDSectionSource) {
        src.append(newSection)
    }

    func appendSection(_ closure: (SDSectionSource) -> Void) {
        let section = SDSectionSource()
        section.tableView = tableView
        closure(section)
        if let headerClass = section.headerClass {
            tableView?.register(section.headerClass, forHeaderFooterViewReuseIdentifier: NSStringFromClass(headerClass))
        }
        for item in section.rows {
            tableView?.register(item.cellClass, forCellReuseIdentifier: NSStringFromClass(item.cellClass))
        }
        src.append(section)
    }

    func remove(at: Int) {
        src.remove(at: at)
    }

    func removeAll() {
        src.removeAll()
    }

    // MARK: - UITableViewDataSource & UITableViewDelegate

    func numberOfSections(in tableView: UITableView) -> Int {
        src.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        src[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = src[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(row.cellClass), for: indexPath) as? MHWTableViewCell ?? MHWTableViewCell(style: .default, reuseIdentifier: "")
        cell.update(src: row)
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let group = src[section]
        guard group.headerClass != nil else {
            return nil
        }
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(group.headerClass ?? MHWTableViewHeaderFooterView.self)) as? MHWTableViewHeaderFooterView
        view?.update(src: group)
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let group = src[section]
        return group.headerHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = src[indexPath.section][indexPath.row]
        if let didSelect = row.didSelect {
            didSelect(tableView, indexPath)
        }
    }
}
