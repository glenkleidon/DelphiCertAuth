# DelphiCertAuth
Batch Scripts to create a Self Signed Certificate Authority and Sign Certificates.
These scripts were created primarily for Software development purposes - in particular Delphi Indy web server certificates
but can be used for NodeJS or any purpose really.

## Commands
+ **newcert** \<common name\> [\<output path\>] [\<options\>] [\/sign]
    + Creates a new certificate. If not present, a new Authority certificate is generated. If certificate details are not supplied, the user is prompted
    **__common name__** Host Name on the certificate
    **__output path__** Alternate path to save the certificate folder.
    **__options__**  _openssl CA_ Signing options eg "-days 60" or "-subject ....."   
+ **makeCertDetails** \<common name\> \<output path\> 
    + Prompts the user for new certificate details only

## Set Up
The Authority Configuration file __caconf.cnf__ should be updated to reflect your company or personal details.

````
[ root_ca_distinguished_name ]
commonName              = root.mycomputer.development.local
stateOrProvinceName     = XXX
countryName             = XX
emailAddress            = root@mycomputer.development.local
organizationName        = Information Technology
organizationalUnitName  = Development
````
+ **commonName** 
    + this is the name of the certificate.  A good name might be "root." followed by your Active Directory Domain name.\
eg `root.galkam.com.au`.  If you dont have a domain then perhaps "root." followed by your name followed by ".local" eg `root.glenkleidon.local`
+ **stateOrProvinceName**
    + there are no strict rules on this field.  Use the abbreviation for your state of province that you commonly use.
+ **countryName**
    + Should be the ISO country code eg AU, NZ, US (note: official codes can be found at ISO [here]( https://www.iso.org/obp/ui/#search)
+ **emailAddress**
    + This does not really matter, but you could "root@" followed by your active directory or local name
+ **organizationName**
    + the name of your organisation or company.  If you dont have one, just use your name
+ **organizationalUnitName**
    + the department or group within your company that has need of a certificate.  Again if you dont have one,\
    then any name will do.
## Certificate Outputs
This script is generates a two layer certificate:
````
    Root Authority-->
        Local Certificate
````
There is no intermediate level.  This arrangement is generally sufficient for software development purposes.

The scripts generate 1 details file, 2 PEM files (private key and Certificate) and two support files.  
Delphi Indy components including Datasnap (and other development environments like NodeJS) require the Key file and certificate to be in 
separate PEM files.  

| Example File                           | Contains                               |
|:-------------------------------------- |:-------------------------------------- |
| test.global-health.com.certdetails.txt | Email, Company, State, Country details |
| test.global-health.comCsr.pem          | Certificate Request                    |
| test.global-health.comCertificate.pem  | Certifcate file                        | 
| test.global-health.comPrivateKey.pem   | Private key (keep secure!!)            | 
| test.global-health.com.pfx             | PFX file for windows certificate store |
| root_cert.crt                          | Public Root Certificate file (a "Trusted root certificate" file) |

The certificate authority's public root certificate is also required.  This
is also create as a PEM file.  For other environments, the PFX (p12) files are required.
These files include all three parts in a single file.  

## Example 
As you can appreciate, the security of a password is very important.  So be warned, there are a LOT
of passwords you need to enter and re-enter.  This is just the way it is  
so be prepared.  It is also quite important that you choose passwords for your development 
environment that can be safely passed around to other developers, so DONT be tempted to use 
a real user password or service user password when generating test certificates.

The __newcert__ command will automatically progress through all of the steps outlined below 
I have split up the output for ease of understanding.  (note: you can also create these details
ahead of time by running the __makeCertDetails__ command independently but you must include the output
path in the newcert to ensure that it locate the detail correctly)

### Creating the certificate Authority certificate 
When running the script for the first time, you will be prompted to create a Private Key 
for the Signing Authority (top layer) certificate.

````
E:\globalhealthcerts>newcert test.global-health.com
Checking for valid root certificate
========================================
Error opening Certificate certificateAuthorityCertificate.pem
4760:error:02001002:system library:fopen:No such file or directory:.\crypto\bio\bss_file.c:356:fopen('certificateAuthorityCertificate.pem','rb')
4760:error:20074002:BIO routines:FILE_CTRL:system lib:.\crypto\bio\bss_file.c:358:
unable to load certificate
Missing certificate or SSL
Generating New Signing certificate
Could Not Find E:\globalhealthcerts\certificateAuthorityCertificate.pem
Could Not Find E:\globalhealthcerts\certificateAuthorityPrivateKey.pem
The system cannot find the file specified.
Loading 'screen' into random state - done
Generating a 2048 bit RSA private key
........+++
......................+++
writing new private key to 'certificateAuthorityPrivateKey.pem'
Enter PEM pass phrase:
Verifying - Enter PEM pass phrase:
-----
````
The authority certificate has now been created so you will not be prompted to create it again.
You can now create as many client certificates as you like with this authority.

### Creating the Client Certificate Private Key and CRQ
After confirming that the Authority Certificate is valid, the certificate can now be created.
Firstly you will be prompted to enter the details for the certificate.  This is identical
to the steps followed for the Authority.  

**__For web server certificates, make sure you make the \<COMMON NAME\> the exact, fully qualified name for the 
computer where you intend to run the web server__**

For windows look at the PROPERTIES of the Computer.  For Linux look at the HOSTNAME environment variable

You need a Password for the Private Key, and you will need to confirm it.

````
Checking for valid root certificate
========================================
Outputting a Private Key and a CSR - Requires Key password
-----------------------------------------------------------
Enter certifcate Details for test.global-health.com
========================================================
Email Address [devcert@test.global-health.com]:
Organisation [IT Department]:
Organisation Unit [Software Development]:
Country Code (2 digit) [AU]:
State/Province [VIC]:
Loading 'screen' into random state - done
Generating a 2048 bit RSA private key
........................+++
.............................+++
writing new private key to './certificates/test.global-health.com/test.global-health.comPrivateKey.pem'
Enter PEM pass phrase:
Verifying - Enter PEM pass phrase:
-----
.\certificates\test.global-health.com\test.global-health.com.CertDetails.txt
````
Now we need the Authority to Sign the certificate request you just created.  So the program needs
to access the Authority Certificate file, and once again you need to enter the password for the
AUTHORITY private key in order to do that.

```` 
Outputting Certificate file
---------------------------
Using configuration from ./caconf.cnf
Loading 'screen' into random state - done
Enter pass phrase for .//certificateAuthorityPrivateKey.pem:
````
Now the client certificate will be checked and generated.  Accept the default Prompts
````
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :PRINTABLE:'test.global-health.com'
stateOrProvinceName   :PRINTABLE:'VIC'
countryName           :PRINTABLE:'AU'
emailAddress          :IA5STRING:'devcert@test.global-health.com'
organizationName      :PRINTABLE:'IT Department'
organizationalUnitName:PRINTABLE:'Software Development'
Certificate is to be certified until Feb 25 22:27:10 2022 GMT (1825 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated
````
Now a valid certificate file has been generated.  For Delphi and NodeJS development, that is all that
is needed.  However, it if often a good idea to import the certificates into the windows 
key store.  It is easiest to do this with a PFX file.

A PFX file will now be generated - this file is also password protected. 
First, because you need to access the client private key in order to create the PFX, you will
be prompted for the Private Key password, and then you will need create a password to use
with the PFX file.  You will need to enter and then verify the PFX file.
````
Outputting a PFX file - Requires a PFX password
-----------------------------------------------
Loading 'screen' into random state - done
Enter pass phrase for ./certificates/test.global-health.com/test.global-health.comPrivateKey.pem:
Enter Export Password:
Verifying - Enter Export Password:
Outputing A copy of the ROOT cert
-----------------------------------------------
````
Finally a copy of the ROOT certificate (Authority Public certificate) is generated.  This 
certificate can be installed into the "Trusted Root Certificate Authorities" certificate store 
to ensure that the client certificate is trusted by Windows.

````
Outputing A copy of the ROOT cert
-----------------------------------------------
````
### Creating more certificates.
Now that you have set up your Authority folder, you can now generate as many certificates as you
need by simply running the **newcert** commmand again with a different common name. 

You can also create as many authorities as you like, if for example you want a personal 
certificate and/or you have more than one corporate domain.


## Acknowledgements
This script uses extensively information written by Rui Figueiredo in 
[this article](https://dev.to/ruidfigueiredo/using-openssl-to-create-certificates)
