@isTest
private class AccountSwitcherImpl_Test {
  @TestSetup
  static void setupData() {
    List<Contact> contacts = TestDataFactory.createContacts();
    insert contacts;
  }

  @isTest
  private static void isPrivateAmountGreaterThan1000() {
    AccountSwitcherImpl accountSwitcher = new AccountSwitcherImpl();
    accountSwitcher.getAndSort();

    for (TypeClass c : AccountSwitcherImpl.AllContacts) {
      if (c instanceof PrivateContactClass) {
        PrivateContactClass privateContact = (PrivateContactClass) c;
        Assert.isTrue(
          privateContact.contactRecord.Amount__c > 1000,
          'Amount in AccountSwitcherImpl.AllContacts should be grater than 1000'
        );
      } else {
        PublicContactClass publicContact = (PublicContactClass) c;
        Assert.isFalse(
          publicContact.contactRecord.Amount__c > 1000,
          'Amount in AccountSwitcherImpl.AllContacts should be less than 1000'
        );
      }
    }
  }

  @isTest
  private static void checkContactTypeDependedOnCardNumber() {
    AccountSwitcherImpl accountSwitcher = new AccountSwitcherImpl();
    accountSwitcher.getAndSort();

    for (TypeClass c : AccountSwitcherImpl.AllContacts) {
      if (c instanceof PrivateContactClass) {
        PrivateContactClass privateContact = (PrivateContactClass) c;
        privateContact.cardNumber = 333421;
        privateContact.contactType = accountSwitcher.getContactType(
          privateContact.cardNumber
        );

        Assert.areEqual(
          privateContact.contactType,
          'Premier',
          'ContactType in Private Contact should Premier because cardNumber contains  3 identical digits '
        );
      } else {
        PublicContactClass publicContact = (PublicContactClass) c;
        Assert.areEqual(
          publicContact.contactType,
          'Person',
          'ContactType in Public Contact should Person'
        );
      }
    }
  }

  @isTest
  private static void switchAccount_Test() {
    List<PrivateContactClass> oldPrivateContact = new List<PrivateContactClass>();
    List<PublicContactClass> oldPublicContact = new List<PublicContactClass>();

    AccountSwitcherImpl accountSwitcher = new AccountSwitcherImpl();
    
    accountSwitcher.getAndSort();
    System.debug(AccountSwitcherImpl.AllContacts);
    // DataResult dataResult = accountSwitcher.switchAccount();
    // ;

    for (TypeClass c : AccountSwitcherImpl.AllContacts) {
      if (c instanceof PrivateContactClass) {
        oldPrivateContact.add((PrivateContactClass) c);
      } else {
        oldPublicContact.add((PublicContactClass) c);
      }
    }
     System.debug(oldPrivateContact);
    // System.debug(AccountSwitcherImpl.AllContacts);
    // accountSwitcher.switchAccount();

    // for (Integer i = 0; i < dataResult.changedPrivateContact.size(); i++) {
    //   Id pubAccId = oldPublicContact[i].contactRecord.Account.Id;
    //   Id privAccId = dataResult.changedPrivateContact[i]
    //     .contactRecord.Account.Id;
    //   Assert.areNotEqual(pubAccId, privAccId, 'They should have the same Account Id');
    // }

    // for (Integer i = 0; i < dataResult.changedPublicContact.size(); i++) {
    //   Id privAccId = oldPrivateContact[i].contactRecord.Account.Id;
    //   Id pubAccId = dataResult.changedPublicContact[i]
    //     .contactRecord.Account.Id;
    //   Assert.areEqual(pubAccId, privAccId, 'They should have the same Account Id');
    // }
  }
}
