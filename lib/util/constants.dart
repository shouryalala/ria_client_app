class Constants {
  static final String DEBUG_TAG = "DEBUG_KANTA::";
  //Collections
  static final String COLN_REQUESTS = "requests";
  static final String COLN_USERS = "users";
  static final String COLN_ASSISTANTS = "assistants";
  static final String COLN_APPTS = "appts";
  static final String COLN_VISITS = "visits";
  static final String COLN_FEEDBACK = "feedback";

  static final int RETROFIT_NETWORK_ERROR = 11;
  static final int FIREBASE_LOGIN_ERROR = 22;
  static final int FIREBASE_FETCH_ERROR = 33;
  static final int MY_REQUEST_ACCESS_FINE_LOCATION_FROM_HOME = 68;
  static final int MY_REQUEST_ACCESS_FINE_LOCATION_FROM_SETUP = 69;
  static final String ALLOW_SKIPPING_KEY = "allowSkipping";

  //User fields
  static final String FIELD_CLIENT_TOKEN = "mClientToken";
  static final String CT_UPDATE_TIMESTAMP = "mCtTmstmp";

  //Appt object fields
  static final String APPT_FIELD_DISTRICT = "district";
  static final String APPT_FIELD_SECTOR = "sector";
  static final String APPT_FIELD_LANG_ENG = "eng"; //TODO change to en and hi
  static final String APPT_FIELD_LANG_HIN = "hin";

  //Firebase Visit Object fields
  static final String FIELD_ASSISTANT_ID = "ass_id";
  static final String FIELD_VISIT_USER_ID = "user_id";
  static final String FIELD_VISIT_DATE = "date";
  static final String FIELD_VISIT_REQ_START_TIME = "req_st_time";
  static final String FIELD_VISIT_REQ_END_TIME = "req_en_time";
  static final String FIELD_VISIT_ACT_START_TIME = "act_st_time";
  static final String FIELD_VISIT_ACT_END_TIME = "act_en_time";
  static final String FIELD_VISIT_STATUS = "status";

  //Request obj fields
  static final String REQ_STATUS_ASSIGNED = "ASN";
  static final String REQ_STATUS_UNASSIGNED = "UNA";
  static final String AST_RESPONSE_NIL = "NIL";
  static final String AST_RESPONSE_ACCEPT = "ACCEPT";
  static final String AST_RESPONSE_REJECT = "REJECT";

  //incoming data payload type
  static final String COMMAND_WORK_REQUEST = "WRDP";
  static final String  COMMAND_REQUEST_CONFIRMED = "RQDP";

  //Service decodes
  static final String SERVICE_CLEANING = "Cx";
  static final String SERVICE_DUSTING = "Dx";
  static final String SERVICE_UTENSILS = "Ux";
  static final String SERVICE_CHORE = "Chx";
  static final String SERVICE_CLEANING_UTENSILS = "CUx";

  //Service Durations
  static final int SERVICE_CLEANING_DURATION = 1800;
  static final int SERVICE_UTENSILS_DURATION = 900;

  //Visit decodes
  static final int VISIT_STATUS_FAILED = -1;
  static final int VISIT_STATUS_CANCELLED = 0;
  static final int VISIT_STATUS_COMPLETED = 1;
  static final int VISIT_STATUS_ONGOING = 2;
  static final int VISIT_STATUS_UPCOMING = 3;

  //Shared Preferences
  static final String SP_TOKEN = "client_token";
  static final String SP_TOKEN_PUSHED = "server_token_updated";


  //DECODES
  static final String DUSTING_CDE = "Dx";
  static final String CLEANING_CDE = "Cx";
  static final String UTENSILS_CDE = "Ux";
  static final String CHORE_CDE = "Chx";
  static final String CLEAN_UTENSIL_CDE = "CUx";
  static final String PRIORITY_MIN = "Min";

  //DEFAULTS
  static final String DEFAULT = "X";
  static final String DEFAULT_TIME = "10:12am";
  static final String DEFAULT_SERVICE = "Cleaning";
  static final String DEFAULT_ADDRESS = "3/202\n Beverly Park Appt\n Sector-22";
}