public with sharing class AccountSwitcherImpl implements AccountSwitcher {
  final integer RANDOM_NUMBER_LENGTH = 6;
  public static List<TypeClass> AllContacts = new List<TypeClass>();

  public void getAndSort() {
    List<Contact> contacts = getALLContacts();

    for (Contact c : contacts) {
      if (c.Amount__c > 1000) {
        PrivateContactClass privateContact = new PrivateContactClass();
        privateContact.contactRecord = c;
        privateContact.cardNumber = getRandomNumber();
        privateContact.contactType = getContactType(privateContact.cardNumber);
        AllContacts.add(privateContact);
      } else {
        PublicContactClass publicContact = new PublicContactClass();
        publicContact.contactRecord = c;
        publicContact.volunteerNumber = getRandomNumber();
        publicContact.contactType = 'Person';
        AllContacts.add(publicContact);
      }
    }
  }
  /**
   * @description fill 3 List by data from Classes(PublicContact and PrivateContact) into DataResult like
   * nonChangedPrivateContact
   * changedPrivateContact
   * changedPublicContact
   */
  public DataResult switchAccount() {
    List<PrivateContactClass> privateContact = new List<PrivateContactClass>();
    List<PublicContactClass> publicContact = new List<PublicContactClass>();

    List<Contact> contactsToUpdate = new List<Contact>();
    DataResult dataResult = new DataResult();

    for (TypeClass c : AllContacts) {
      if (c instanceof PrivateContactClass) {
        privateContact.add((PrivateContactClass) c);
      } else {
        publicContact.add((PublicContactClass) c);
      }
    }
    for (Integer i = 0; i < privateContact.size(); i++) {
      if (privateContact[i].contactType == 'Premier') {
        dataResult.nonChangedPrivateContact.add(privateContact[i]);
        continue;
      }
      if ((privateContact[i] != null) && (publicContact[i] != null)) {
        Id accountPrivateContact = privateContact[i].contactRecord.AccountId;
        privateContact[i].contactRecord.AccountId = publicContact[i]
          .contactRecord.AccountId;
        publicContact[i].contactRecord.AccountId = accountPrivateContact;

        contactsToUpdate.add(privateContact[i].contactRecord);
        contactsToUpdate.add(publicContact[i].contactRecord);

        dataResult.changedPrivateContact.add(privateContact[i]);
        dataResult.changedPublicContact.add(publicContact[i]);
      }
    }
    return dataResult;
  }

  public List<Contact> getALLContacts() {
    return [SELECT Id, AccountId, Amount__c FROM Contact];
  }
  /**
   * @description Generates Random Number
   */
  private Integer getRandomNumber() {
    String result = '';
    for (Integer i = 1; i <= RANDOM_NUMBER_LENGTH; i++) {
      Integer digit = (Integer) (Math.random() * 10);
      result += String.valueOf(digit);
    }
    Integer cardNumber = Integer.valueOf(result);
    return cardNumber;
  }
  /**
   * @description Calculate identical digits. It it 3 and higher -
   * It has ContactType = Premier otherwise Person.
   */
  public String getContactType(Integer cardNumber) {
    Boolean found = false;
    List<String> listCardNumber = String.valueOf(cardNumber).split('');
    Map<String, Integer> mapDigits = new Map<String, Integer>();
    for (String str : listCardNumber) {
      Integer value = mapDigits.get(str);

      if (value != null) {
        mapDigits.put(str, value + 1);
      } else {
        mapDigits.put(str, 1);
      }
      Integer updatedValue = mapDigits.get(str);
      if (updatedValue >= 3) {
        found = true;
        break;
      }
    }
    return found ? 'Premier' : 'Person';
  }
}
