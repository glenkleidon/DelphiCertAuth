@echo off
SET commonName=%1
if NOT DEFINED commonName (
  echo Certificate Name not specified eg "computer1.domain.local"
  GOTO FAIL
)
SET outputFolder=%2
if NOT DEFINED outputFolder (
  echo Output folder NOT SPECIFIED 
  GOTO FAIL
)
if "%outputFolder%" == "" SET outputFolder="./"
IF NOT EXIST %outputFolder% mkdir "%outputFolder%"

SET Outfile=%outputFolder%/%commonName%.certdetails.txt

:GETDETAILS
echo.
%BIGTEXT%create.txt
%BIGTEXT%CertRequest.txt
echo Enter certifcate Details for %commonName%
echo ========================================================
::Email Address
SET emailAddress=devcert@%commonName%
SET /p emailAddress="Email Address [%emailAddress%]:"
if /I "%emailAddress%" == "Q" GOTO QUIT
if "%emailAddress%" == "" SET emailAddress=devcert@%commonName%

::Organisation
SET organizationName=IT Department
SET /p organizationName="Organisation [%organizationName%]:"
if /I "%organizationName%" == "Q" GOTO QUIT
if "%organizationName%" == "" SET organizationName=IT Department

::Organisation Unit
SET organizationalUnitName=Software Development
SET /p organizationalUnitName="Organisation Unit [%organizationalUnitName%]:"
if /I "%organizationalUnitName%" == "Q" GOTO QUIT
if "%organizationalUnitName%" == "" SET organizationalUnitName=Software Development

::Country Code
SET countryName=AU
SET /p countryName="Country Code (2 digit) [%countryName%]:"
if /I "%commonName%" == "Q" GOTO QUIT
if "%commonName%" == "" SET countryName=AU

::STATE
SET stateOrProvinceName=VIC
SET /p stateOrProvinceName="State/Province [%stateOrProvinceName%]:"
if /I "%stateOrProvinceName%"=="Q" GOTO QUIT
if "%stateOrProvinceName%"=="" SET stateOrProvinceName=VIC

::Output the file
echo [ req ]> %Outfile%
echo prompt                  = no>> %Outfile%
echo distinguished_name      = server_distinguished_name>> %Outfile%
echo req_extensions          = v3_req>> %Outfile%
echo.>>%Outfile%
echo [ server_distinguished_name ]>> %Outfile%
echo commonName              = %commonName%>> %Outfile%
echo stateOrProvinceName     = %stateOrProvinceName%>> %Outfile%
echo countryName             = %countryName%>> %Outfile%
echo emailAddress            = %emailAddress%>> %Outfile%
echo organizationName        = %organizationName%>> %Outfile%
echo organizationalUnitName  = %organizationalUnitName%>> %Outfile%
echo.>>%Outfile%
echo [ v3_req ]>> %Outfile%
echo basicConstraints        = CA:FALSE>> %Outfile%
echo keyUsage                = digitalSignature, keyEncipherment, dataEncipherment>> %Outfile%
echo subjectAltName          = @alternate_names>> %Outfile%
echo [ alternate_names]>> %Outfile%
echo DNS.1     = %commonName%>> %Outfile%
echo DNS.2     = localhost>> %Outfile% 

:SUCCESS
exit /b 0
:QUIT
exit /b 1
:FAIL
exit /b 100
