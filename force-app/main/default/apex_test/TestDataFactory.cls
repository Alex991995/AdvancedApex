public class TestDataFactory {

  public static List<Contact> createContacts() {
    List<Contact> contacts = new List<Contact>();

    for (Integer i = 1; i <= 50; i++) {
      Contact c = new Contact();
      c.LastName = 'User ' + i;
      if (i <= 25) {
        c.Amount__c = 1100;
      } else {
        c.Amount__c = 10;
      }
      contacts.add(c);
    }
    return contacts;
  }
}
