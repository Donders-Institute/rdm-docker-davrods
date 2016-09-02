# PAM module configuration

This PAM setup enables iRODS to use the event-based one-time password ([HOTP](https://en.wikipedia.org/wiki/HMAC-based_One-time_Password_Algorithm)) to authenticate client; while allows temporarily re-using the same one-time password for consequent client interactions which is helpful for the WebDAV and RESTful clients.

The feature of re-using same one-time password for authentication is implemented by caching an authentication token as an iRODS' user attribute, using the bash script (`otp_cache`) through the [pam_script plugin](https://github.com/jeroennijhof/pam_script).

If authentication token cacheing is not needed in your setup, simply refer to [here](pam_oath_setup.md) using only the one-time password mechanism.

## The authentication token

Following a successufl login with the one-time password, an authentication token is generated as a hash of a combination of the username and the one-time password. The token (together with it's validity) is then stored as an attribute (`authToken`) of the iRODS user.

In the consequent authentications, when the hash constructed from the given username-password combination is found to be a valid token, the user is authenticated immediately. During this checking procedure, the validity of the matched token may be extended.

The `otp_cache` script accept few optional argument to adjust the caching behaviour. Please refer to the comments in the script for more detail.

## System requirement

- PAM framework
- [`pam_oath`](http://www.nongnu.org/oath-toolkit/pam_oath.html): PAM module for one-time password
- [`pam_script`](https://github.com/jeroennijhof/pam_script): PAM module using provided shell scripts for PAM actions

## Installation

```bash
$ yum install pam pam_oath oathtool pam_script
$ mkdir /etc/irods/pam_script
$ cp otp_cache /etc/irods/pam_script
$ env PAMSCRIPTDIR=/etc/irods/pam_script \
      /etc/pam_script -v -x -s auth /etc/irods/pam_script/otp_cache
```
