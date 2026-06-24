public with sharing class PrivateContactClass extends TypeClass {
  public Integer cardNumber;
  public Contact contactRecord;

  public PrivateContactClass() {}

  public Integer getCardNumber() {
    return cardNumber;
  }

  public Contact getContactRecord() {
    return contactRecord;
  }
}
