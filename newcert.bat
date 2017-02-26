::https://dev.to/ruidfigueiredo/using-openssl-to-create-certificates
::@echo off
SET ssldir=%CD%\
SET authorityPath=.\
SET authPath=%authorityPath:\=/%
SET auConfig=%authPath%caconf.cnf
SET commonName=%1
if NOT DEFINED commonName (
  echo Certificate Name not specified eg "newcert computer1.domain.local"
  EXIT /b
)
SET clientPath=%2
if NOT DEFINED clientPath SET clientPath=%authorityPath%certificates\%commonName%
SET clientDetails=%clientPath%\%commonName%.CertDetails.txt
SET OPTIONS=%3
IF NOT DEFINED OPTIONS SET OPTIONS=NONE
SET OPTIONS=%OPTIONS:/=%
SET authClientPath=%clientPath:\=/%

:CHECK
echo Checking for valid root certificate
echo ========================================
SET OPENSSL_CONF=%auConfig%
%ssldir%openssl x509 -in certificateAuthorityCertificate.pem -text > NUL
if %ERRORLEVEL% NEQ 0 (
echo Missing certificate or SSL
GOTO NEWAUTH
)

if not EXIST "%authpath%certificates" (
mkdir "%authpath%certificates"   
)

if not EXIST "serial" echo 01 > serial
if not EXIST "index.txt" echo >NUL 2>index.txt
if /I %OPTIONS%==sign GOTO SIGN
echo "%OPTIONS%"

::did that work??
echo Outputting a Private Key and a CSR - Requires Key password
echo -----------------------------------------------------------
SET OPENSSL_CONF=%clientDetails%
IF NOT EXIST %OPENSSL_CONF% CALL makeCertDetails %commonName% %clientPath%
IF %ERRORLEVEL% NEQ 0 EXIT /b
%ssldir%openssl req -out %authClientPath%/%commonName%Csr.pem -newkey rsa:2048 -keyout %authClientPath%/%commonName%PrivateKey.pem
echo %OPENSSL_CONF%

:SIGN
echo Outputting Certificate file
echo ---------------------------
SET OPENSSL_CONF=%auConfig%
:RETRYSIGN_x
%ssldir%openssl ca -in %authClientPath%/%commonName%Csr.pem -out %authClientPath%/%commonName%Certificate.pem
if %ERRORLEVEL% NEQ 0 (
echo failed. 
pause
GOTO RETRYSIGN
)

echo Outputting a PFX file - Requires a PFX password
echo -----------------------------------------------
%ssldir%openssl pkcs12 -export -in %authClientPath%/%commonName%Certificate.pem -inkey %authClientPath%/%commonName%PrivateKey.pem -out %authClientPath%/%commonName%.pfx
echo Outputing A copy of the ROOT cert
echo -----------------------------------------------
%ssldir%\openssl x509 -in %authPath%certificateAuthorityCertificate.pem -out %authClientPath%/root_cert.crt -outform DER
EXIT /b

:NEWAUTH
echo Generating New Signing certificate
del %authorityPath%certificateAuthorityCertificaterPath%certificateAuthorityCertificate.pem
del %authorityPath%certificateAuthorityPrivateKey.pem
del %authorityPath%certificates\*.*
SET OPENSSL_CONF=%auConfig%
%ssldir%openssl req -x509 -out certificateAuthorityCertificate.pem -newkey rsa:2048 -keyout certificateAuthorityPrivateKey.pem -days 365
GOTO CHECK
