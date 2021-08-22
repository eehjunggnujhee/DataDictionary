/* ============================================================================================
@authror twitter handle @reality_jung
@instruction
    Copy and paste the entire code into the anonymous window and run
    Open "Files" tab and find the CSV file named, <Timestamp> - DataDictionary.csv
    ',' will be removed from Label, Description, Formula, Help Text, and Picklist Values
=============================================================================================== */
/* ============================================================================================
    1. Setup an array of sObject 
    2. Build a string for database.query into FieldDefinition
    3. Setup CSV file header columns
=============================================================================================== */

String[] sObjectTypes = new String[]{'Account','Contact','Lead','Opportunity','Campaign','CampaignMember'}; //add more objects, recommend runing 5 objects at a time
List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(sObjectTypes); 

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
    Loop 1-2 : Loop through an array of Schema.DescribeSobjectResult and process each sObject
    Loop 1-2-1 : Loop through each Schema.DescribeSobjectResult and populate each field's metadata
    Loop 1-2-1-1 : Loop through an array of PicklistEntry and cascade picklist's label values into a string
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
// LOOP 1-2
    for (Schema.DescribeSobjectResult result : results) {
      Map<String, Schema.SObjectField> fieldMap = result.fields.getMap();
      Set<String> fieldNames = fieldMap.keySet(); // get fields' API names   
      String sObjectName = result.getName(); // get sObject API name
        if(sObjectName == sObjName){ // gaurantees processing same object from the query and the schema metatdata from DescribeSobjectResult
// LOOP 1-2-1            
            for(String fieldName : fieldNames) {
                csvStr += sObjectName+','
                    + fieldMap.get(fieldName).getDescribe().getSObjectField() +','
                    + fieldMap.get(fieldName).getDescribe().getLabel().replaceAll(',',' ') + ','
                    + fieldMap.get(fieldName).getDescribe().getType() + ','
                    + fieldMap.get(fieldName).getDescribe().getLength() + ','
                    + fieldMap.get(fieldName).getDescribe().getPrecision() + ','
                    + fieldMap.get(fieldName).getDescribe().getByteLength() + ','
                    + fieldMap.get(fieldName).getDescribe().getDigits() + ','
                    + fieldMap.get(fieldName).getDescribe().getRelationshipName() + ','
                    + fieldMap.get(fieldName).getDescribe().isCalculated() + ','
                    + fieldMap.get(fieldName).getDescribe().isCustom() + ','
                    + fieldMap.get(fieldName).getDescribe().isDependentPicklist() + ','
                    + fieldMap.get(fieldName).getDescribe().isRestrictedPicklist() + ','
                    + fieldMap.get(fieldName).getDescribe().isExternalID() + ','
                    + fieldMap.get(fieldName).getDescribe().isFormulaTreatNullNumberAsZero() + ','
                    + fieldMap.get(fieldName).getDescribe().isUnique() + ','
                    + fieldMap.get(fieldName).getDescribe().isSearchPrefilterable() + ','
                    + fieldMap.get(fieldName).getDescribe().getDefaultValue() + ','
                    + fieldMap.get(fieldName).getDescribe().getInlineHelpText()?.replaceAll('(\r\n|\r|\n)','').replaceAll(',','') +','; // Safe Navigator Operator
    
                if(fieldMap.get(fieldName).getDescribe().getCalculatedFormula()!=null){ // prevents dereference error
                    csvStr += fieldMap.get(fieldName).getDescribe().getCalculatedFormula().replaceAll('(\\s*|\r\n|\r|\n)','').replaceAll(',','')+','; 
                }else{
                   csvStr += fieldMap.get(fieldName).getDescribe().getCalculatedFormula()+',';
                }
                if(fieldMap.get(fieldName).getDescribe().getPicklistValues()!=null){ // get a list of pickvalues' labels from Schema.PicklistEntry
                    String values ='';
// LOOP 1-2-1-1
                    for(Schema.PicklistEntry picklist : FieldMap.get(fieldName).getDescribe().getPicklistValues()){
                        
                        values += picklist.getLabel().replaceAll(',',' ') + ' | ';
                    }
                    values = values?.removeEnd(' | ');
                    csvStr += values + ',';
                }else{
                    csvStr += ''+',';
                }
                
                sObject o = fieldNameObject.get(fieldName); // initialize sObject 0 
                
                if(o != null){ 
                    csvStr += (String)o.get('QualifiedApiName') + ','
                    + ((String)o.get('Description'))?.replaceAll('(\r\n|\r|\n)','').replaceAll(',','') + ','
                    + ((String)o.get('DataType')).replaceAll('(\\s*|\r\n|\r|\n)','').replaceAll(',','') + ','
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
conVer.PathOnClient = System.Now().format() +'- DataDictionary.csv'; // Set the file name with the extension; will use in preview
conVer.Title = 'Data Dictionary - '+System.Now().format(); // Display name of the file
conVer.VersionData = csvBlob; // based on base64 encoded

INSERT conVer;    //Insert ContentVersion 
