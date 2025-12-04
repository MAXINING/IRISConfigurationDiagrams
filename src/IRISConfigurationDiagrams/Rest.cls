Class IRISConfigurationDiagrams.Rest Extends %CSP.REST
{

Parameter HandleCorsRequest = "true";

XData UrlMap [ XMLNamespace = "http://www.IRISConfigurationDiagrams.com/urlmap" ]
{
<Routes>
  <Route Url="/*" Method="OPTIONS" Call="Status"/>
  <Route Url="/:Method" Method="POST" Call="IRISConfiguration"/>
  
</Routes>
}

ClassMethod Status() As %Status
{
    Quit $$$OK
}

ClassMethod IRISConfiguration(method As %String) As %Status
{
	try{
		if method="NamespacesList"{
			Set status=..NamespacesList(.pOutput)
		}elseif(method="Namespace2Globals"){
			Set status=..Namespace2Globals(.pOutput)
		}elseif(method="Namespace2Routines"){
			Set status=..Namespace2Routines(.pOutput)
		}elseif(method="Namespace2Packages"){
			Set status=..Namespace2Packages(.pOutput)
		}elseif(method="MirrorDiagrams"){
			Set status=..MirrorDiagrams(.pOutput)
		}else{
			Set pOutput=..Failure("Incorrect request path")
		}
	}catch(ex){
		Set pOutput=..Failure("Request error. Please check if the parameters are correct")
	}
	Do %response.SetHeader("Content-Type", "application/json;charset=UTF-8")
	w pOutput
    Quit $$$OK
}

ClassMethod NamespacesList(Output pOutput As %String) As %Status
{
	Set queryStr="call Config.Namespaces_List()"
	Set statement = ##class(%SQL.Statement).%New()
	Set qStatus = statement.%Prepare(queryStr)
	if qStatus'=1 {DO $System.Status.DisplayError(qStatus)}
	#dim rset As %SQL.StatementResult = statement.%Execute()
    set array=##class(%DynamicArray).%New()
	while rset.%Next(){
		Set namespaceObj = ##class(%DynamicObject).%New()
		Set namespaceObj=namespaceObj.%Set("id",rset.%Get("Namespace"))
		Set namespaceObj=namespaceObj.%Set("name",rset.%Get("Namespace"))
		Set namespaceObj=namespaceObj.%Set("description","Globals Database is "_rset.%Get("Globals")_",Routines Database is "_rset.%Get("Routines"))
		Set namespaceObj=namespaceObj.%Set("color","#27ae60")
		Set namespaceObj=namespaceObj.%Set("status","active")
		do array.%Push(namespaceObj)
	}
	Set pOutput=..Success(array)
	Quit $$$OK
}

ClassMethod Namespace2Globals(Output pOutput As %String) As %Status
{
	Set requestStr=%request.Content.Read()
	Set returnObj = ##class(%DynamicObject).%New()
	#Dim json As %DynamicObject =##class(%DynamicObject).%FromJSON(requestStr)
	Set namespace=json.%Get("namespace")
	Set queryStr="call Config.Namespaces_List('"_namespace_"')"
	Set statement = ##class(%SQL.Statement).%New()
	Set qStatus = statement.%Prepare(queryStr)
	if qStatus'=1 {DO $System.Status.DisplayError(qStatus)}
	#dim rset As %SQL.StatementResult = statement.%Execute()
    Set namespaceObj = ##class(%DynamicObject).%New()
	if rset.%Next(){		
		Set namespaceObj=namespaceObj.%Set("id",rset.%Get("Namespace"))
		Set namespaceObj=namespaceObj.%Set("name",rset.%Get("Namespace"))
		Set namespaceObj=namespaceObj.%Set("description","Globals Database is "_rset.%Get("Globals")_",Routines Database is "_rset.%Get("Routines"))
		Set namespaceObj=namespaceObj.%Set("color","#27ae60")
		Set namespaceObj=namespaceObj.%Set("status","active")
	}else{
		Set pOutput=..Failure("The namespace does not exist")
		Quit $$$OK
	}
	
	//
	set arrayIndex=##class(%DynamicArray).%New()
    set arrayGlobals=##class(%DynamicArray).%New()
    set arrayDatabases=##class(%DynamicArray).%New()
    set arrayMappings=##class(%DynamicArray).%New()
    Set metadataObj = ##class(%DynamicObject).%New()
    
    Set globalsObjUtil = ##class(%DynamicObject).%New()
    Set databasesObjUtil = ##class(%DynamicObject).%New()
    Set indexObjUtil = ##class(%DynamicObject).%New()
    Set mappingObjUtil = ##class(%DynamicObject).%New()
    
	Set queryStr="call Config.MapGlobals_List('"_namespace_"')"
	Set statement = ##class(%SQL.Statement).%New()
	Set qStatus = statement.%Prepare(queryStr)
	if qStatus'=1 {DO $System.Status.DisplayError(qStatus)}
	#dim rset1 As %SQL.StatementResult = statement.%Execute()
	while rset1.%Next(){	
		 
		if ""'=rset1.%Get("Subscript"){
			if ('indexObjUtil.%IsDefined(rset1.%Get("Subscript"))){
				Set indexObj = ##class(%DynamicObject).%New()
				Set indexObj=indexObj.%Set("id",rset1.%Get("Subscript"))
				Set indexObj=indexObj.%Set("name",rset1.%Get("Subscript"))
				Set indexObj=indexObj.%Set("mappingCount",1)
				Set indexObj=indexObj.%Set("description","")
				Set indexObj=indexObj.%Set("namespace",namespace)
				do arrayIndex.%Push(indexObj)
				Set indexObjUtil=indexObjUtil.%Set(rset1.%Get("Subscript"),"1")
			}else{
				Set iter = arrayIndex.%GetIterator()
    			While iter.%GetNext(.key , .value ) {
	    			if value.%Get("name")=rset1.%Get("Subscript"){
		    			set mappingCount=value.%Get("mappingCount")+1
		    			Set indexObj = ##class(%DynamicObject).%New()
						Set indexObj=indexObj.%Set("id",rset1.%Get("Subscript"))
						Set indexObj=indexObj.%Set("name",rset1.%Get("Subscript"))
						Set indexObj=indexObj.%Set("mappingCount",mappingCount)
						Set indexObj=indexObj.%Set("description","")
						Set indexObj=indexObj.%Set("namespace",namespace)
						do arrayIndex.%Set(key,indexObj)
	    			}
    			}
			}
		}
		
		
		if ('globalsObjUtil.%IsDefined(rset1.%Get("Global"))){
			Set globalsObj = ##class(%DynamicObject).%New()
			Set globalsObj=globalsObj.%Set("id",rset1.%Get("Global"))
			Set globalsObj=globalsObj.%Set("name",rset1.%Get("Global"))
			Set globalsObj=globalsObj.%Set("mappingCount",1)
			Set globalsObj=globalsObj.%Set("description","")
			Set globalsObj=globalsObj.%Set("namespace",namespace)
			do arrayGlobals.%Push(globalsObj)
			Set globalsObjUtil=globalsObjUtil.%Set(rset1.%Get("Global"),"1")
		}else{
			Set iter = arrayGlobals.%GetIterator()
    		While iter.%GetNext(.key , .value ) {
	    		if value.%Get("name")=rset1.%Get("Global"){
		    		set mappingCount=value.%Get("mappingCount")+1
		    		Set globalsObj = ##class(%DynamicObject).%New()
					Set globalsObj=globalsObj.%Set("id",rset1.%Get("Global"))
					Set globalsObj=globalsObj.%Set("name",rset1.%Get("Global"))
					Set globalsObj=globalsObj.%Set("mappingCount",mappingCount)
					Set globalsObj=globalsObj.%Set("description","")
					Set globalsObj=globalsObj.%Set("namespace",namespace)
					do arrayGlobals.%Set(key,globalsObj)
	    		}
    		}
		}
		
		if ('databasesObjUtil.%IsDefined(rset1.%Get("Database"))){
			Set databasesObj = ##class(%DynamicObject).%New()
			Set databasesObj=databasesObj.%Set("id",rset1.%Get("Database"))
			Set databasesObj=databasesObj.%Set("name",rset1.%Get("Database"))
			Set databasesObj=databasesObj.%Set("mappingCount",1)
			Set databasesObj=databasesObj.%Set("description","")
			Set databasesObj=databasesObj.%Set("namespace",namespace)
			do arrayDatabases.%Push(databasesObj)
			Set databasesObjUtil=databasesObjUtil.%Set(rset1.%Get("Database"),"1")
		}else{
			Set iter = arrayDatabases.%GetIterator()
    		While iter.%GetNext(.key , .value ) {
	    		if value.%Get("name")=rset1.%Get("Database"){
		    		set mappingCount=value.%Get("mappingCount")+1
		    		Set databasesObj = ##class(%DynamicObject).%New()
					Set databasesObj=databasesObj.%Set("id",rset1.%Get("Database"))
					Set databasesObj=databasesObj.%Set("name",rset1.%Get("Database"))
					Set databasesObj=databasesObj.%Set("mappingCount",mappingCount)
					Set databasesObj=databasesObj.%Set("description","")
					Set databasesObj=databasesObj.%Set("namespace",namespace)
					do arrayDatabases.%Set(key,databasesObj)
	    		}
    		}
		}
		
		
		
		if ""=rset1.%Get("Subscript"){
			Set mappingsObj = ##class(%DynamicObject).%New()
			Set mappingsObj=mappingsObj.%Set("source",rset1.%Get("Global"))
			Set mappingsObj=mappingsObj.%Set("target",rset1.%Get("Database"))
			Set mappingsObj=mappingsObj.%Set("description","")
			Set mappingsObj=mappingsObj.%Set("value",1)
			Set mappingsObj=mappingsObj.%Set("namespace",namespace)
			do arrayMappings.%Push(mappingsObj)	
		}else{
			
			
			
			
			Set mappingsObj = ##class(%DynamicObject).%New()
			Set mappingsObj=mappingsObj.%Set("source",rset1.%Get("Global"))
			Set mappingsObj=mappingsObj.%Set("target",rset1.%Get("Subscript"))
			Set mappingsObj=mappingsObj.%Set("description","")
			Set mappingsObj=mappingsObj.%Set("value",1)
			Set mappingsObj=mappingsObj.%Set("namespace",namespace)
			do arrayMappings.%Push(mappingsObj)	
			
			set mappingStr=rset1.%Get("Subscript")_"2"_rset1.%Get("Database")
			if ('mappingObjUtil.%IsDefined(mappingStr)){
				Set mappingsObj1 = ##class(%DynamicObject).%New()
				Set mappingsObj1=mappingsObj1.%Set("source",rset1.%Get("Subscript"))
				Set mappingsObj1=mappingsObj1.%Set("target",rset1.%Get("Database"))
				Set mappingsObj1=mappingsObj1.%Set("description","")
				Set mappingsObj1=mappingsObj1.%Set("value",1)
				Set mappingsObj1=mappingsObj1.%Set("namespace",namespace)
				Set mappingObjUtil=mappingObjUtil.%Set(mappingStr,"1")
				do arrayMappings.%Push(mappingsObj1)
			}else{
				Set iter = arrayMappings.%GetIterator()
    			While iter.%GetNext(.key , .value ) {
	    			if (value.%Get("source")=rset1.%Get("Subscript"))&&(value.%Get("target")=rset1.%Get("Database")){
		    			set mappingValue=value.%Get("value")+1		    			
		    			Set mappingsObj1 = ##class(%DynamicObject).%New()
						Set mappingsObj1=mappingsObj1.%Set("source",rset1.%Get("Subscript"))
						Set mappingsObj1=mappingsObj1.%Set("target",rset1.%Get("Database"))
						Set mappingsObj1=mappingsObj1.%Set("description","")
						Set mappingsObj1=mappingsObj1.%Set("value",mappingValue)
						Set mappingsObj1=mappingsObj1.%Set("namespace",namespace)
						do arrayMappings.%Set(key,mappingsObj1)
	    		}
    		}
				
			}
			
			
			
		}

	}
	
	Set metadataObj=metadataObj.%Set("totalPackages",arrayGlobals.%Size())
	Set metadataObj=metadataObj.%Set("totalDatabases",arrayDatabases.%Size())
	Set metadataObj=metadataObj.%Set("totalMappings",arrayMappings.%Size())
	
	Set returnObj=returnObj.%Set("namespace",namespaceObj)
	Set returnObj=returnObj.%Set("index",arrayIndex)
	Set returnObj=returnObj.%Set("packages",arrayGlobals)
	Set returnObj=returnObj.%Set("databases",arrayDatabases)
	Set returnObj=returnObj.%Set("mappings",arrayMappings)
	Set returnObj=returnObj.%Set("metadata",metadataObj)
	
   
	Set pOutput=..Success(returnObj)
    Quit $$$OK
}

ClassMethod Namespace2Routines(Output pOutput As %String) As %Status
{
	Set requestStr=%request.Content.Read()
	Set returnObj = ##class(%DynamicObject).%New()
	#Dim json As %DynamicObject =##class(%DynamicObject).%FromJSON(requestStr)
	Set namespace=json.%Get("namespace")
	Set queryStr="call Config.Namespaces_List('"_namespace_"')"
	Set statement = ##class(%SQL.Statement).%New()
	Set qStatus = statement.%Prepare(queryStr)
	if qStatus'=1 {DO $System.Status.DisplayError(qStatus)}
	#dim rset As %SQL.StatementResult = statement.%Execute()
    Set namespaceObj = ##class(%DynamicObject).%New()
	if rset.%Next(){		
		Set namespaceObj=namespaceObj.%Set("id",rset.%Get("Namespace"))
		Set namespaceObj=namespaceObj.%Set("name",rset.%Get("Namespace"))
		Set namespaceObj=namespaceObj.%Set("description","Globals Database is "_rset.%Get("Globals")_",Routines Database is "_rset.%Get("Routines"))
		Set namespaceObj=namespaceObj.%Set("color","#27ae60")
		Set namespaceObj=namespaceObj.%Set("status","active")
	}else{
		Set pOutput=..Failure("The namespace does not exist")
		Quit $$$OK
	}
	
	//
	set arrayIndex=##class(%DynamicArray).%New()
    set arrayRoutines=##class(%DynamicArray).%New()
    set arrayDatabases=##class(%DynamicArray).%New()
    set arrayMappings=##class(%DynamicArray).%New()
    Set metadataObj = ##class(%DynamicObject).%New()
    
    Set routinesObjUtil = ##class(%DynamicObject).%New()
    Set databasesObjUtil = ##class(%DynamicObject).%New()
    
	Set queryStr="call Config.MapRoutines_List('"_namespace_"')"
	Set statement = ##class(%SQL.Statement).%New()
	Set qStatus = statement.%Prepare(queryStr)
	if qStatus'=1 {DO $System.Status.DisplayError(qStatus)}
	#dim rset1 As %SQL.StatementResult = statement.%Execute()
	while rset1.%Next(){		 

		
		if ('routinesObjUtil.%IsDefined(rset1.%Get("Routine"))){
			Set routineObj = ##class(%DynamicObject).%New()
			Set routineObj=routineObj.%Set("id",rset1.%Get("Routine"))
			Set routineObj=routineObj.%Set("name",rset1.%Get("Routine"))
			Set routineObj=routineObj.%Set("mappingCount",1)
			Set routineObj=routineObj.%Set("description","")
			Set routineObj=routineObj.%Set("namespace",namespace)
			do arrayRoutines.%Push(routineObj)
			Set routinesObjUtil=routinesObjUtil.%Set(rset1.%Get("Routine"),"1")
		}else{
			Set iter = arrayRoutines.%GetIterator()
    		While iter.%GetNext(.key , .value ) {
	    		if value.%Get("name")=rset1.%Get("Routine"){
		    		set mappingCount=value.%Get("mappingCount")+1
		    		Set routineObj = ##class(%DynamicObject).%New()
					Set routineObj=routineObj.%Set("id",rset1.%Get("Routine"))
					Set routineObj=routineObj.%Set("name",rset1.%Get("Routine"))
					Set routineObj=routineObj.%Set("mappingCount",mappingCount)
					Set routineObj=routineObj.%Set("description","")
					Set routineObj=routineObj.%Set("namespace",namespace)
					do arrayRoutines.%Set(key,routineObj)
	    		}
    		}
		}
		
		if ('databasesObjUtil.%IsDefined(rset1.%Get("Database"))){
			Set databasesObj = ##class(%DynamicObject).%New()
			Set databasesObj=databasesObj.%Set("id",rset1.%Get("Database"))
			Set databasesObj=databasesObj.%Set("name",rset1.%Get("Database"))
			Set databasesObj=databasesObj.%Set("mappingCount",1)
			Set databasesObj=databasesObj.%Set("description","")
			Set databasesObj=databasesObj.%Set("namespace",namespace)
			do arrayDatabases.%Push(databasesObj)
			Set databasesObjUtil=databasesObjUtil.%Set(rset1.%Get("Database"),"1")
		}else{
			Set iter = arrayDatabases.%GetIterator()
    		While iter.%GetNext(.key , .value ) {
	    		if value.%Get("name")=rset1.%Get("Database"){
		    		set mappingCount=value.%Get("mappingCount")+1
		    		Set databasesObj = ##class(%DynamicObject).%New()
					Set databasesObj=databasesObj.%Set("id",rset1.%Get("Database"))
					Set databasesObj=databasesObj.%Set("name",rset1.%Get("Database"))
					Set databasesObj=databasesObj.%Set("mappingCount",mappingCount)
					Set databasesObj=databasesObj.%Set("description","")
					Set databasesObj=databasesObj.%Set("namespace",namespace)
					do arrayDatabases.%Set(key,databasesObj)
	    		}
    		}
		}
		
		Set mappingsObj = ##class(%DynamicObject).%New()
		Set mappingsObj=mappingsObj.%Set("source",rset1.%Get("Routine"))
		Set mappingsObj=mappingsObj.%Set("target",rset1.%Get("Database"))
		Set mappingsObj=mappingsObj.%Set("description","")
		Set mappingsObj=mappingsObj.%Set("value",1)
		Set mappingsObj=mappingsObj.%Set("namespace",namespace)
		do arrayMappings.%Push(mappingsObj)	
	}
	
	Set metadataObj=metadataObj.%Set("totalPackages",arrayRoutines.%Size())
	Set metadataObj=metadataObj.%Set("totalDatabases",arrayDatabases.%Size())
	Set metadataObj=metadataObj.%Set("totalMappings",arrayMappings.%Size())
	
	Set returnObj=returnObj.%Set("namespace",namespaceObj)
	Set returnObj=returnObj.%Set("index",arrayIndex)
	Set returnObj=returnObj.%Set("packages",arrayRoutines)
	Set returnObj=returnObj.%Set("databases",arrayDatabases)
	Set returnObj=returnObj.%Set("mappings",arrayMappings)
	Set returnObj=returnObj.%Set("metadata",metadataObj)
	
   
	Set pOutput=..Success(returnObj)
    Quit $$$OK
}

ClassMethod Namespace2Packages(Output pOutput As %String) As %Status
{
	Set requestStr=%request.Content.Read()
	Set returnObj = ##class(%DynamicObject).%New()
	#Dim json As %DynamicObject =##class(%DynamicObject).%FromJSON(requestStr)
	Set namespace=json.%Get("namespace")
	Set queryStr="call Config.Namespaces_List('"_namespace_"')"
	Set statement = ##class(%SQL.Statement).%New()
	Set qStatus = statement.%Prepare(queryStr)
	if qStatus'=1 {DO $System.Status.DisplayError(qStatus)}
	#dim rset As %SQL.StatementResult = statement.%Execute()
    Set namespaceObj = ##class(%DynamicObject).%New()
	if rset.%Next(){		
		Set namespaceObj=namespaceObj.%Set("id",rset.%Get("Namespace"))
		Set namespaceObj=namespaceObj.%Set("name",rset.%Get("Namespace"))
		Set namespaceObj=namespaceObj.%Set("description","Globals Database is "_rset.%Get("Globals")_",Routines Database is "_rset.%Get("Routines"))
		Set namespaceObj=namespaceObj.%Set("color","#27ae60")
		Set namespaceObj=namespaceObj.%Set("status","active")
	}else{
		Set pOutput=..Failure("The namespace does not exist")
		Quit $$$OK
	}
	
	//
	set arrayIndex=##class(%DynamicArray).%New()
    set arrayPackages=##class(%DynamicArray).%New()
    set arrayDatabases=##class(%DynamicArray).%New()
    set arrayMappings=##class(%DynamicArray).%New()
    Set metadataObj = ##class(%DynamicObject).%New()
    
    Set packagesObjUtil = ##class(%DynamicObject).%New()
    Set databasesObjUtil = ##class(%DynamicObject).%New()
    
	Set queryStr="call Config.MapPackages_List('"_namespace_"')"
	Set statement = ##class(%SQL.Statement).%New()
	Set qStatus = statement.%Prepare(queryStr)
	if qStatus'=1 {DO $System.Status.DisplayError(qStatus)}
	#dim rset1 As %SQL.StatementResult = statement.%Execute()
	while rset1.%Next(){		 

		
		if ('packagesObjUtil.%IsDefined(rset1.%Get("Package"))){
			Set packagesObj = ##class(%DynamicObject).%New()
			Set packagesObj=packagesObj.%Set("id",rset1.%Get("Package"))
			Set packagesObj=packagesObj.%Set("name",rset1.%Get("Package"))
			Set packagesObj=packagesObj.%Set("mappingCount",1)
			Set packagesObj=packagesObj.%Set("description","")
			Set packagesObj=packagesObj.%Set("namespace",namespace)
			do arrayPackages.%Push(packagesObj)
			Set packagesObjUtil=packagesObjUtil.%Set(rset1.%Get("Package"),"1")
		}else{
			Set iter = arrayPackages.%GetIterator()
    		While iter.%GetNext(.key , .value ) {
	    		if value.%Get("name")=rset1.%Get("Global"){
		    		set mappingCount=value.%Get("mappingCount")+1
		    		Set packagesObj = ##class(%DynamicObject).%New()
					Set packagesObj=packagesObj.%Set("id",rset1.%Get("Global"))
					Set packagesObj=packagesObj.%Set("name",rset1.%Get("Global"))
					Set packagesObj=packagesObj.%Set("mappingCount",mappingCount)
					Set packagesObj=packagesObj.%Set("description","")
					Set packagesObj=packagesObj.%Set("namespace",namespace)
					do arrayPackages.%Set(key,packagesObj)
	    		}
    		}
		}
		
		if ('databasesObjUtil.%IsDefined(rset1.%Get("Database"))){
			Set databasesObj = ##class(%DynamicObject).%New()
			Set databasesObj=databasesObj.%Set("id",rset1.%Get("Database")_"(db)")
			Set databasesObj=databasesObj.%Set("name",rset1.%Get("Database")_"(db)")
			Set databasesObj=databasesObj.%Set("mappingCount",1)
			Set databasesObj=databasesObj.%Set("description","")
			Set databasesObj=databasesObj.%Set("namespace",namespace)
			do arrayDatabases.%Push(databasesObj)
			Set databasesObjUtil=databasesObjUtil.%Set(rset1.%Get("Database"),"1")
		}else{
			Set iter = arrayDatabases.%GetIterator()
    		While iter.%GetNext(.key , .value ) {
	    		if value.%Get("name")=rset1.%Get("Database"){
		    		set mappingCount=value.%Get("mappingCount")+1
		    		Set databasesObj = ##class(%DynamicObject).%New()
					Set databasesObj=databasesObj.%Set("id",rset1.%Get("Database")_"(db)")
					Set databasesObj=databasesObj.%Set("name",rset1.%Get("Database")_"(db)")
					Set databasesObj=databasesObj.%Set("mappingCount",mappingCount)
					Set databasesObj=databasesObj.%Set("description","")
					Set databasesObj=databasesObj.%Set("namespace",namespace)
					do arrayDatabases.%Set(key,databasesObj)
	    		}
    		}
		}
		
		Set mappingsObj = ##class(%DynamicObject).%New()
		Set mappingsObj=mappingsObj.%Set("source",rset1.%Get("Package"))
		Set mappingsObj=mappingsObj.%Set("target",rset1.%Get("Database")_"(db)")
		Set mappingsObj=mappingsObj.%Set("value",1)
		Set mappingsObj=mappingsObj.%Set("description","")
		Set mappingsObj=mappingsObj.%Set("namespace",namespace)
		do arrayMappings.%Push(mappingsObj)	
	}
	
	Set metadataObj=metadataObj.%Set("totalPackages",arrayPackages.%Size())
	Set metadataObj=metadataObj.%Set("totalDatabases",arrayDatabases.%Size())
	Set metadataObj=metadataObj.%Set("totalMappings",arrayMappings.%Size())
	
	Set returnObj=returnObj.%Set("namespace",namespaceObj)
	Set returnObj=returnObj.%Set("index",arrayIndex)
	Set returnObj=returnObj.%Set("packages",arrayPackages)
	Set returnObj=returnObj.%Set("databases",arrayDatabases)
	Set returnObj=returnObj.%Set("mappings",arrayMappings)
	Set returnObj=returnObj.%Set("metadata",metadataObj)
	
   
	Set pOutput=..Success(returnObj)
    Quit $$$OK
}

ClassMethod MirrorDiagrams(Output pOutput As %String) As %Status
{
	If ($System.Mirror.IsMember() = 0) {
	    set pOutput=..Failure("This instance is not a mirror member")
	    Quit $$$OK
    }
    Set returnObj = ##class(%DynamicObject).%New()
    Set vipObj=##class(%DynamicObject).%New()
    Set masterObj = ##class(%DynamicObject).%New()
    Set failoverObj = ##class(%DynamicObject).%New()
    Set failoverArr = ##class(%DynamicArray).%New()
    Set arbiterObj = ##class(%DynamicObject).%New()
    set arrayAsync=##class(%DynamicArray).%New()
    
    //
    Set MirrorName=""
    Set queryStr="select name from Config.Mirrors where ID like'%IRIS||MapMirrors||%'"
	Set statement = ##class(%SQL.Statement).%New()
	Set qStatus = statement.%Prepare(queryStr)
	if qStatus'=1 {DO $System.Status.DisplayError(qStatus)}
	#dim rset As %SQL.StatementResult = statement.%Execute()
    set array=##class(%DynamicArray).%New()
	while rset.%Next(){
		Set MirrorName=rset.%Get("Name")
	}
    
    
    //get VirtualAddress、ArbiterNode 
    Set ArbiterNode=""
	Set queryStr="select ArbiterNode,VirtualAddress from Config.Mirrors where name ='"_MirrorName_"'AND SectionHeader='Mirrors'"
   	Set statement = ##class(%SQL.Statement).%New()
	Set qStatus = statement.%Prepare(.queryStr)
	if qStatus'=1 {DO $System.Status.DisplayError(qStatus)}
	#dim rset0 As %SQL.StatementResult = statement.%Execute()
	if (rset0.%Next()){
		Set arbiterObj=arbiterObj.%Set("ip",$P(rset0.%Get("ArbiterNode"),"|"))
		Set vipObj=vipObj.%Set("ip",$P(rset0.%Get("VirtualAddress"),"/"))
	}else{
		Set arbiterObj=arbiterObj.%Set("ip","")
		Set vipObj=vipObj.%Set("ip","")
	}
	Set vipObj=vipObj.%Set("mounted_on_master",1,"boolean")
    
	//
	set ipUtilObj=##class(%DynamicObject).%New()
	Set queryStr="select MirrorAddress,Name from Config.MapMirrors where ID ='"_MirrorName_"'"
   	Set statement = ##class(%SQL.Statement).%New()
	Set qStatus = statement.%Prepare(.queryStr)
	if qStatus'=1 {DO $System.Status.DisplayError(qStatus)}
	#dim rset1 As %SQL.StatementResult = statement.%Execute()
	while rset1.%Next(){
		Set ipUtilObj=ipUtilObj.%Set(rset1.%Get("Name"),rset1.%Get("MirrorAddress"))
		
	}
	
	
	
	//
	Set queryStr="call SYS.Mirror_MemberStatusList()"
	Set statement = ##class(%SQL.Statement).%New()
	Set qStatus = statement.%Prepare(queryStr)
	if qStatus'=1 {DO $System.Status.DisplayError(qStatus)}
	#dim rset2 As %SQL.StatementResult = statement.%Execute()
	while rset2.%Next(){
		set CurrentRole = rset2.%Get("CurrentRole")
		set displayStatus=rset2.%Get("DisplayStatus")
		set status=$SELECT("Primary"=displayStatus:"normal","Backup"=displayStatus:"normal","Connected"=displayStatus:"normal","Down"=displayStatus:"error",1:"error")
		if "Primary"=CurrentRole{
			Set masterObj=masterObj.%Set("name",rset2.%Get("MemberName"))
			Set masterObj=masterObj.%Set("status",status)
			Set masterObj=masterObj.%Set("ip",ipUtilObj.%Get(rset2.%Get("MemberName")))
		}elseif "Backup"=CurrentRole{
			Set failoverObj=failoverObj.%Set("name",rset2.%Get("MemberName"))
			Set failoverObj=failoverObj.%Set("sync_status",status)
			Set failoverObj=failoverObj.%Set("ip",ipUtilObj.%Get(rset2.%Get("MemberName")))
		}elseif "Async"=CurrentRole{
			Set asyncObj = ##class(%DynamicObject).%New()
			Set asyncObj=asyncObj.%Set("name",rset2.%Get("MemberName"))
			Set asyncObj=asyncObj.%Set("sync_status",status)
			Set asyncObj=asyncObj.%Set("ip",ipUtilObj.%Get(rset2.%Get("MemberName")))
			do arrayAsync.%Push(asyncObj)
		}elseif "Unknown"=CurrentRole{
			Set asyncObj = ##class(%DynamicObject).%New()
			Set asyncObj=asyncObj.%Set("name",rset2.%Get("MemberName"))
			Set asyncObj=asyncObj.%Set("sync_status",status)
			Set asyncObj=asyncObj.%Set("ip",ipUtilObj.%Get(rset2.%Get("MemberName")))
			do arrayAsync.%Push(asyncObj)
		}
	}	
	Set state = $SYSTEM.Mirror.ArbiterState()
	Set thisConnected = $SELECT($ZB(+state,+2,1)'=0:1,1:0)
	Set otherConnected = $SELECT($ZB(+state,+4,1)'=0:1,1:0)
	Set connectionsObj = ##class(%DynamicObject).%New()
	Set connectionsObj=connectionsObj.%Set("master",thisConnected,"boolean")
	Set connectionsObj=connectionsObj.%Set("failover1",otherConnected,"boolean")
	Set arbiterObj=arbiterObj.%Set("connections",connectionsObj)
	do failoverArr.%Push(failoverObj)
	
	
    Set returnObj=returnObj.%Set("vip",vipObj)
	Set returnObj=returnObj.%Set("master",masterObj)
	Set returnObj=returnObj.%Set("failover_servers",failoverArr)
	Set returnObj=returnObj.%Set("async_servers",arrayAsync)
	Set returnObj=returnObj.%Set("arbiter",arbiterObj)
	
	Set pOutput=..Success(returnObj)
	
	
    Quit $$$OK
}

ClassMethod Success(pRequest As %RegisteredObject) As %String
{
	Set response = ##class(%DynamicObject).%New()
	Set response.code=200
	Set response.data=pRequest
	Set response.msg=""
	Set response=response.%Set("success",1,"boolean")
	Quit response.%ToJSON()
}

ClassMethod Failure(pRequest As %RegisteredObject) As %String
{
	Set response = ##class(%DynamicObject).%New()
	Set response.code=400
	Set response.data=pRequest
	Set response.msg=""
	Set response=response.%Set("success",0,"boolean")
	Quit response.%ToJSON()
}

}

