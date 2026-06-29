@IsTest
private class AccountSwitcherImpl_Test {
  @TestSetup
  private static void setupData() {
    List<Account> accounts = TestDataFactory.createAccounts();
    insert accounts;
    List<Account> insertedAccounts = TestDataFactory.getAccounts();

    List<Contact> contacts = TestDataFactory.createContacts(insertedAccounts);
    insert contacts;
  }

  @IsTest
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

  @IsTest
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

  @IsTest
  private static void isAccountIdBelongedPreviousContact() {
    // List<PrivateContactClass> oldPrivateContact = new List<PrivateContactClass>();
    // List<PublicContactClass> oldPublicContact = new List<PublicContactClass>();
    List<Id> oldPrivateContactId = new List<Id>();
    List<Id> oldPublicContactId = new List<Id>();

    AccountSwitcherImpl accountSwitcher = new AccountSwitcherImpl();
    accountSwitcher.getAndSort();

    for (TypeClass c : AccountSwitcherImpl.AllContacts) {
      if (c instanceof PrivateContactClass) {
        PrivateContactClass privateContact = (PrivateContactClass) c;
        oldPrivateContactId.add(privateContact.contactRecord.AccountId);
      } else {
        PublicContactClass PublicContact = (PublicContactClass) c;
        oldPublicContactId.add(publicContact.contactRecord.AccountId);
      }
    }

    DataResult dataResult = accountSwitcher.switchAccount();

    for (Integer i = 0; i < 10; i++) {
      Id pubAccId = oldPublicContactId[i];
      Id privAccId = dataResult.changedPrivateContact[i]
        .contactRecord.AccountId;
      Assert.areEqual(
        pubAccId,
        privAccId,
        'They should have the same Account Id'
      );
    }

    for (Integer i = 0; i < 10; i++) {
      Id privAccId = oldPrivateContactId[i];
      Id pubAccId = dataResult.changedPublicContact[i].contactRecord.AccountId;
      Assert.areEqual(
        pubAccId,
        privAccId,
        'They should have the same Account Id'
      );
    }
  }
}
