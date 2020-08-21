* Generates
  * self-signed CA, CAkey
  * Server certificate signed by CA, Server key
  * client certificate signed by CA, client key
* how to run
  * modify alternate_names in `openSSLConf/server_san.cnf` file.
  * `./cert_generation.sh -o generatedCertsDir`

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

* output files after running the script
```
$ tree generatedCertsDir
generatedCertsDir
├── 10.pem
├── 11.pem
├── elasticsearch_key.pem
├── elasticsearch_node_crt.pem
├── kibana_key.pem
├── kibana_node_crt.pem
└── myCA.pem
```