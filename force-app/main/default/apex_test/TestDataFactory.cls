public class TestDataFactory {
  public static List<Account> createAccounts() {
    List<Account> accounts = new List<Account>();

    for (Integer i = 0; i < 50; i++) {
      Account c = new Account();
      c.Name = 'Account ' + i;
      accounts.add(c);
    }
    return accounts;
  }

  public static List<Contact> createContacts(List<Account> accounts) {
    List<Contact> contacts = new List<Contact>();

    for (Integer i = 0; i < 50; i++) {
      Contact c = new Contact();
      c.LastName = 'Contact ' + i;
      c.AccountId = accounts[i].Id;
      if (i < 25) {
        c.Amount__c = 11000;
      } else {
        c.Amount__c = 10;
      }
      contacts.add(c);
    }
    return contacts;
  }

  public static List<Account> getAccounts() {
    return [SELECT Id, Name FROM Account];
  }
}
