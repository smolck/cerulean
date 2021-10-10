//
// Seaglass, a native macOS Matrix client
// Copyright © 2018, Neil Alexander
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Cocoa
import MatrixSDK

class MemberListController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet var membersCacheController: NSArrayController!
    
    @IBOutlet var MemberSearch: NSSearchField!
    
    public var roomId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if roomId == "" {
            return
        }
        
        MatrixServices.inst.session.room(withRoomId: roomId).state { state in
            let state = state!
            for member in state.members.members {
                self.membersCacheController.insert(MembersCacheEntry(member), atArrangedObjectIndex: 0)
            }
            
            let membercount = (self.membersCacheController.arrangedObjects as! [MXRoomMember]).count
            
            self.MemberSearch.placeholderString = "Search \(membercount) member"
            if membercount != 1 {
                self.MemberSearch.placeholderString?.append(contentsOf: "s")
            }
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if roomId == "" {
            return 0
        }
        return (membersCacheController.arrangedObjects as! [MXRoomMember]).count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let room = MatrixServices.inst.session.room(withRoomId: roomId)
        let member: MembersCacheEntry = (membersCacheController.arrangedObjects as! [MembersCacheEntry])[row]
        var powerlevel = 0
        // TODO(smolck): How to deal with this and the callback stuff
        /*if room?.state.powerLevels != nil {
            powerlevel = room?.state.powerLevels.powerLevelOfUser(withUserID: member.userId) ?? 0
        }*/
        
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MemberListEntry"), owner: self) as? MemberListEntry
 
        cell?.MemberName.stringValue = member.name()
        cell?.MemberDescription.stringValue = "Power level \(powerlevel)"
        cell?.MemberIcon.setAvatar(forUserId: member.userId)
        
        cell?.identifier = nil
        return cell
    }
}
