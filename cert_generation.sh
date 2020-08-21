#! /bin/bash

set -euo pipefail

[[ "$(uname)" == "Darwin" ]] && READLINK="greadlink" || READLINK="readlink"
[[ "$(uname)" == "Darwin" ]] && OPENSSL="/usr/local/opt/openssl/bin/openssl" || OPENSSL="openssl"

this_script_full_path=$($READLINK -f $0)
this_script_loc=$(dirname ${this_script_full_path})
opensslTmplConfDir="${this_script_loc}/openSSLConf"
baseDir=$(mktemp -d)

function removeOldPKISetup() {
  echo "------ Remove old dir setup ${baseDir} if present"
  rm -rf "${baseDir}"
}

function createPKISetup() {
  CSRsDir="${baseDir}/CSRs"
  privateKeysDir="${baseDir}/privateKeys"
  certDir="${baseDir}/certs"
  caCertDir="${baseDir}/caCert"
  caDataBase="${baseDir}/caDatabase"
  opensslConfDir="${baseDir}/opensslConf"
  tempDir=$(mktemp -d)

  mkdir -p "$baseDir"
  mkdir -p "$CSRsDir" "$privateKeysDir" "$certDir" "$caCertDir" "$opensslConfDir" "$caDataBase"
  touch "${caDataBase}/index.txt"
  echo 10 > "${caDataBase}/serial"
  chmod 700 "${privateKeysDir}"
  chmod 700 "$caCertDir"

  cat "${opensslTmplConfDir}/CA_openssl.cnf.tmpl" | sed -e 's|\<TO_BE_REPLACED\>|'${baseDir}'|g' > "${opensslConfDir}/CA_openssl.cnf"
  cp -f "${opensslTmplConfDir}/csr_openssl.cnf" "${opensslConfDir}"
}

function createSelfSignedCACert() {
  email="my@email.com"
  country="GB"
  state="London"
  location="London"
  org="MyCompany"
  orgUnit="Engg"
  commonName=$(hostname)

  subjectLine="/emailAddress=${email}/C=${country}/ST=${state}/L=${location}/O=${org}/OU=${orgUnit}/CN=${commonName}"

  echo "------ Creating self signed CA authority ------"
  ${OPENSSL} req -config ${opensslConfDir}/CA_openssl.cnf \
    -new -x509 \
    -out ${caCertDir}/myCA.pem \
    -newkey rsa:2048 -keyout ${caCertDir}/myCAKey.pem \
    -extensions v3_ca \
    -days 365 \
    -nodes \
    -subj "${subjectLine}"
}

function copyCertsToOutputDir() {
  cp -f ${certDir}/* ${finalCertsDir}
  cp -f ${privateKeysDir}/* ${finalCertsDir}
  cp -f ${caCertDir}/myCA.pem ${finalCertsDir}/myCA.pem
  chmod 600 ${finalCertsDir}/${serviceName}_key.pem

  echo "------ Certs created successfully and copied to ${finalCertsDir} directoty ------"
}

function generateCSRAndCertsFor() {
  serviceName="$1"
  sanFile="$2"
  certType="$3"
  commonName="$4"
  email="$5"

  country="GB"
  state="London"
  location="London"
  org="MyCompany"
  orgUnit="Engg"
  subjectLine="/emailAddress=${email}/C=${country}/ST=${state}/L=${location}/O=${org}/OU=${orgUnit}/CN=${commonName}"

  echo "------ Creating CSR for ${serviceName} ------"
  ${OPENSSL} req -config <(cat ${opensslConfDir}/csr_openssl.cnf ${sanFile}) \
    -new -newkey rsa:2048 \
    -nodes -days 5000 \
    -out ${CSRsDir}/${serviceName}.csr \
    -keyout ${privateKeysDir}/${serviceName}_key.pem \
    -subj "${subjectLine}" \
    -reqexts ${certType}


  echo "------ Signing CSR for ${serviceName} ------"
  ${OPENSSL} ca \
    -config ${opensslConfDir}/CA_openssl.cnf \
    -policy policy_anything \
    -cert ${caCertDir}/myCA.pem \
    -keyfile ${caCertDir}/myCAKey.pem \
    -in ${CSRsDir}/${serviceName}.csr \
    -batch \
    -out ${certDir}/${serviceName}_node_crt.pem

  chmod 600 ${privateKeysDir}/*
  echo "------ certs created for ${serviceName} ------"

  copyCertsToOutputDir
}

function getCmdArguments() {
  usageMsg="./$(basename $0) -o </full/path/to/certs/to/store>"
  while getopts "o:" option
  do
    case "$option" in
      o) finalCertsDir="$OPTARG"
        mkdir "$finalCertsDir"
        ;;
      ?) echo "${usageMsg}"
        exit 2
        ;;
    esac
  done

  if (($OPTIND == 1))
  then
    echo "$usageMsg"
    exit 2
  fi

  shift "$((OPTIND - 1))"

  if [[ -z "$finalCertsDir" ]]
  then
    echo "argument value to -o must be specified"
    exit 3
  fi

  echo "------ Starting to create certs ------"
}

function cleanup() {
  rm -rf ${baseDir} ${tempDir}
}

function main() {
  getCmdArguments "$@"
  removeOldPKISetup
  createPKISetup
  createSelfSignedCACert
  generateCSRAndCertsFor "elasticsearch" "${opensslTmplConfDir}/server_san.cnf" "server" "elasticsearch.example.com" "server@example.com"

  # uncomment following to create client cert for Kibana (or some other service)
  # generateCSRAndCertsFor "kibana" "${opensslTmplConfDir}/client_san.cnf" "client" "kibana.example.com" "client@example.com"
  cleanup
}

#===== main ======#
main "$@"