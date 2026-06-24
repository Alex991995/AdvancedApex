public with sharing class PublicContactClass extends TypeClass {
  public Integer volunteerNumber;
  public Contact contactRecord;

  public PublicContactClass() {}

  public Integer getVolunteerNumber() {
    return volunteerNumber;
  }

  public Contact getContactRecord() {
    return contactRecord;
    
  }
  

}