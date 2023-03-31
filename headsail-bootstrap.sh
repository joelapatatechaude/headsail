#!/bin/sh
NSTUDENT=3
SESSION=academy-1
ARGOCD_USERNAME=admin



oc apply -f bootstrap


echo "hit any key ONCE gitops is ready"
read answer

ARGOCD_SERVER=$(oc get route -n openshift-gitops openshift-gitops-server -o jsonpath='{.spec.host}')
ARGOCD_PASSWORD=$(oc get secret openshift-gitops-cluster -n openshift-gitops -o json | jq -r '.data."admin.password"' |  base64 -d)

argocd app create setup --repo https://github.com/joelapatatechaude/headsail --path content/${SESSION}/setup --dest-namespace setup --dest-server https://kubernetes.default.svc --sync-option CreateNamespace=true
#argocd app create student-$STUDENT_ID --repo $(params.git-repo) --path $(params.path) --dest-namespace student-$STUDENT_ID --label headsail.student-id=$STUDENT_ID --dest-server https://kubernetes.default.svc --sync-option CreateNamespace=true 
#argocd app sync -l headsail.student-id=$STUDENT_ID
#argocd app wait -l headsail.student-id=$STUDENT_ID --health


for i in $(seq 1 $NSTUDENT); do
    echo $i
done
