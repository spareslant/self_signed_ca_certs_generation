* Generates
  * self-signed CA, CAkey
  * Server certificate signed by CA, Server key
  * client certificate signed by CA, client key
* how to run
  * To generate Server certificate (e.g for elasticsearch service)
    * modify alternate_names in `openSSLConf/server_san.cnf` file.
    * `./cert_generation.sh -o elasticCertsDir  -s elasticsearch -t server  -c elasticsearch.mycompany.linux -e myemail@mycompany.linux`
  * To generate client certificate
    * modify alternate_names in `openSSLConf/client_san.cnf` file.
    * `./cert_generation.sh -o myServiceCertsDir  -s myCustomService -t client  -c myservice.mycompany.linux -e myemail@mycompany.linux` 

* **NOTE**: Depending on the version of openssl it may create version-1 certs only. version-1 certs may not work with some latest applications. On fedora-32, this creates version-3 certs. For Macos you need to install openssl via brew or some other package-manager. Default installed openssl in Macos will not generate version-3 certs.

* openssl version used:
  * linux (fedora-32)
  ```
    $ openssl version -a
      OpenSSL 1.1.1d FIPS  10 Sep 2019
      built on: Mon Feb 17 00:00:00 2020 UTC
      platform: linux-x86_64
      options:  bn(64,64) md2(char) rc4(16x,int) des(int) idea(int) blowfish(ptr)
      compiler: gcc -fPIC -pthread -m64 -Wa,--noexecstack -Wall -O3 -O2 -g -pipe -Wall -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -Wp,-D_GLIBCXX_ASSERTIONS -fexceptions -fstack-protector-strong -grecord-gcc-switches -specs=/usr/lib/rpm/redhat/redhat-hardened-cc1 -specs=/usr/lib/rpm/redhat/redhat-annobin-cc1 -m64 -mtune=generic -fasynchronous-unwind-tables -fstack-clash-protection -fcf-protection -Wa,--noexecstack -Wa,--generate-missing-build-notes=yes -specs=/usr/lib/rpm/redhat/redhat-hardened-ld -DOPENSSL_USE_NODELETE -DL_ENDIAN -DOPENSSL_PIC -DOPENSSL_CPUID_OBJ -DOPENSSL_IA32_SSE2 -DOPENSSL_BN_ASM_MONT -DOPENSSL_BN_ASM_MONT5 -DOPENSSL_BN_ASM_GF2m -DSHA1_ASM -DSHA256_ASM -DSHA512_ASM -DKECCAK1600_ASM -DRC4_ASM -DMD5_ASM -DAESNI_ASM -DVPAES_ASM -DGHASH_ASM -DECP_NISTZ256_ASM -DX25519_ASM -DPOLY1305_ASM -DZLIB -DNDEBUG -DPURIFY -DDEVRANDOM="\"/dev/urandom\"" -DSYSTEM_CIPHERS_FILE="/etc/crypto-policies/back-ends/openssl.config"
      OPENSSLDIR: "/etc/pki/tls"
      ENGINESDIR: "/usr/lib64/engines-1.1"
      Seeding source: os-specific
      engines:  rdrand dynamic
  ```
  * Macos
  ```
  $ brew install openssl
  $ /usr/local/opt/openssl/bin/openssl version -a
    OpenSSL 1.1.1g  21 Apr 2020
    built on: Tue Apr 21 13:30:00 2020 UTC
    platform: darwin64-x86_64-cc
    options:  bn(64,64) rc4(16x,int) des(int) idea(int) blowfish(ptr)
    compiler: clang -fPIC -arch x86_64 -O3 -Wall -DL_ENDIAN -DOPENSSL_PIC -DOPENSSL_CPUID_OBJ -DOPENSSL_IA32_SSE2 -DOPENSSL_BN_ASM_MONT -DOPENSSL_BN_ASM_MONT5 -DOPENSSL_BN_ASM_GF2m -DSHA1_ASM -DSHA256_ASM -DSHA512_ASM -DKECCAK1600_ASM -DRC4_ASM -DMD5_ASM -DAESNI_ASM -DVPAES_ASM -DGHASH_ASM -DECP_NISTZ256_ASM -DX25519_ASM -DPOLY1305_ASM -D_REENTRANT -DNDEBUG
    OPENSSLDIR: "/usr/local/etc/openssl@1.1"
    ENGINESDIR: "/usr/local/Cellar/openssl@1.1/1.1.1g/lib/engines-1.1"
    Seeding source: os-specific
  ```

* Example RUNs
  * Creating Server certificate. 
  ```
  $ ./cert_generation.sh -o elasticCertsDir  -s elasticsearch -t server  -c elasticsearch.mycompany.linux -e myemail@mycompany.linux
  ------ Starting to create certs ------
  ------ Remove old dir setup /var/folders/rm/hn6kdd0n4_7dnd5ts9mcf5yh0000gn/T/tmp.vzmg4hbH if present
  ------ Creating self signed CA authority ------
  Generating a RSA private key
  ...........................................+++++
  ...............................................................+++++
  writing new private key to '/var/folders/rm/hn6kdd0n4_7dnd5ts9mcf5yh0000gn/T/tmp.vzmg4hbH/caCert/myCAKey.pem'
  -----
  ------ Creating CSR for elasticsearch ------
  Ignoring -days; not generating a certificate
  Generating a RSA private key
  ............................................+++++
  ........................................................+++++
  writing new private key to '/var/folders/rm/hn6kdd0n4_7dnd5ts9mcf5yh0000gn/T/tmp.vzmg4hbH/privateKeys/elasticsearch_key.pem'
  -----
  ------ Signing CSR for elasticsearch ------
  Using configuration from /var/folders/rm/hn6kdd0n4_7dnd5ts9mcf5yh0000gn/T/tmp.vzmg4hbH/opensslConf/CA_openssl.cnf
  Check that the request matches the signature
  Signature ok
  Certificate Details:
          Serial Number: 16 (0x10)
          Validity
              Not Before: Aug 21 21:17:06 2020 GMT
              Not After : Aug 21 21:17:06 2021 GMT
          Subject:
              countryName               = GB
              stateOrProvinceName       = London
              localityName              = London
              organizationName          = MyCompany
              organizationalUnitName    = Engg
              commonName                = elasticsearch.mycompany.linux
              emailAddress              = myemail@mycompany.linux
          X509v3 extensions:
              X509v3 Basic Constraints:
                  CA:FALSE
              Netscape Cert Type:
                  SSL Server
              X509v3 Key Usage:
                  Digital Signature, Non Repudiation, Key Encipherment
              Netscape Comment:
                  OpenSSL Generated Certificate
              X509v3 Subject Key Identifier:
                  DD:59:B4:D1:51:E6:EA:2D:A7:24:14:45:24:F5:48:57:0A:15:18:39
              X509v3 Extended Key Usage:
                  TLS Web Server Authentication, TLS Web Client Authentication
              X509v3 Subject Alternative Name:
                  DNS:*.serverdomain.com, IP Address:127.0.0.1, DNS:localhost
  Certificate is to be certified until Aug 21 21:17:06 2021 GMT (365 days)

  Write out database with 1 new entries
  Data Base Updated
  ------ certs created for elasticsearch ------
  ------ Certs created successfully and copied to elasticCertsDir directoty ------
  ```
  * Output files
  ```
  $ tree elasticCertsDir
    elasticCertsDir
    ├── 10.pem
    ├── elasticsearch_key.pem
    ├── elasticsearch_node_crt.pem
    └── myCA.pem
  ```
  * **NOTE**: Above server certificate has both `TLS Web Server Authentication` and  `TLS Web Client Authentication` extensions.

  * Creating client certificate
  ```
  $ ./cert_generation.sh -o myServiceCertsDir  -s myCustomService -t client  -c myservice.mycompany.linux -e myemail@mycompany.linux
  ------ Starting to create certs ------
  ------ Remove old dir setup /var/folders/rm/hn6kdd0n4_7dnd5ts9mcf5yh0000gn/T/tmp.cUgCHUpI if present
  ------ Creating self signed CA authority ------
  Generating a RSA private key
  ....................................................+++++
  .....+++++
  writing new private key to '/var/folders/rm/hn6kdd0n4_7dnd5ts9mcf5yh0000gn/T/tmp.cUgCHUpI/caCert/myCAKey.pem'
  -----
  ------ Creating CSR for myCustomService ------
  Ignoring -days; not generating a certificate
  Generating a RSA private key
  .............................................+++++
  ..............................................................+++++
  writing new private key to '/var/folders/rm/hn6kdd0n4_7dnd5ts9mcf5yh0000gn/T/tmp.cUgCHUpI/privateKeys/myCustomService_key.pem'
  -----
  ------ Signing CSR for myCustomService ------
  Using configuration from /var/folders/rm/hn6kdd0n4_7dnd5ts9mcf5yh0000gn/T/tmp.cUgCHUpI/opensslConf/CA_openssl.cnf
  Check that the request matches the signature
  Signature ok
  Certificate Details:
          Serial Number: 16 (0x10)
          Validity
              Not Before: Aug 21 21:23:35 2020 GMT
              Not After : Aug 21 21:23:35 2021 GMT
          Subject:
              countryName               = GB
              stateOrProvinceName       = London
              localityName              = London
              organizationName          = MyCompany
              organizationalUnitName    = Engg
              commonName                = myservice.mycompany.linux
              emailAddress              = myemail@mycompany.linux
          X509v3 extensions:
              X509v3 Basic Constraints:
                  CA:FALSE
              Netscape Cert Type:
                  SSL Client, S/MIME
              X509v3 Key Usage:
                  Digital Signature, Non Repudiation, Key Encipherment
              Netscape Comment:
                  OpenSSL Generated Certificate
              X509v3 Subject Key Identifier:
                  2A:73:8C:00:EB:5C:BC:7D:E8:A7:CB:92:43:5C:4B:D1:0D:9E:BE:93
              X509v3 Extended Key Usage:
                  TLS Web Client Authentication
              X509v3 Subject Alternative Name:
                  DNS:*.clientdomain.com, IP Address:127.0.0.1, DNS:localhost
  Certificate is to be certified until Aug 21 21:23:35 2021 GMT (365 days)

  Write out database with 1 new entries
  Data Base Updated
  ------ certs created for myCustomService ------
  ------ Certs created successfully and copied to myServiceCertsDir directoty ------
  ```
  * Output files
  ```
  $ tree myServiceCertsDir
  myServiceCertsDir
  ├── 10.pem
  ├── myCA.pem
  ├── myCustomService_key.pem
  └── myCustomService_node_crt.pem
  ```
  * **NOTE**: Above client certificate has only `TLS Web Client Authentication` extension.