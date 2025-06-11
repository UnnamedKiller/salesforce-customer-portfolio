@isTest
public class TestDataFactory {
    
    public static Account createAccount(String name) {
        return new Account(Name = name);
    }
    /**
* @description Cria um utilizador com um papel específico.
* @param name Role name.
* @param parentRoleId Parent role Id.
* @return Inserted User Role.
*/
    public static User createUser(String alias, UserRole role) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        String uniqueTimestamp = String.valueOf(Datetime.now().getTime()) + alias;
        
        User u = new User(
            Alias = alias,
            Email = alias + '@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test ' + alias,
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = alias + '.' + uniqueTimestamp + '@test.com',
            UserRoleId = role.Id
        );
        return u;
    }
    
    /**
* @description Creates and  inserts a User Role.
* @param name Role name.
* @param parentRoleId Parent role Id.
* @return Inserted User Role.
*/    
    public static Customer_Portfolio__c createPortfolio(Id accountId, Id userId, String source) {
        return new Customer_Portfolio__c(
            Customer__c = accountId,
            User__c = userId,
            Source__c = source,
            External_Id__c = userId + '' + accountId
        );
    }
    
    /**
* @description Creates and  inserts a User Role.
* @param name Role name.
* @param parentRoleId Parent role Id.
* @return Inserted User Role.
*/
    public static UserRole createRole(String name, Id parentRoleId) {
        UserRole role = new UserRole(Name = name, ParentRoleId = parentRoleId);
        insert role;
        return role;
    }
    
    /**
* @description Creates and inserts a role hierarchy with a list of roles.
* @param roleNames A list with role names, from the top one to the bottom one.
* @return Inserted users list.
*/
    public static List<UserRole> createRoleHierarchy(List<String> roleNames) {
        List<UserRole> createdRoles = new List<UserRole>();
        Id parentId = null;
        for (String roleName : roleNames) {
            UserRole newRole = createRole(roleName, parentId);
            createdRoles.add(newRole);
            parentId = newRole.Id;
        }
        return createdRoles;
    }
}