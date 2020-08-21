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

  echo "------ Certs created successfully and copied to ${finalCertsDir} directory ------"
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
  usageMsg="./$(basename $0) -o </full/path/to/certs/to/store> -s <service name> -t <service type [server|client]> -c <CN Name in Certificate> -e <email to be used in certificate>"
  while getopts "o:s:t:c:e:" option
  do
    case "$option" in
      o) finalCertsDir="$OPTARG"
        ;;
      s) serviceName="$OPTARG"
        ;;
      t) serviceType="$OPTARG"
        ;;
      c) CN_name="$OPTARG"
        ;;
      e) certEmail="$OPTARG"
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
  set +u

  if [[ -z "$finalCertsDir" ]]
  then
    echo "argument value to -o must be specified"
    echo "$usageMsg"
    exit 3
  fi

  if [[ -z "$serviceName" ]]
  then
    echo "argument value to -s must be specified"
    echo "$usageMsg"
    exit 3
  fi

  if [[ -z "$serviceType" ]]
  then
    echo "argument value to -t must be specified"
    echo "$usageMsg"
    exit 3
  fi

  if [[ -z "$CN_name" ]]
  then
    echo "argument value to -c must be specified"
    echo "$usageMsg"
    exit 3
  fi

  if [[ -z "$certEmail" ]]
  then
    echo "argument value to -e must be specified"
    echo "$usageMsg"
    exit 3
  fi
  set -u

  case "${serviceType}" in
    "server") sanFileToUse="server_san.cnf"
      ;;
    "client") sanFileToUse="client_san.cnf"
      ;;
      *) echo "argument value to -t can be either 'server' or 'client' only"
         exit 3
      ;;
  esac

  mkdir "$finalCertsDir"
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
  generateCSRAndCertsFor "${serviceName}" "${opensslTmplConfDir}/${sanFileToUse}" "${serviceType}" "${CN_name}" "${certEmail}"
  cleanup
}

#===== main ======#
main "$@"
