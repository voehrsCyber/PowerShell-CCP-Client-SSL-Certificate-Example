echo "init call (WSDL and Certificate already prepared)"
$CertName = Read-Host -Prompt 'Please enter CN of the client certficate'
Set-Location cert:
cd "\CurrentUser\My";
$CertThumbprint='';
Get-ChildItem -Recurse | foreach{If($_.Subject -eq $CertName){$CertThumbprint = $_.Thumbprint;$certificate = $_}}
if ($CertThumbprint -eq ''){
    throw "No Certificate found";
}
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
