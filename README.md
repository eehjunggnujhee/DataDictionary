# Generate Data Dictionary with Apex
The simple apex script to generate Salesforce data dictionary was born from a personal need to make the workflow as simple as one-click. The code is meant to run in anonymous window inside of Salesforce developer console making the whole process ephemeral. Please do try this code in a sandbox or a dev org.

# RUN
1. Open Developer Console
2. Open Anonymous Window
3. Copy and paste DataDictionary.cls
4. Remove all the comments
5. RUN
6. Open **Files** tab
7. You will see the exported **Data Dictionary -** on the top of **Owned By Me** files
8. The rest is up to your artistic expression with Excel formatting

---> See the [output](https://github.com/eehjunggnujhee/DataDictionary/blob/main/Data%20Dictionary%20-%208-21-2021,%2010-12%20PM.csv) from Salesforce dev org sample.

## MODIFICATION

`String[] sObjectTypes = new String[]{'Account','Contact','Lead','Opportunity','Campaign','CampaignMember'};`

- Replace the existing string values (ex. 'Account') of the **sObjectTypes** array to the API Names of sObjects you wish to retrieve.
- Extract a set of five sObjects at a time for sObject containing less than 200 fields. Cut down the number of sObject per transaction if each sObject contains more than 300+ fields and you do not love LOADING........1%...2%..3%.

### Disclaimer
- I did not include every info from the field definition. Let me know if you don't see what you want to see
- `,` will be removed from Label, Description, Formula, Help Text, and Picklist Values