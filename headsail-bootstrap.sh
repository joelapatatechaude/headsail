#!/bin/sh
NSTUDENT=3
SESSION=academy-1
ARGOCD_USERNAME=admin

oc apply -f bootstrap

echo "hit any key ONCE gitops argocd is ready"
read answer

ARGOCD_SERVER=$(oc get route -n openshift-gitops openshift-gitops-server -o jsonpath='{.spec.host}')
ARGOCD_PASSWORD=$(oc get secret openshift-gitops-cluster -n openshift-gitops -o json | jq -r '.data."admin.password"' |  base64 -d)

echo $ARGOCD_SERVER

argocd login "$ARGOCD_SERVER" --username="$ARGOCD_USERNAME" --password="$ARGOCD_PASSWORD" --insecure

argocd app create setup --repo https://github.com/joelapatatechaude/headsail.git --path content/${SESSION}/setup --dest-namespace setup --dest-server https://kubernetes.default.svc --sync-option CreateNamespace=true --server=$ARGOCD_SERVER --insecure
argocd app sync setup
argocd app wait setup --health

#argocd app create student-$STUDENT_ID --repo $(params.git-repo) --path $(params.path) --dest-namespace student-$STUDENT_ID --label headsail.student-id=$STUDENT_ID --dest-server https://kubernetes.default.svc --sync-option CreateNamespace=true 
#argocd app sync -l headsail.student-id=$STUDENT_ID
#argocd app wait -l headsail.student-id=$STUDENT_ID --health

for i in $(seq 1 $NSTUDENT); do
    echo $i
    N=stu-$i
    argocd app create $N --repo https://github.com/joelapatatechaude/headsail.git --path content/${SESSION}/challenges --dest-namespace $N --dest-server https://kubernetes.default.svc --sync-option CreateNamespace=true --server=$ARGOCD_SERVER --insecure
    argocd app sync $N
    argocd app wait $N --health
done
