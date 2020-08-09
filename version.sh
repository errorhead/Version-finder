#!/bin/bash

#check if kubeconfig env is set
if [ -z "$KUBECONFIG" ] ; then
 echo "kubeconfig is not set!"
 exit 1
fi

VENDOR=vendor/katalog

if [ -d "${VENDOR}" ] ; then
 echo "true" > /dev/null 2>&1
else
 echo "Directory ${VENDOR} not exist!"
 exit 2
fi

function main () {
 
    find ${VENDOR} -type f -name "kustomization.yaml" | \
    xargs egrep namespace | awk -F":" '{ print $3 }' | sort -u | sed -E 's/^ //g' | grep -v default | \
 
    while read LINE
     do
        A=$(printf "${LINE}\t")
        B=$(kubectl get pods -n ${LINE} -o yaml | grep 'image\:' | sed -E "s/[[:space:]]+\-?//g" | sort -u | wc -l)
        if [ ${B} -eq 0 ] ; then
         echo -e "${A} ${B}" > /dev/null 2>&1
        else
         echo "${A}" ; kubectl get pods -n ${A} -o yaml | grep 'image\:' | sed -E "s/[[:space:]]+\-?//g" | sort -u
        fi
    done

}

#
## run main function
#
main
