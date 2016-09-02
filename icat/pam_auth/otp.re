ACC_RODS_ADMIN = "rods"
ACC_RODS_ADMIN_PASS = "demo123"
OTP_REGEX = "^[0-9]{6}$"
EC_FORBIDDEN_ACTION = -1

#-----------------------------------------------------------------------
# pre/post-processing rules for user creation and deletion
#-----------------------------------------------------------------------
acPostProcForCreateUser {
    ON( $otherUserType == "rodsuser" ) {
        # hook on rdmOtpAddUser.sh ACC_RODS_ADMIN_PASS $otherUserName
        # on success, set the returned OTP-key as metadata of the user
        msiExecCmd("rdmOtpAddUser.sh", ACC_RODS_ADMIN_PASS++" "++$otherUserName, "null", "null", "null", *out);
    }
}

acDeleteUser {

  acPreProcForDeleteUser;

  ## query to get user type
  *otherUserType = "";
  foreach(*r in SELECT USER_TYPE WHERE USER_NAME = '$otherUserName') {
      *otherUserType = *r.'USER_TYPE';
  }
  acDeleteUserF1;

  ## only execute the postprocess when the deleting user is a rodsuser
  ## this ignores the case of deleting iRODS user groups
  if ( *otherUserType == 'rodsuser' ) {
      acPostProcForDeleteUser;
  }
}

acPostProcForDeleteUser {
    # hook on rdmOtpDeleteUser.sh ACC_RODS_ADMIN_PASS $otherUserName
    msiExecCmd("rdmOtpDeleteUser.sh", ACC_RODS_ADMIN_PASS++" "++$otherUserName, "null", "null", "null", *out);
}

#-----------------------------------------------------------------------
# irodsUserExist: checks whether the given iRODS username exists. 
#
# [Input]
#  - *userName: the iRODS username 
#
# [Output]
#  - *rslt: true if the given iRODS username can be mapped to an iRODS userid 
#-----------------------------------------------------------------------
irodsUserExist(*userName, *rslt) {
    *rslt = false;
    foreach( *r in SELECT USER_ID WHERE USER_NAME = '*userName' ) {
        *rslt = true;
    }
}

#-----------------------------------------------------------------------
# uiGetUserNextHOTP: gets user's next event-based one-time password.
#
# [Input]
#  - *userName: the iRODS user name
#
# [Output]
#  - *out: exit-code, errmsg and OTP in JSON format.
#          If the OTP is properly returned, the exit-code is 0.
#-----------------------------------------------------------------------
uiGetUserNextHOTP(*userName, *out) {
    *ec  = 0;
    *errmsg = "";
    *otp = "xxxxxx";

    irodsUserExist(*userName, *ick);

    if (! *ick) {
        *ec = EC_FORBIDDEN_ACTION;
        *errmsg = "user not found: " ++ *userName;
    } else if ($userNameClient == ACC_RODS_ADMIN || $userNameClient == *userName) {
        *ec = errormsg(msiExecCmd("rdmOtpGetNextHOTP.sh", ACC_RODS_ADMIN_PASS++" "++*userName, "null", "null", "null", *cmdOut),*errmsg);
        msiGetStderrInExecCmdOut(*cmdOut, *stdErr);
        msiGetStdoutInExecCmdOut(*cmdOut, *stdOut);

        if ( *ec != 0 ) {
            *errmsg = "OTP retrieval failed: " ++ *stdErr;
        } else {
            if ( *stdOut like regex OTP_REGEX ) {
                *otp = trimr(*stdOut,"\n");
            } else {
                *ec = -1;
                *errmsg = trimr(*stdErr,"\n");
            }
        }
    } else if ( $userNameClient != *userName && $userNameClient != ACC_RODS_ADMIN ) {
        *ec = EC_FORBIDDEN_ACTION;
        *errmsg = "OTP can only be retrived by the same user or the iRODS admin";
    }

    ## make sure the " character is escaped
    #msi_str_replace(*errmsg, '"', '\\"', *errmsg);
    *out = '{"otp":"' ++ *otp ++ '", "ec":' ++ str(*ec) ++ ', "errmsg":"' ++ *errmsg ++ '"}';
}
