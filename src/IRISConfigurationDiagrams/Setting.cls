Class IRISConfigurationDiagrams.Setting
{

Parameter HandleCorsRequest = "true";

ClassMethod initialization() As %Status
{

	set ns=$namespace
	Do $SYSTEM.OBJ.Export("IRISConfigurationDiagrams.Rest.cls",$SYSTEM.Util.InstallDirectory()_"IRISConfigurationDiagrams.xml")
	Do $system.OBJ.ImportDir("/opt/IRISConfigurationDiagrams/user/",,"cbrpsuy",,1)
	zn "%SYS"
	D $system.OBJ.Load($SYSTEM.Util.InstallDirectory()_"IRISConfigurationDiagrams.xml","cbrpsuy")
	Set sc("DispatchClass")="IRISConfigurationDiagrams.Rest",sc("AutheEnabled")=64,sc("IsNameSpaceDefault")=0,sc("MatchRoles")=":%All",sc("GroupById")="%ISCMgtPortal",sc("NameSpace")="%SYS",sc("DeepSeeEnabled")=1
	Set tSC=##Class(Security.Applications).Create("/api/IRISConfigurationDiagrams",.sc)
	zn ns
	
	
	
 Quit $$$OK
}

}

