//
//  EditMuteWordsViewController.swift
//  Sky
//

import Foundation
import AppKit
import SwiftUI
import WebKit

class MuteWordsEditorViewController:
    NSViewController,
    NSTableViewDataSource,
    NSTableViewDelegate
{
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var editButton: NSButton!
    @IBOutlet weak var removeButton: NSButton!
    @IBOutlet weak var saveButton: NSButton!

    let PLACEHOLDER_TEXT = "long eggs"

    struct MuteWord {
        var value: String
        var isEnabled: Bool
    }

    var muteWords: [MuteWord] = []
    var hasChanged = false
    var needsReload = false

    override func viewWillAppear() {
        super.viewWillAppear()
        NSLog("viewWillAppear")
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("viewDidLoad")

        hasChanged = false
        needsReload = false

        // load muteWords
        muteWords.append(MuteWord(value: "test", isEnabled: true))
        muteWords.append(MuteWord(value: "foo bar", isEnabled: false))
        muteWords.append(MuteWord(value: "aloha", isEnabled: true))

        tableView.delegate = self
        tableView.dataSource = self

        tableView.doubleAction = #selector(actionMuteWordsEdit)
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        refreshButtons()
    }

    func refreshButtons() {
        let isEnabled = tableView.selectedRow != -1
        editButton.isEnabled = isEnabled
        removeButton.isEnabled = isEnabled
        saveButton.isEnabled = hasChanged
    }

    @IBAction func actionMuteWordsEdit(_ sender: Any?) {
        NSLog("actionMuteWordsEdit")
        let selectedRow = tableView.selectedRow
        let muteWord = muteWords[selectedRow]

        // Set the message as the NSAlert text
        let alert = NSAlert()
        alert.messageText = "Edit mute word"
        alert.informativeText = "Mute words are case-insensitive."

        // Add an input NSTextField for the prompt
        let inputFrame = NSRect(
            x: 0,
            y: 0,
            width: 300,
            height: 24
        )

        let textField = NSTextField(frame: inputFrame)
        textField.placeholderString = PLACEHOLDER_TEXT
        textField.stringValue = muteWord.value
        alert.accessoryView = textField

        // Add a confirmation button “OK”
        // and cancel button “Cancel”
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")

        alert.window.initialFirstResponder = textField

        // Display the NSAlert
        let action = alert.runModal()

        if action == .alertFirstButtonReturn {
            let stringValue = textField.stringValue
            updateMuteWord(selectedRow, stringValue)
            changeData()
        }
    }

    func updateMuteWord(_ row: Int, _ value : String) {
        muteWords[row] = MuteWord(value: value, isEnabled: true)
    }

    @IBAction func actionMuteWordsAdd(_ sender: Any?) {
        NSLog("actionMuteWordsAdd")

        // Set the message as the NSAlert text
        let alert = NSAlert()
        alert.messageText = "Add mute word"
        alert.informativeText = "Mute words are case-insensitive."

        // Add an input NSTextField for the prompt
        let inputFrame = NSRect(
            x: 0,
            y: 0,
            width: 300,
            height: 24
        )

        let textField = NSTextField(frame: inputFrame)
        textField.placeholderString = PLACEHOLDER_TEXT
        alert.accessoryView = textField

        // Add a confirmation button “OK”
        // and cancel button “Cancel”
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")

        alert.window.initialFirstResponder = textField

        // Display the NSAlert
        let action = alert.runModal()

        if action == .alertFirstButtonReturn {
            let stringValue = textField.stringValue
            addMuteWord(stringValue)
        }
    }

    func addMuteWord(_ muteWord: String) {
        let trimmed = muteWord.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            muteWords.append(MuteWord(value: trimmed, isEnabled: true))
            changeData()
        }
    }

    func changeData() {
        hasChanged = true
        tableView.reloadData()
        refreshButtons()
    }

    @IBAction func actionMuteWordsRemove(_ sender: Any?) {
        NSLog("actionMuteWordsRemove")
        let selectedRow = tableView.selectedRow
        muteWords.remove(at: selectedRow)
        changeData()
    }

    @IBAction func actionMuteWordsSave(_ sender: Any?) {
        NSLog("actionMuteWordsSave")

        hasChanged = false
        needsReload = true
        refreshButtons()
    }

    @IBAction func actionMuteWordsClose(_ sender: Any?) {
        NSLog("actionMuteWordsClose")

        if hasChanged {
            // Set the message as the NSAlert text
            let alert = NSAlert()
            alert.messageText = "Save changes before closing?"

            alert.addButton(withTitle: "Save")
            alert.addButton(withTitle: "Don't Save")
            alert.addButton(withTitle: "Cancel")

            // Display the NSAlert
            let action = alert.runModal()

            NSLog("action = \(action)")
            if action == .alertFirstButtonReturn {
                // save
                actionMuteWordsSave(nil)
            } else if action == .alertSecondButtonReturn {
                // don't save
            } else {
                // cancel
                return
            }
        }

        if needsReload {
            // Set the message as the NSAlert text
            let alert = NSAlert()
            alert.messageText = "Reload with updated mute words?"

            alert.addButton(withTitle: "Reload")
            alert.addButton(withTitle: "Don't Reload")

            // Display the NSAlert
            let action = alert.runModal()
            if action == .alertFirstButtonReturn {
                // OK
                let appDelegate = NSApplication.shared.delegate as! AppDelegate
                appDelegate.mainViewController?.actionRefresh(nil)
            }
        }
        view.window!.close()
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 21.0
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return muteWords.count
    }

    func tableView(
        _ tableView: NSTableView,
        viewFor tableColumn: NSTableColumn?,
        row: Int
    ) -> NSView? {
        let currentMuteWord = muteWords[row]
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "muteWordColumn") {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "muteWordCell")
            if let cellView = tableView.makeView(
                withIdentifier: cellIdentifier,
                owner: self) as? NSTableCellView
            {
                cellView.textField?.stringValue = currentMuteWord.value
                return cellView
            }
        }
        return nil
    }

}
