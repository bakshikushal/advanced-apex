public with sharing class Constants {
    public static final integer DEFAULT_ROWS = 5;
    public static final String SELECT_ONE = LABEL.Select_One;
    public static final String INVENTORY_LEVEL_LOW = LABEL.Inventory_Level_Low;
    public static final List<Schema.PicklistEntry> PRODUCT_FAMILY = Product2.sobjectType.family.getDescribe().getPickListValues();
    public static final String DRAFT_ORDER_STATUS= 'Draft';
    public static final String ACTIVATED_ORDER_STATUS = 'Activated';
    public static final String INVENTORY_ANNOUNCEMENTS = 'Inventory Announcements';
    public static final String ERROR_MESSAGE = 'An error has occurred, please take a screenshot with the URL and send it to IT.';
    public static final String STANDARD_PRICEBOOK_ID = '01s5g000002c795AAA';

}