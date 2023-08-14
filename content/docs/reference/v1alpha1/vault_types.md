---
title: VaultSpec
weight: 200
generated_file: true
---

## VaultSpec

VaultSpec defines the desired state of Vault

### size (int32, optional) {#vaultspec-size}

Size defines the number of Vault instances in the cluster (>= 1 means HA) default: 1 

Default: -

### image (string, optional) {#vaultspec-image}

Image specifies the Vault image to use for the Vault instances default: hashicorp/vault:latest 

Default: -

### bankVaultsImage (string, optional) {#vaultspec-bankvaultsimage}

BankVaultsImage specifies the Bank Vaults image to use for Vault unsealing and configuration default: ghcr.io/bank-vaults/bank-vaults:latest 

Default: -

### bankVaultsVolumeMounts ([]v1.VolumeMount, optional) {#vaultspec-bankvaultsvolumemounts}

BankVaultsVolumeMounts define some extra Kubernetes Volume mounts for the Bank Vaults Sidecar container. default: 

Default: -

### statsdDisabled (bool, optional) {#vaultspec-statsddisabled}

StatsDDisabled specifies if StatsD based metrics should be disabled default: false 

Default: -

### statsdImage (string, optional) {#vaultspec-statsdimage}

StatsDImage specifices the StatsD image to use for Vault metrics exportation default: prom/statsd-exporter:latest 

Default: -

### statsdConfig (string, optional) {#vaultspec-statsdconfig}

StatsdConfig specifices the StatsD mapping configuration default: 

Default: -

### fluentdEnabled (bool, optional) {#vaultspec-fluentdenabled}

FluentDEnabled specifies if FluentD based log exportation should be enabled default: false 

Default: -

### fluentdImage (string, optional) {#vaultspec-fluentdimage}

FluentDImage specifices the FluentD image to use for Vault log exportation default: fluent/fluentd:edge 

Default: -

### fluentdConfLocation (string, optional) {#vaultspec-fluentdconflocation}

FluentDConfLocation is the location of the fluent.conf file default: "/fluentd/etc" 

Default: -

### fluentdConfFile (string, optional) {#vaultspec-fluentdconffile}

FluentDConfFile specifices the FluentD configuration file name to use for Vault log exportation default: 

Default: -

### fluentdConfig (string, optional) {#vaultspec-fluentdconfig}

FluentDConfig specifices the FluentD configuration to use for Vault log exportation default: 

Default: -

### watchedSecretsLabels ([]map[string]string, optional) {#vaultspec-watchedsecretslabels}

WatchedSecretsLabels specifices a set of Kubernetes label selectors which select Secrets to watch. If these Secrets change the Vault cluster gets restarted. For example a Secret that Cert-Manager is managing a public Certificate for Vault using let's Encrypt. default: 

Default: -

### watchedSecretsAnnotations ([]map[string]string, optional) {#vaultspec-watchedsecretsannotations}

WatchedSecretsAnnotations specifices a set of Kubernetes annotations selectors which select Secrets to watch. If these Secrets change the Vault cluster gets restarted. For example a Secret that Cert-Manager is managing a public Certificate for Vault using let's Encrypt. default: 

Default: -

### annotations (map[string]string, optional) {#vaultspec-annotations}

Annotations define a set of common Kubernetes annotations that will be added to all operator managed resources. default: 

Default: -

### vaultAnnotations (map[string]string, optional) {#vaultspec-vaultannotations}

VaultAnnotations define a set of Kubernetes annotations that will be added to all Vault Pods. default: 

Default: -

### vaultLabels (map[string]string, optional) {#vaultspec-vaultlabels}

VaultLabels define a set of Kubernetes labels that will be added to all Vault Pods. default: 

Default: -

### vaultPodSpec (*EmbeddedPodSpec, optional) {#vaultspec-vaultpodspec}

VaultPodSpec is a Kubernetes Pod specification snippet (`spec:` block) that will be merged into the operator generated Vault Pod specification. default: 

Default: -

### vaultContainerSpec (v1.Container, optional) {#vaultspec-vaultcontainerspec}

VaultContainerSpec is a Kubernetes Container specification snippet that will be merged into the operator generated Vault Container specification. default: 

Default: -

### vaultConfigurerAnnotations (map[string]string, optional) {#vaultspec-vaultconfigurerannotations}

VaultConfigurerAnnotations define a set of Kubernetes annotations that will be added to the Vault Configurer Pod. default: 

Default: -

### vaultConfigurerLabels (map[string]string, optional) {#vaultspec-vaultconfigurerlabels}

VaultConfigurerLabels define a set of Kubernetes labels that will be added to all Vault Configurer Pod. default: 

Default: -

### vaultConfigurerPodSpec (*EmbeddedPodSpec, optional) {#vaultspec-vaultconfigurerpodspec}

VaultConfigurerPodSpec is a Kubernetes Pod specification snippet (`spec:` block) that will be merged into the operator generated Vault Configurer Pod specification. default: 

Default: -

### config (extv1beta1.JSON, required) {#vaultspec-config}

Config is the Vault Server configuration. See https://www.vaultproject.io/docs/configuration/ for more details. default: 

Default: -

### externalConfig (extv1beta1.JSON, optional) {#vaultspec-externalconfig}

ExternalConfig is higher level configuration block which instructs the Bank Vaults Configurer to configure Vault through its API, thus allows setting up: - Secret Engines - Auth Methods - Audit Devices - Plugin Backends - Policies - Startup Secrets (Bank Vaults feature) A documented example: https://github.com/bank-vaults/vault-operator/blob/main/vault-config.yml default: 

Default: -

### unsealConfig (UnsealConfig, optional) {#vaultspec-unsealconfig}

UnsealConfig defines where the Vault cluster's unseal keys and root token should be stored after initialization. See the type's documentation for more details. Only one method may be specified. default: Kubernetes Secret based unsealing 

Default: -

### credentialsConfig (CredentialsConfig, optional) {#vaultspec-credentialsconfig}

CredentialsConfig defines a external Secret for Vault and how it should be mounted to the Vault Pod for example accessing Cloud resources. default: 

Default: -

### envsConfig ([]v1.EnvVar, optional) {#vaultspec-envsconfig}

EnvsConfig is a list of Kubernetes environment variable definitions that will be passed to all Bank-Vaults pods. default: 

Default: -

### securityContext (v1.PodSecurityContext, optional) {#vaultspec-securitycontext}

SecurityContext is a Kubernetes PodSecurityContext that will be applied to all Pods created by the operator. default: 

Default: -

### serviceType (string, optional) {#vaultspec-servicetype}

ServiceType is a Kubernetes Service type of the Vault Service. default: ClusterIP 

Default: -

### loadBalancerIP (string, optional) {#vaultspec-loadbalancerip}

LoadBalancerIP is an optional setting for allocating a specific address for the entry service object of type LoadBalancer default: "" 

Default: -

### serviceRegistrationEnabled (bool, optional) {#vaultspec-serviceregistrationenabled}

serviceRegistrationEnabled enables the injection of the service_registration Vault stanza. This requires elaborated RBAC privileges for updating Pod labels for the Vault Pod. default: false 

Default: -

### raftLeaderAddress (string, optional) {#vaultspec-raftleaderaddress}

RaftLeaderAddress defines the leader address of the raft cluster in multi-cluster deployments. (In single cluster (namespace) deployments it is automatically detected). "self" is a special value which means that this instance should be the bootstrap leader instance. default: "" 

Default: -

### servicePorts (map[string]int32, optional) {#vaultspec-serviceports}

ServicePorts is an extra map of ports that should be exposed by the Vault Service. default: 

Default: -

### affinity (*v1.Affinity, optional) {#vaultspec-affinity}

Affinity is a group of affinity scheduling rules applied to all Vault Pods. default: 

Default: -

### podAntiAffinity (string, optional) {#vaultspec-podantiaffinity}

PodAntiAffinity is the TopologyKey in the Vault Pod's PodAntiAffinity. No PodAntiAffinity is used if empty. Deprecated. Use Affinity. default: 

Default: -

### nodeAffinity (v1.NodeAffinity, optional) {#vaultspec-nodeaffinity}

NodeAffinity is Kubernetees NodeAffinity definition that should be applied to all Vault Pods. Deprecated. Use Affinity. default: 

Default: -

### nodeSelector (map[string]string, optional) {#vaultspec-nodeselector}

NodeSelector is Kubernetees NodeSelector definition that should be applied to all Vault Pods. default: 

Default: -

### tolerations ([]v1.Toleration, optional) {#vaultspec-tolerations}

Tolerations is Kubernetes Tolerations definition that should be applied to all Vault Pods. default: 

Default: -

### serviceAccount (string, optional) {#vaultspec-serviceaccount}

ServiceAccount is Kubernetes ServiceAccount in which the Vault Pods should be running in. default: default 

Default: -

### volumes ([]v1.Volume, optional) {#vaultspec-volumes}

Volumes define some extra Kubernetes Volumes for the Vault Pods. default: 

Default: -

### volumeMounts ([]v1.VolumeMount, optional) {#vaultspec-volumemounts}

VolumeMounts define some extra Kubernetes Volume mounts for the Vault Pods. default: 

Default: -

### volumeClaimTemplates ([]EmbeddedPersistentVolumeClaim, optional) {#vaultspec-volumeclaimtemplates}

VolumeClaimTemplates define some extra Kubernetes PersistentVolumeClaim templates for the Vault Statefulset. default: 

Default: -

### vaultEnvsConfig ([]v1.EnvVar, optional) {#vaultspec-vaultenvsconfig}

VaultEnvsConfig is a list of Kubernetes environment variable definitions that will be passed to the Vault container. default: 

Default: -

### sidecarEnvsConfig ([]v1.EnvVar, optional) {#vaultspec-sidecarenvsconfig}

SidecarEnvsConfig is a list of Kubernetes environment variable definitions that will be passed to Vault sidecar containers. default: 

Default: -

### resources (*Resources, optional) {#vaultspec-resources}

Resources defines the resource limits for all the resources created by the operator. See the type for more details. default: 

Default: -

### ingress (*Ingress, optional) {#vaultspec-ingress}

Ingress, if it is specified the operator will create an Ingress resource for the Vault Service and will annotate it with the correct Ingress annotations specific to the TLS settings in the configuration. See the type for more details. default: 

Default: -

### serviceMonitorEnabled (bool, optional) {#vaultspec-servicemonitorenabled}

ServiceMonitorEnabled enables the creation of Prometheus Operator specific ServiceMonitor for Vault. default: false 

Default: -

### existingTlsSecretName (string, optional) {#vaultspec-existingtlssecretname}

ExistingTLSSecretName is name of the secret that contains a TLS server certificate and key and the corresponding CA certificate. Required secret format kubernetes.io/tls type secret keys + ca.crt key If it is set, generating certificate will be disabled default: "" 

Default: -

### tlsExpiryThreshold (string, optional) {#vaultspec-tlsexpirythreshold}

TLSExpiryThreshold is the Vault TLS certificate expiration threshold in Go's Duration format. default: 168h 

Default: -

### tlsAdditionalHosts ([]string, optional) {#vaultspec-tlsadditionalhosts}

TLSAdditionalHosts is a list of additional hostnames or IP addresses to add to the SAN on the automatically generated TLS certificate. default: 

Default: -

### caNamespaces ([]string, optional) {#vaultspec-canamespaces}

CANamespaces define a list of namespaces where the generated CA certificate for Vault should be distributed, use ["*"] for all namespaces. default: 

Default: -

### istioEnabled (bool, optional) {#vaultspec-istioenabled}

IstioEnabled describes if the cluster has a Istio running and enabled. default: false 

Default: -

### veleroEnabled (bool, optional) {#vaultspec-veleroenabled}

VeleroEnabled describes if the cluster has a Velero running and enabled. default: false 

Default: -

### veleroFsfreezeImage (string, optional) {#vaultspec-velerofsfreezeimage}

VeleroFsfreezeImage specifices the Velero Fsrfeeze image to use in Velero backup hooks default: velero/fsfreeze-pause:latest 

Default: -

### vaultContainers ([]v1.Container, optional) {#vaultspec-vaultcontainers}

VaultContainers add extra containers 

Default: -

### vaultInitContainers ([]v1.Container, optional) {#vaultspec-vaultinitcontainers}

VaultInitContainers add extra initContainers 

Default: -


## VaultStatus

VaultStatus defines the observed state of Vault

### nodes ([]string, required) {#vaultstatus-nodes}

Important: Run "make generate-code" to regenerate code after modifying this file 

Default: -

### leader (string, required) {#vaultstatus-leader}

Default: -

### conditions ([]v1.ComponentCondition, optional) {#vaultstatus-conditions}

Default: -


## UnsealOptions

UnsealOptions represents the common options to all unsealing backends

### preFlightChecks (*bool, optional) {#unsealoptions-preflightchecks}

Default: -

### storeRootToken (*bool, optional) {#unsealoptions-storeroottoken}

Default: -

### secretThreshold (*uint, optional) {#unsealoptions-secretthreshold}

Default: -

### secretShares (*uint, optional) {#unsealoptions-secretshares}

Default: -


## UnsealConfig

UnsealConfig represents the UnsealConfig field of a VaultSpec Kubernetes object

### options (UnsealOptions, optional) {#unsealconfig-options}

Default: -

### kubernetes (KubernetesUnsealConfig, optional) {#unsealconfig-kubernetes}

Default: -

### google (*GoogleUnsealConfig, optional) {#unsealconfig-google}

Default: -

### alibaba (*AlibabaUnsealConfig, optional) {#unsealconfig-alibaba}

Default: -

### azure (*AzureUnsealConfig, optional) {#unsealconfig-azure}

Default: -

### aws (*AWSUnsealConfig, optional) {#unsealconfig-aws}

Default: -

### vault (*VaultUnsealConfig, optional) {#unsealconfig-vault}

Default: -

### hsm (*HSMUnsealConfig, optional) {#unsealconfig-hsm}

Default: -


## KubernetesUnsealConfig

KubernetesUnsealConfig holds the parameters for Kubernetes based unsealing

### secretNamespace (string, optional) {#kubernetesunsealconfig-secretnamespace}

Default: -

### secretName (string, optional) {#kubernetesunsealconfig-secretname}

Default: -


## GoogleUnsealConfig

GoogleUnsealConfig holds the parameters for Google KMS based unsealing

### kmsKeyRing (string, required) {#googleunsealconfig-kmskeyring}

Default: -

### kmsCryptoKey (string, required) {#googleunsealconfig-kmscryptokey}

Default: -

### kmsLocation (string, required) {#googleunsealconfig-kmslocation}

Default: -

### kmsProject (string, required) {#googleunsealconfig-kmsproject}

Default: -

### storageBucket (string, required) {#googleunsealconfig-storagebucket}

Default: -


## AlibabaUnsealConfig

AlibabaUnsealConfig holds the parameters for Alibaba Cloud KMS based unsealing

--alibaba-kms-region eu-central-1 --alibaba-kms-key-id 9d8063eb-f9dc-421b-be80-15d195c9f148 --alibaba-oss-endpoint oss-eu-central-1.aliyuncs.com --alibaba-oss-bucket bank-vaults

### kmsRegion (string, required) {#alibabaunsealconfig-kmsregion}

Default: -

### kmsKeyId (string, required) {#alibabaunsealconfig-kmskeyid}

Default: -

### ossEndpoint (string, required) {#alibabaunsealconfig-ossendpoint}

Default: -

### ossBucket (string, required) {#alibabaunsealconfig-ossbucket}

Default: -

### ossPrefix (string, required) {#alibabaunsealconfig-ossprefix}

Default: -


## AzureUnsealConfig

AzureUnsealConfig holds the parameters for Azure Key Vault based unsealing

### keyVaultName (string, required) {#azureunsealconfig-keyvaultname}

Default: -


## AWSUnsealConfig

AWSUnsealConfig holds the parameters for AWS KMS based unsealing

### kmsKeyId (string, required) {#awsunsealconfig-kmskeyid}

Default: -

### kmsRegion (string, optional) {#awsunsealconfig-kmsregion}

Default: -

### kmsEncryptionContext (string, optional) {#awsunsealconfig-kmsencryptioncontext}

Default: -

### s3Bucket (string, required) {#awsunsealconfig-s3bucket}

Default: -

### s3Prefix (string, required) {#awsunsealconfig-s3prefix}

Default: -

### s3Region (string, optional) {#awsunsealconfig-s3region}

Default: -

### s3SSE (string, optional) {#awsunsealconfig-s3sse}

Default: -


## VaultUnsealConfig

VaultUnsealConfig holds the parameters for remote Vault based unsealing

### address (string, required) {#vaultunsealconfig-address}

Default: -

### unsealKeysPath (string, required) {#vaultunsealconfig-unsealkeyspath}

Default: -

### role (string, optional) {#vaultunsealconfig-role}

Default: -

### authPath (string, optional) {#vaultunsealconfig-authpath}

Default: -

### tokenPath (string, optional) {#vaultunsealconfig-tokenpath}

Default: -

### token (string, optional) {#vaultunsealconfig-token}

Default: -


## HSMUnsealConfig

HSMUnsealConfig holds the parameters for remote HSM based unsealing

### daemon (bool, optional) {#hsmunsealconfig-daemon}

Default: -

### modulePath (string, required) {#hsmunsealconfig-modulepath}

Default: -

### slotId (uint, optional) {#hsmunsealconfig-slotid}

Default: -

### tokenLabel (string, optional) {#hsmunsealconfig-tokenlabel}

Default: -

### pin (string, required) {#hsmunsealconfig-pin}

Default: -

### keyLabel (string, required) {#hsmunsealconfig-keylabel}

Default: -


## CredentialsConfig

CredentialsConfig configuration for a credentials file provided as a secret

### env (string, required) {#credentialsconfig-env}

Default: -

### path (string, required) {#credentialsconfig-path}

Default: -

### secretName (string, required) {#credentialsconfig-secretname}

Default: -


## Resources

Resources holds different container's ResourceRequirements

### vault (*v1.ResourceRequirements, optional) {#resources-vault}

Default: -

### bankVaults (*v1.ResourceRequirements, optional) {#resources-bankvaults}

Default: -

### hsmDaemon (*v1.ResourceRequirements, optional) {#resources-hsmdaemon}

Default: -

### prometheusExporter (*v1.ResourceRequirements, optional) {#resources-prometheusexporter}

Default: -

### fluentd (*v1.ResourceRequirements, optional) {#resources-fluentd}

Default: -


## Ingress

Ingress specification for the Vault cluster

### annotations (map[string]string, optional) {#ingress-annotations}

Default: -

### spec (netv1.IngressSpec, optional) {#ingress-spec}

Default: -


## Vault

Vault is the Schema for the vaults API

###  (metav1.TypeMeta, required) {#vault-}

Default: -

### metadata (metav1.ObjectMeta, optional) {#vault-metadata}

Default: -

### spec (VaultSpec, optional) {#vault-spec}

Default: -

### status (VaultStatus, optional) {#vault-status}

Default: -


## VaultList

VaultList contains a list of Vault

###  (metav1.TypeMeta, required) {#vaultlist-}

Default: -

### metadata (metav1.ListMeta, optional) {#vaultlist-metadata}

Default: -

### items ([]Vault, required) {#vaultlist-items}

Default: -


