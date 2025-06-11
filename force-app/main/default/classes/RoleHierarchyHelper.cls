/**
 * @description Support Class to obtain information on the users' role hierarchy
 */
public with sharing class RoleHierarchyHelper {

    /**
     * @description Receives a set of user ids, returns the ids
     * of the users that are above in the role hierarchy.
     * @param userIds Set<Id> - Base users' ids.
     * @return Set<Id> - Superior Users' Role ids.
     */
    public static Set<Id> getSuperiorUserIds(Set<Id> userIds) {
        if (userIds == null || userIds.isEmpty()) {
            return new Set<Id>();
        }

        Map<Id, UserRole> allRolesMap = new Map<Id, UserRole>([SELECT Id, ParentRoleId FROM UserRole]);
        Set<Id> initialRoleIds = new Set<Id>();

        for (User u : [SELECT UserRoleId FROM User WHERE Id IN :userIds AND UserRoleId != null]) {
            initialRoleIds.add(u.UserRoleId);
        }
        
        if (initialRoleIds.isEmpty()) {
            return new Set<Id>();
        }

        Set<Id> superiorRoleIds = new Set<Id>();
        Set<Id> rolesToProcess = initialRoleIds;

        while (!rolesToProcess.isEmpty()) {
            Set<Id> nextParentRoleIds = new Set<Id>();
            for (Id currentRoleId : rolesToProcess) {
                UserRole currentRole = allRolesMap.get(currentRoleId);
                if (currentRole != null && currentRole.ParentRoleId != null) {
                    if (!superiorRoleIds.contains(currentRole.ParentRoleId)) {
                        superiorRoleIds.add(currentRole.ParentRoleId);
                        nextParentRoleIds.add(currentRole.ParentRoleId);
                    }
                }
            }
            rolesToProcess = nextParentRoleIds;
        }

        if (superiorRoleIds.isEmpty()) {
            return new Set<Id>();
        }

        Set<Id> superiorUserIds = new Set<Id>();
        for (User u : [SELECT Id FROM User WHERE UserRoleId IN :superiorRoleIds AND IsActive = true]) {
            superiorUserIds.add(u.Id);
        }

        return superiorUserIds;
    }
}