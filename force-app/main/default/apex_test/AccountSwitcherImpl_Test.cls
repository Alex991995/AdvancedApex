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

    for (TypeClass c : accountSwitcher.AllContacts) {
      if (c instanceof PrivateContactClass) {
        PrivateContactClass privateContact = (PrivateContactClass) c;
        Assert.isTrue(
          privateContact.contactRecord.Amount__c > 10000,
          'Amount in AccountSwitcherImpl.AllContacts should be grater than 10000'
        );
      } else {
        PublicContactClass publicContact = (PublicContactClass) c;
        Assert.isFalse(
          publicContact.contactRecord.Amount__c > 10000,
          'Amount in AccountSwitcherImpl.AllContacts should be less than 10000'
        );
      }
    }
  }

  @IsTest
  private static void checkContactTypeDependedOnCardNumber() {
    AccountSwitcherImpl accountSwitcher = new AccountSwitcherImpl();
    accountSwitcher.getAndSort();

    for (TypeClass c : accountSwitcher.AllContacts) {
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
    List<Id> oldPrivateContactAccountId = new List<Id>();
    List<Id> oldPublicContactAccountId = new List<Id>();

    AccountSwitcherImpl accountSwitcher = new AccountSwitcherImpl();
    accountSwitcher.getAndSort();

    for (TypeClass c : accountSwitcher.AllContacts) {
      if (c instanceof PrivateContactClass) {
        PrivateContactClass privateContact = (PrivateContactClass) c;
        oldPrivateContactAccountId.add(privateContact.contactRecord.AccountId);
      } else {
        PublicContactClass publicContact = (PublicContactClass) c;
        oldPublicContactAccountId.add(publicContact.contactRecord.AccountId);
      }
    }

    DataResult dataResult = accountSwitcher.switchAccount();

    Integer numberExistedPrivateAccountId = 0;
    Integer numberExistedPublicAccountId = 0;

    /**
     * @description я проверяю на существование DataResult-PrivateContact-AccountId в PublicContact AccountId
     * и считаю сколько совпадний и проверяю длину DataResult-PrivateContact
     */
    for (PrivateContactClass c : dataResult.changedPrivateContact) {
      Boolean isExist = oldPublicContactAccountId.contains(
        c.contactRecord.AccountId
      );
      if (isExist) {
        numberExistedPrivateAccountId += 1;
      }
    }

    Assert.areEqual(
      numberExistedPrivateAccountId,
      dataResult.changedPrivateContact.size(),
      'the number of matching Account ids must be the same as the changedPrivateContact size.'
    );

    /**
     * @description тоже самое но наоброт
     */
    for (PublicContactClass c : dataResult.changedPublicContact) {
      Boolean isExist = oldPrivateContactAccountId.contains(
        c.contactRecord.AccountId
      );
      if (isExist) {
        numberExistedPublicAccountId += 1;
      }
    }

    Assert.areEqual(
      numberExistedPublicAccountId,
      dataResult.changedPublicContact.size(),
      'the number of matching Account ids must be the same as the changedPublicContact size.'
    );
  }
}
