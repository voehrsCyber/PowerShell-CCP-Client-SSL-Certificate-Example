echo "init call (WSDL and Certificate already prepared)"
$certificate = Get-ChildItem Cert:\LocalMachine\My\C1D488C836A3E84324129E818A93DC556AFACD02
$temp_wsdl = "C:\temp\aimwebservice.xml"
$fileTempWsdl = "file://C:/temp/aimwebservice.xml"
$WebRequest = @{
               "Certificate" = $certificate
               "URI" = "https://components.cyberarkdemo.com/aimwebservice/v1.1/aim.asmx?WSDL"
}
echo "load wsdl"
$Response = Invoke-WebRequest @WebRequest
$file = [System.IO.Path]::GetTempFileName()|Rename-Item -NewName { $_ -replace 'tmp$', 'xml' } –PassThru
Add-Content  $file $Response.Content
get-content $file |    select -Skip 1 |    set-content $temp_wsdl
$proxy = New-WebServiceProxy -Uri $fileTempWsdl
$t = $proxy.getType().namespace
echo "Request Password"
$request = New-Object ($t + ".passwordRequest")
$request.AppID = "WebServiceTest";
$request.Query = "Safe=FTP Script Accounts;Folder=Root;Object=FTPScript_Password";
$proxy.ClientCertificates.Add($certificate)
$response = $proxy.GetPassword($request)
$response.content
remove-item $file
