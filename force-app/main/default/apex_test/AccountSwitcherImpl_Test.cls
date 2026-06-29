@isTest
private class AccountSwitcherImpl_Test {
  @TestSetup
  static void setupData() {
    List<Account> accounts = TestDataFactory.createAccounts();
    insert accounts;
    List<Account> insertedAccounts = TestDataFactory.getAccounts();

    List<Contact> contacts = TestDataFactory.createContacts(insertedAccounts);
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
          privateContact.contactRecord.Amount__c > 10000,
          'Amount in AccountSwitcherImpl.AllContacts should be grater than 1000'
        );
      } else {
        PublicContactClass publicContact = (PublicContactClass) c;
        Assert.isFalse(
          publicContact.contactRecord.Amount__c > 10000,
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
  private static void isAccountIdBelongedPreviousContact() {
    List<PrivateContactClass> oldPrivateContact = new List<PrivateContactClass>();
    List<PublicContactClass> oldPublicContact = new List<PublicContactClass>();

    AccountSwitcherImpl accountSwitcher = new AccountSwitcherImpl();

    accountSwitcher.getAndSort();
    DataResult dataResult = accountSwitcher.switchAccount();
   

    for (TypeClass c : AccountSwitcherImpl.AllContacts) {
      if (c instanceof PrivateContactClass) {
        oldPrivateContact.add((PrivateContactClass) c);
      } else {
        oldPublicContact.add((PublicContactClass) c);
      }
    }


    for (Integer i = 0; i < 20; i++) {
      Id pubAccId = oldPublicContact[i].contactRecord.AccountId;
      Id privAccId = dataResult.changedPrivateContact[i]
        .contactRecord.AccountId;
      Assert.areEqual(
        pubAccId,
        privAccId,
        'They should have the same Account Id'
      );
    }

    for (Integer i = 0; i < 20; i++) {
      Id privAccId = oldPrivateContact[i].contactRecord.AccountId;
      Id pubAccId = dataResult.changedPublicContact[i].contactRecord.AccountId;
      Assert.areEqual(
        pubAccId,
        privAccId,
        'They should have the same Account Id'
      );
    }
  }
}
