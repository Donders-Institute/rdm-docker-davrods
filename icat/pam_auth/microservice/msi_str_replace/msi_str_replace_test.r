myTestRule {

   *str_org = "surName=Lee;;givenName=David;;email=d.lee@gmail.com";
   *str_search = ";;";
   *str_replace = "%";

   msi_str_replace( *str_org, *str_search, *str_replace, *str_new);

   writeLine("stdout",*str_new);
}
OUTPUT ruleExecOut

