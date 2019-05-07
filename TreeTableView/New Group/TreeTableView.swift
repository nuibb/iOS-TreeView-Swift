//
//  TreeTableView.swift

import UIKit

protocol TreeTableViewCellDelegate: NSObjectProtocol {
    func cellClick() //The parameter has not been added yet, and the TreeNode represents the node.
}

class TreeTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    var mAllNodes: [TreeNode]? //All nodes
    var mNodes: [TreeNode]? // Visible node
    
    //    var treeTableViewCellDelegate: TreeTableViewCellDelegate?
    
    let NODE_CELL_ID: String = "nodecell"
    
    init(frame: CGRect, withData data: [TreeNode]) {
        super.init(frame: frame, style: UITableView.Style.plain)
        self.delegate = self
        self.dataSource = self
        mAllNodes = data
        print(mAllNodes!)
        mNodes = TreeNodeHelper.sharedInstance.filterVisibleNode(mAllNodes!)
        print(" mNodes :  \(String(describing: mNodes!.count))")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let nib = UINib(nibName: "TreeNodeTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: NODE_CELL_ID)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NODE_CELL_ID) as! TreeNodeTableViewCell
        
        let node: TreeNode = mNodes![indexPath.row]
        
        cell.background.bounds.origin.x = -20.0 * CGFloat(node.getLevel())
        
        if node.type == TreeNode.NODE_TYPE_G {
            cell.nodeIMG.contentMode = UIView.ContentMode.center
            cell.nodeIMG.image = UIImage(named: node.icon!)
        } else {
            cell.nodeIMG.image = nil
        }
        
        cell.nodeName.text = node.pId
        cell.nodeDesc.text = node.id
        return cell
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (mNodes?.count)!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let parentNode = mNodes![indexPath.row]
        
        let startPosition = indexPath.row+1
        var endPosition = startPosition
        
        if parentNode.isLeaf() {
            // do something
        } else {
            expandOrCollapse(&endPosition, node: parentNode)
            mNodes = TreeNodeHelper.sharedInstance.filterVisibleNode(mAllNodes!)
            
            var indexPathArray :[IndexPath] = []
            var tempIndexPath: IndexPath?
            for i in startPosition ..< endPosition {
                tempIndexPath = IndexPath(row: i, section: 0)
                indexPathArray.append(tempIndexPath!)
            }
            
            if parentNode.isExpand {
                self.insertRows(at: indexPathArray, with: UITableView.RowAnimation.none)
            } else {
                self.deleteRows(at: indexPathArray, with: UITableView.RowAnimation.none)
            }

            self.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
        }
    }
    

    func expandOrCollapse(_ count: inout Int, node: TreeNode) {
        if node.isExpand {
            closedChildNode(&count,node: node)
        } else {
            count += node.children.count
            node.setExpand(true)
        }
    }
    
    func closedChildNode(_ count:inout Int, node: TreeNode) {
        
        if node.isLeaf() {
            return
        }
        
        if node.isExpand {
            node.isExpand = false
            for item in node.children {
                count += 1 
                closedChildNode(&count, node: item)
            }
        } 
    }
}

