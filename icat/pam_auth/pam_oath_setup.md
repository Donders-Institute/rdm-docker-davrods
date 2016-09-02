# Setting up PAM_OATH for One-time password

## install PAM_OATH package and oathtool

```bash
$ yum install pam_oath
$ yum install oathtool
```

## add PAM file for irods

```bash
$ echo 'auth [success=ok new_authtok_reqd=ok default=die] pam_oath.so usersfile=/etc/irods/users.oath window=1 digits=6' > /etc/pam.d/irods
```
