/* ============================================================================================
@author @reality_jung
@instruction
    Copy and paste the entire code into the anonymous window, remove comments and run
    Open "Files" tab and find the CSV file named, <Timestamp> - DataDictionary.csv
    Beautify the CSV file

@credits Thanks for trailblazers who provided warm advices to improve the code.
=============================================================================================== */
/* ============================================================================================
    1. Setup a string array of sObject 
    2. Build a string for database.query into FieldDefinition
    3. Setup CSV file header columns
=============================================================================================== */

String[] sObjectTypes = new String[]{'Account','Contact','Lead','Opportunity','Campaign','CampaignMember'}; //add more objects, recommend runing 5 objects at a time

String queryFields ='QualifiedApiName,Description,DataType,IsCompactLayoutable,IsCompound,IsFieldHistoryTracked,'
                    + 'IsHighScaleNumber,IsHtmlFormatted,IsIndexed,IsListFilterable,IsListSortable,IsListVisible,'
                    + 'IsNillable,IsPolymorphicForeignKey,IsSearchPrefilterable,IsWorkflowFilterable,LastModifiedDate,NamespacePrefix' ;
                    

Map<String,String> mapResult = new Map<String,String>();
String csvHeader = 'Object Name,Field Name,Label,Type,Length,Precision,ByteLength,Digit,Relationship Name,isCalculated,isCustom,isDependentPicklist,isRestrictedPicklist,isExternalID,TreatNULLasZERO,isUnique,isSearchPrefilterable,getDefaultValue,Help Text,Formula,Picklist Values,'+ queryFields+'\n'; // csv header
String csvStr = csvHeader;

/* ============================================================================================
    Loop 1 : Loop through "sObjectTypes: string array and make database query into FieldDeinition
    one object at a time.
    Loop 1-1 : Loop through returned sObject list from the FieldDefinition and build a map collection with field API name as key and sObject as value
    Loop 1-2 : Loop through each Schema.SObjectField and populate each field's metadata
    Loop 1-2-1 : Loop through an array of PicklistEntry and cascade picklist's label values into a string
=============================================================================================== */

// LOOP 1
for(String sObjName : sObjectTypes){
    String query = 'SELECT '
                + queryFields
                + ' FROM FieldDefinition WHERE EntityDefinitionId = \'' 
                + sObjName
                +'\' ORDER BY Label ASC';

    List<sObject> fieldDescribe = Database.query(query);

    Map<String,sObject> fieldNameObject = new Map<String,sObject>();
// LOOP 1-1
    for(sObject oneField : fieldDescribe) {
        String fieldName = oneField.get('QualifiedApiName').toString().toLowerCase();
        fieldNameObject.put(fieldName,oneField);
        system.debug(fieldNameObject);
    }
    sObjectType t = ((sObject)Type.forName('Schema.'+sObjName).newInstance()).getSObjectType();
    DescribeSobjectResult r = t.getDescribe();
    Map<String, Schema.SObjectField> fieldMap = r.fields.getMap();
    Set<String> fieldNames = fieldMap.keySet();
// LOOP 1-2           
    for(String fieldName : fieldNames) {
        DescribeFieldResult tmptField = fieldMap.get(fieldName).getDescribe();
        csvStr += sObjName+','
            + tmptField.getSObjectField() +','
            + tmptField.getLabel().escapeCsv() + ','
            + tmptField.getType() + ','
            + tmptField.getLength() + ','
            + tmptField.getPrecision() + ','
            + tmptField.getByteLength() + ','
            + tmptField.getDigits() + ','
            + tmptField.getRelationshipName() + ','
            + tmptField.isCalculated() + ','
            + tmptField.isCustom() + ','
            + tmptField.isDependentPicklist() + ','
            + tmptField.isRestrictedPicklist() + ','
            + tmptField.isExternalID() + ','
            + tmptField.isFormulaTreatNullNumberAsZero() + ','
            + tmptField.isUnique() + ','
            + tmptField.isSearchPrefilterable() + ','
            + tmptField.getDefaultValue() + ','
            + tmptField.getInlineHelpText()?.escapeCsv() +','; // Safe Navigator Operator

        if(tmptField.getCalculatedFormula()!=null){ // prevents dereference error
            csvStr += tmptField.getCalculatedFormula().escapeCsv()+','; 
        }else{
            csvStr += tmptField.getCalculatedFormula()+',';
        }
        if(tmptField.getPicklistValues()!=null){ // get a list of pickvalues' labels from Schema.PicklistEntry
            String[] values = new String[]{};
            String value = '';
// LOOP 1-2-1
            for(Schema.PicklistEntry picklist : tmptField.getPicklistValues()){
                
                values.add(picklist.getLabel());
            }
                if(values != null) {
                    value = String.join(values,' | ').escapeCsv();
                }
            csvStr += value + ',';
        }else{
            csvStr += ''+',';
        }
        
        sObject o = fieldNameObject.get(fieldName); // initialize sObject o 
        
        if(o != null){ 
            csvStr += (String)o.get('QualifiedApiName') + ','
            + ((String)o.get('Description'))?.escapeCsv() + ','
            + ((String)o.get('DataType')).escapeCsv() + ','
            + o.get('IsCompactLayoutable') + ','
            + o.get('IsCompound')+ ','
            + o.get('IsFieldHistoryTracked')+ ','
            + o.get('IsHighScaleNumber') + ','
            + o.get('IsHtmlFormatted') + ','
            + o.get('IsIndexed') + ','
            + o.get('IsListFilterable') + ','
            + o.get('IsListSortable')+ ','
            + o.get('IsListVisible') + ','
            + o.get('IsNillable')+ ','
            + o.get('IsPolymorphicForeignKey') + ','
            + o.get('IsSearchPrefilterable') + ','
            + o.get('IsWorkflowFilterable')+ ','
            + o.get('LastModifiedDate') + ','
            + (String)o.get('NamespacePrefix'); 
        }
        csvStr += '\n';
    }
}

/* ============================================================================================
    Build CSV file & Insert it as a ContentVersions record
    Check the "Files" tab for the uploaded CSV file.

    ContentVersion API: https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api_objects_contentversion.htm
    Blob API : https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_blob.htm
    Safe Navigator Operator : https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/langCon_apex_SafeNavigationOperator.htm
=============================================================================================== */

blob csvBlob = Blob.valueOf(csvStr); // convert String to binary data

ContentVersion conVer = new ContentVersion();
conVer.Origin = 'C'; // Content document from the user's personal library
conVer.PathOnClient = System.Now().format() +' - DataDictionary.csv'; // Set the file name with the extension; will use in preview
conVer.Title = 'Data Dictionary - ' + String.join(sObjectTypes,'-')+ ' - ' +System.Now().format(); // Display name of the file
conVer.VersionData = csvBlob; // based on base64 encoded

INSERT conVer;    //Insert ContentVersion 
