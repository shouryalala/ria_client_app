import 'package:flutter/material.dart';

class Constants {
  static const String APP_NAME = "RIA";
  static final String DEBUG_TAG = "DEBUG_KANTA::";
  //Collections
  static final String COLN_REQUESTS = "requests";
  static final String COLN_USERS = "users";
  static final String COLN_ASSISTANTS = "assistants";
  static final String COLN_APPTS = "appts";
  static final String COLN_SOCIETIES = "societies";
  static final String COLN_VISITS = "visits";
  static final String COLN_FEEDBACK = "feedback";
  static final String COLN_CALLBACK = "callback";

  //Sub-collections
  static final String SUBCOLN_USER_ACTIVITY = "activity";
  static final String SUBCOLN_USER_FCM = "fcm";
  static final String DOC_USER_FCM_TOKEN = "client_token";
  static final String DOC_DEVICE_LOG = "DEVICE_LOG";
  static final String DOC_USER_ACTIVITY_STATUS = "status";
  static final String DOC_USER_ACTIVITY_STATS = "statistics";
  static final String SUBCOLN_AST_FEEDBACK = "feedback";

  //Firebase Storage
  static final String ASSISTANT_DP_PATH = "assistant_dp";

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
  static final String APPT_FIELD_PLOT = "plot";
  static final String APPT_FIELD_LANG_EN = "en";
  static final String APPT_FIELD_LANG_HI = "hi";

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
  static const String REQ_STATUS_ASSIGNED = "ASN";
  static const String REQ_STATUS_UNASSIGNED = "UNA";
  static const String AST_RESPONSE_NIL = "NIL";
  static const String AST_RESPONSE_ACCEPT = "ACCEPT";
  static const String AST_RESPONSE_REJECT = "REJECT";

  //incoming data payload type
  static const String COMMAND_WORK_REQUEST = "WRDP";
  static const String COMMAND_REQUEST_CONFIRMED = "RQDP";
  static const String COMMAND_VISIT_ONGOING = "VISON";
  static const String COMMAND_VISIT_CANCELLED = "VISCAN";
  static const String COMMAND_VISIT_COMPLETED = "VISCOM";
  static const String COMMAND_MISC_MESSAGE = "MISC";
  //misc message type
  static const String FLD_MISC_MESSAGE = 'msg_type';
  static const String NO_AVAILABLE_AST = 'NoAvailableAst';
  static const String SERVER_ERROR = 'ErrorMsg';

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
  static const int VISIT_STATUS_FAILED = -1;
  static const int VISIT_STATUS_CANCELLED = 0;
  static const int VISIT_STATUS_COMPLETED = 1;
  static const int VISIT_STATUS_ONGOING = 2;
  static const int VISIT_STATUS_UPCOMING = 3;
  static const int VISIT_STATUS_NONE = 4;
  static const int VISIT_STATUS_SEARCHING = 5;

  //Shared Preferences
  static final String SP_TOKEN = "client_token";
  static final String SP_TOKEN_PUSHED = "server_token_updated";

  //DECODES
  static const String DUSTING_CDE = "Dx";
  static const String CLEANING_CDE = "Cx";
  static const String UTENSILS_CDE = "Ux";
  static const String CHORE_CDE = "Chx";
  static const String CLEAN_UTENSIL_CDE = "CUx";
  static const String CLEAN_DUST_CDE = "CDx";
  static const String DUST_UTENSIL_CDE = "DUx";
  static const String CLEAN_DUST_UTENSIL_CDE = "CDUx";
  static final String PRIORITY_MIN = "Min";
  //DEFAULTS
  static final String DEFAULT = "X";
  static final String DEFAULT_TIME = "4:20 am";
  static final String DEFAULT_SERVICE = "Cleaning";
  static final String DEFAULT_ADDRESS = "3/202\n Beverly Park Appt\n Sector-22";
  //Home Screen constants
  static const String CLEANING = "Cleaning";
  static const String UTENSILS = "Utensils";
  static const String DUSTING = "Dusting";

  static const TimeOfDay dayStartTime = TimeOfDay(hour:7, minute: 0);
  //static const TimeOfDay dayEndTime = TimeOfDay(hour:19, minute: 0);
  static const TimeOfDay dayEndTime = TimeOfDay(hour:23, minute: 59); //test time
  static const TimeOfDay outOfBoundTimeStart = TimeOfDay(hour:0, minute:0);
  static const TimeOfDay outOfBoundTimeEnd = TimeOfDay(hour:6, minute:0);

  static const int ALLOWED_VISIT_SEARCH_BUFFER = 600; //been 10 mins since searching for assistant
  static const int ALLOWED_VISIT_UPCOMING_BUFFER = 3600; //been an hour since the ast was supposed to checkin
  static const int ALLOWED_VISIT_ONGOING_BUFFER = 3600; //been an hour since the ast had to checkout
  //Time error codes
  static const int TIME_ERROR_OUTSIDE_WINDOW = -1;
  static const int TIME_ERROR_SERVICE_OFF = -2;
  static const int TIME_ERROR_NOT_SELECTED = -3;
  static const int TIME_ERROR_PAST = -4;
  static const int TIME_VERIFIED = 0;


  static const String ABOUT_US_DESCRIPTION = '$APP_NAME is a simple idea to use technology to uplift the current regime of domestic help, for everyone.\n'
      'Users can:'
      'pick an assistant based on their ratings and reviews.'
      '  Switch assistants in case of delays or unplanned leaves.'
      'Pay standardized charges based on the services requested.'
      'Change timings or assistants as per their conveinience'
      'Assistants can:'
      'Find more work due to adhoc requests and a managed timetable'
      'Become technologically empowered and more independent'
      'Receive pay fairly and consistently'
      'We are currently in the beta stage where we are slowly getting the assistants accustomed to an app-based roster.'
      ' We are also using the new ratings to onboard better assistants. Due to this there might be some lapses on our end,'
      ' which is why, cryb is currently completely free for use. In time this system will become much stronger and will '
      'ensure that you never have to think about your home requirements ever again!';
}