generate-tokens.sh
==================

This script accepts a list of users and their auth providers and generates
non-derived tokens for them. The purpose of this is to work around an issue
where user attributes are not refreshed for users who only have derived tokens.

The tokens generated are non-functional, i.e. there is no secret string and
therefore the token resources cannot be used to log in or make requests.

The script accepts a CSV file containing broken users in the format
userid,provider. For example:

```
user-abcde,local
u-bcdef,local
u-cdefg,local
u-defgh12345,keycloak
u-efghi23456,keycloak
```

To get a list of auth provider tags, run `kubectl get authconfigs`.

After running the script, log in to Rancher and navigate to "Users &
Authentication" -> Users. Using the checkboxes on the left side of the screen,
select every affected user and click "Refresh Group Memberships".

The script does NOT work on users with provider 'shibboleth'. To fix broken
shibboleth users, you must log in to the Rancher dashboard as the user.
