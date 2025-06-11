@isTest
private class RoleHierarchyHelperTest {

    @testSetup
    static void setup() {
        UserRole directorRole = new UserRole(Name = 'Test Director');
        insert directorRole;

        UserRole managerRole = new UserRole(Name = 'Test Manager', ParentRoleId = directorRole.Id);
        insert managerRole;
        
        UserRole userRole = new UserRole(Name = 'Test User Role', ParentRoleId = managerRole.Id);
        insert userRole;


        User director = TestDataFactory.createUser('director', directorRole);
        User manager = TestDataFactory.createUser('manager', managerRole);
        User jrUser = TestDataFactory.createUser('jruser', userRole);
        
        insert new List<User>{director, manager, jrUser};
    }

    @isTest
    static void testGetSuperiorUserIds() {
        User jrUser = [SELECT Id FROM User WHERE Alias = 'jruser' LIMIT 1];
        User manager = [SELECT Id FROM User WHERE Alias = 'manager' LIMIT 1];
        User director = [SELECT Id FROM User WHERE Alias = 'director' LIMIT 1];

        Test.startTest();
            Set<Id> superiorIds = RoleHierarchyHelper.getSuperiorUserIds(new Set<Id>{jrUser.Id});
        Test.stopTest();

        System.assertEquals(2, superiorIds.size());
        System.assert(superiorIds.contains(manager.Id));
        System.assert(superiorIds.contains(director.Id));
        System.assert(!superiorIds.contains(jrUser.Id));
    }
}