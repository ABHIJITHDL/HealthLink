#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $5)
    local CP=$(one_line_pem $6)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${P1PORT}/$3/" \
        -e "s/\${CAPORT}/$4/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        ccp-template.json 
}

# function yaml_ccp {
#     local PP=$(one_line_pem $5)
#     local CP=$(one_line_pem $6)
#     sed -e "s/\${ORG}/$1/" \
#         -e "s/\${P0PORT}/$2/" \
#         -e "s/\${P1PORT}/$3/" \
#         -e "s/\${CAPORT}/$4/" \
#         -e "s#\${PEERPEM}#$PP#" \
#         -e "s#\${CAPEM}#$CP#" \
#         ccp-template.yaml | sed -e $'s/\\\\n/\\\n        /g'
# }

ORG=1
P0PORT=7051
P1PORT=8051
CAPORT=7054
PEERPEM=artifacts/channel/crypto-config/peerOrganizations/org1.example.com/tlsca/tlsca.org1.example.com-cert.pem
CAPEM=artifacts/channel/crypto-config/peerOrganizations/org1.example.com/ca/ca.org1.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > ../backend/src/main/resources/static/connection-profiles/org1/connection-org1.json
# echo "$(yaml_ccp $ORG $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > EHR/src/main/resources/static/connection-profiles/connection-org1.yaml

ORG=2
P0PORT=9051
P1PORT=10051
CAPORT=8054
PEERPEM=artifacts/channel/crypto-config/peerOrganizations/org2.example.com/tlsca/tlsca.org2.example.com-cert.pem
CAPEM=artifacts/channel/crypto-config/peerOrganizations/org2.example.com/ca/ca.org2.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > ../backend/src/main/resources/static/connection-profiles/org2/connection-org2.json
# echo "$(yaml_ccp $ORG $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > EHR/src/main/resources/static/connection-profiles/connection-org2.yaml
