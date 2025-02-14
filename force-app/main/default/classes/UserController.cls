public without sharing class UserController {
    public static void updateUsers(Map<String, String> personAccountMap) {
        List<User> users = new List<User>();
        users = [
            SELECT Id, Email, FirstName, MiddleName, LastName, AccountId
            FROM User
            WHERE AccountId IN :(personAccountMap.keySet())
        ];

        if (users != null && !users.isEmpty()) {
            for (User user : users) {
                user.Email = personAccountMap.get(user.AccountId);
            }
            update users;
        }
    }
}