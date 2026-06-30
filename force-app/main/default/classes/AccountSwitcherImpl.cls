public with sharing class AccountSwitcherImpl implements AccountSwitcher {
  final integer RANDOM_NUMBER_LENGTH = 6;
  private static final String TYPE_PREMIER = 'Premier';
  private static final String TYPE_PERSON = 'Person';
  public List<TypeClass> AllContacts = new List<TypeClass>();

  public void getAndSort() {
    List<Contact> contacts = getAllContacts();

    for (Contact c : contacts) {
      if (c.Amount__c > 10000) {
        PrivateContactClass privateContact = new PrivateContactClass();
        privateContact.contactRecord = c;
        privateContact.cardNumber = getRandomNumber();
        privateContact.contactType = getContactType(privateContact.cardNumber);
        AllContacts.add(privateContact);
      } else {
        PublicContactClass publicContact = new PublicContactClass();
        publicContact.contactRecord = c;
        publicContact.volunteerNumber = getEvenRandomNumber();
        publicContact.contactType = TYPE_PERSON;
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
      if (privateContact[i].contactType == TYPE_PREMIER) {
        dataResult.nonChangedPrivateContact.add(privateContact[i]);
        continue;
      }
      if ((privateContact[i] != null) && (publicContact[i] != null)) {
        Id accountPrivateId = privateContact[i].contactRecord.AccountId;
        privateContact[i].contactRecord.AccountId = publicContact[i]
          .contactRecord.AccountId;
        publicContact[i].contactRecord.AccountId = accountPrivateId;

        contactsToUpdate.add(privateContact[i].contactRecord);
        contactsToUpdate.add(publicContact[i].contactRecord);

        dataResult.changedPrivateContact.add(privateContact[i]);
        dataResult.changedPublicContact.add(publicContact[i]);
      }
    }
    try {
      update contactsToUpdate;
    } catch (DmlException e) {
      System.debug('DML failed at line: ' + e.getLineNumber());
      System.debug('Error message: ' + e.getMessage());
    }
    return dataResult;
  }

  public List<Contact> getAllContacts() {
    return [SELECT Id, AccountId, Amount__c FROM Contact];
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
    return found ? TYPE_PREMIER : TYPE_PERSON;
  }

  /**
   * @description Generates Random Number
   */
  private Integer getRandomNumber() {
    String result = '';

    while (result.length() < RANDOM_NUMBER_LENGTH) {
      Integer digit = (Integer) (Math.random() * 10);
      if (result.length() == 0 && digit == 0) {
        continue;
      }
      result += String.valueOf(digit);
    }
    Integer cardNumber = Integer.valueOf(result);
    return cardNumber;
  }

  private Integer getEvenRandomNumber() {
    String result = '';

    while (result.length() < RANDOM_NUMBER_LENGTH) {
      Integer digit = (Integer) (Math.random() * 10);
      if (result.length() == 0 && digit == 0) {
        continue;
      }
      if (Math.mod(digit, 2) == 0) {
        result += String.valueOf(digit);
      }
    }
    Integer cardNumber = Integer.valueOf(result);
    return cardNumber;
  }
}
