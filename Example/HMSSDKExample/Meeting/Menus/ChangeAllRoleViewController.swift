//
//  ChangeAllRoleViewController.swift
//  HMSSDKExample
//
//  Created by Dmitry Fedoseyev on 13.09.2021.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit
import HMSSDK
import Eureka

protocol ChangeAllRoleViewControllerDelegate: AnyObject {
    func changeAllRoleController(_ changeAllRoleController:ChangeAllRoleViewController, didSelect sourceRoles:[HMSRole]?, targetRole:HMSRole)
}

final class ChangeAllRoleViewController: FormViewController {
    
    internal var knownRoles = [HMSRole]()
    
    internal weak var delegate: ChangeAllRoleViewControllerDelegate? = nil
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("")
            <<< SegmentedRow<String>() {
                $0.title = "Roles to change"
                $0.options = ["All", "Specific"]
                $0.value = "All"
                $0.tag = "roleFilterType"
            }
            <<< MultipleSelectorRow<String>(){
                $0.hidden = Condition.function(["roleFilter"], { form in
                    return ((form.rowBy(tag: "roleFilter") as? SegmentedRow)?.value ?? "") == "All"
                })
                $0.title = "Select roles to change"
                $0.options = knownRoles.map { $0.name }
                $0.tag = "roleNameFilter"
            }
            <<< PushRow<String>() {
                $0.title = "Target role"
                $0.options = knownRoles.map { $0.name }
                $0.value = knownRoles.first?.name
                $0.tag = "targetRoleName"
            }
        form +++ Section("")
            <<< ButtonRow() {
                $0.title = "Change"
                $0.onCellSelection { [weak self] _, _ in
                    self?.onChangeButtonTap()
                }
            }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Change All Role to Role"
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Action Handlers
    
    private func onChangeButtonTap() {
        let row: SegmentedRow<String>? = form.rowBy(tag: "roleFilterType")
        var roleFilter: [HMSRole]?
        
        if row?.value == "Specific",
           let specificRoleFilter = (form.rowBy(tag: "roleNameFilter") as? MultipleSelectorRow<String>)?.value  {
            roleFilter = specificRoleFilter.compactMap { name in knownRoles.first(where: { $0.name == name  }) }
        }
        
        guard let targetRoleName = (form.rowBy(tag: "targetRoleName") as? PushRow<String>)?.value,
              let targetRole = knownRoles.first(where: { $0.name == targetRoleName }) else {
            showNoTargetError()
            return
        }
        
        delegate?.changeAllRoleController(self, didSelect: roleFilter, targetRole: targetRole)
        navigationController?.popViewController(animated: true)
    }
    
    private func showNoTargetError() {
        let title = "Error"
        
        let alertController = UIAlertController(title: title,
                                                message: "Please select a target role",
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        present(alertController, animated: true)
    }
}
