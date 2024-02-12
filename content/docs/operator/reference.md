---
title: API Reference
---

## Packages
- [vault.banzaicloud.com/v1alpha1](#vaultbanzaicloudcomv1alpha1)


## vault.banzaicloud.com/v1alpha1

Package v1alpha1 contains API Schema definitions for the vault.banzaicloud.com v1alpha1 API group

- [Vault](#vault)
- [VaultList](#vaultlist)



### AWSUnsealConfig



AWSUnsealConfig holds the parameters for AWS KMS based unsealing

_Appears in:_
- [UnsealConfig](#unsealconfig)

#### `kmsKeyId` (_string_)


#### `kmsRegion` (_string_)


#### `kmsEncryptionContext` (_string_)


#### `s3Bucket` (_string_)


#### `s3Prefix` (_string_)


#### `s3Region` (_string_)


#### `s3SSE` (_string_)




### AlibabaUnsealConfig



AlibabaUnsealConfig holds the parameters for Alibaba Cloud KMS based unsealing 
 --alibaba-kms-region eu-central-1 --alibaba-kms-key-id 9d8063eb-f9dc-421b-be80-15d195c9f148 --alibaba-oss-endpoint oss-eu-central-1.aliyuncs.com --alibaba-oss-bucket bank-vaults

_Appears in:_
- [UnsealConfig](#unsealconfig)

#### `kmsRegion` (_string_)


#### `kmsKeyId` (_string_)


#### `ossEndpoint` (_string_)


#### `ossBucket` (_string_)


#### `ossPrefix` (_string_)




### AzureUnsealConfig



AzureUnsealConfig holds the parameters for Azure Key Vault based unsealing

_Appears in:_
- [UnsealConfig](#unsealconfig)

#### `keyVaultName` (_string_)




### CredentialsConfig



CredentialsConfig configuration for a credentials file provided as a secret

_Appears in:_
- [VaultSpec](#vaultspec)

#### `env` (_string_)


#### `path` (_string_)


#### `secretName` (_string_)




### EmbeddedObjectMetadata



EmbeddedObjectMetadata contains a subset of the fields included in k8s.io/apimachinery/pkg/apis/meta/v1.ObjectMeta Only fields which are relevant to embedded resources are included. controller-gen discards embedded ObjectMetadata type fields, so we have to overcome this.

_Appears in:_
- [EmbeddedPersistentVolumeClaim](#embeddedpersistentvolumeclaim)

#### `name` (_string_)

Name must be unique within a namespace. Is required when creating resources, although some resources may allow a client to request the generation of an appropriate name automatically. Name is primarily intended for creation idempotence and configuration definition. Cannot be updated. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
#### `labels` (_object (keys:string, values:string)_)

Map of string keys and values that can be used to organize and categorize (scope and select) objects. May match selectors of replication controllers and services. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
#### `annotations` (_object (keys:string, values:string)_)

Annotations is an unstructured key value map stored with a resource that may be set by external tools to store and retrieve arbitrary metadata. They are not queryable and should be preserved when modifying objects. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/


### EmbeddedPersistentVolumeClaim



EmbeddedPersistentVolumeClaim is an embeddable and controller-gen friendly version of k8s.io/api/core/v1.PersistentVolumeClaim. It contains TypeMeta and a reduced ObjectMeta.

_Appears in:_
- [VaultSpec](#vaultspec)

#### `metadata` (_[EmbeddedObjectMetadata](#embeddedobjectmetadata)_)

Refer to Kubernetes API documentation for fields of `metadata`.
#### `spec` (_[PersistentVolumeClaimSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#persistentvolumeclaimspec-v1-core)_)

Spec defines the desired characteristics of a volume requested by a pod author. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistentvolumeclaims


### EmbeddedPodSpec



EmbeddedPodSpec is a description of a pod, which allows containers to be missing, almost as k8s.io/api/core/v1.PodSpec.

_Appears in:_
- [VaultSpec](#vaultspec)

#### `volumes` (_[Volume](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#volume-v1-core) array_)

List of volumes that can be mounted by containers belonging to the pod. More info: https://kubernetes.io/docs/concepts/storage/volumes
#### `initContainers` (_[Container](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#container-v1-core) array_)

List of initialization containers belonging to the pod. Init containers are executed in order prior to containers being started. If any init container fails, the pod is considered to have failed and is handled according to its restartPolicy. The name for an init container or normal container must be unique among all containers. Init containers may not have Lifecycle actions, Readiness probes, Liveness probes, or Startup probes. The resourceRequirements of an init container are taken into account during scheduling by finding the highest request/limit for each resource type, and then using the max of of that value or the sum of the normal containers. Limits are applied to init containers in a similar fashion. Init containers cannot currently be added or removed. Cannot be updated. More info: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/
#### `containers` (_[Container](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#container-v1-core) array_)

List of containers belonging to the pod. Containers cannot currently be added or removed. There must be at least one container in a Pod. Cannot be updated.
#### `ephemeralContainers` (_[EphemeralContainer](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#ephemeralcontainer-v1-core) array_)

List of ephemeral containers run in this pod. Ephemeral containers may be run in an existing pod to perform user-initiated actions such as debugging. This list cannot be specified when creating a pod, and it cannot be modified by updating the pod spec. In order to add an ephemeral container to an existing pod, use the pod's ephemeralcontainers subresource.
#### `restartPolicy` (_[RestartPolicy](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#restartpolicy-v1-core)_)

Restart policy for all containers within the pod. One of Always, OnFailure, Never. Default to Always. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#restart-policy
#### `terminationGracePeriodSeconds` (_integer_)

Optional duration in seconds the pod needs to terminate gracefully. May be decreased in delete request. Value must be non-negative integer. The value zero indicates stop immediately via the kill signal (no opportunity to shut down). If this value is nil, the default grace period will be used instead. The grace period is the duration in seconds after the processes running in the pod are sent a termination signal and the time when the processes are forcibly halted with a kill signal. Set this value longer than the expected cleanup time for your process. Defaults to 30 seconds.
#### `activeDeadlineSeconds` (_integer_)

Optional duration in seconds the pod may be active on the node relative to StartTime before the system will actively try to mark it failed and kill associated containers. Value must be a positive integer.
#### `dnsPolicy` (_[DNSPolicy](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#dnspolicy-v1-core)_)

Set DNS policy for the pod. Defaults to "ClusterFirst". Valid values are 'ClusterFirstWithHostNet', 'ClusterFirst', 'Default' or 'None'. DNS parameters given in DNSConfig will be merged with the policy selected with DNSPolicy. To have DNS options set along with hostNetwork, you have to specify DNS policy explicitly to 'ClusterFirstWithHostNet'.
#### `nodeSelector` (_object (keys:string, values:string)_)

NodeSelector is a selector which must be true for the pod to fit on a node. Selector which must match a node's labels for the pod to be scheduled on that node. More info: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
#### `serviceAccountName` (_string_)

ServiceAccountName is the name of the ServiceAccount to use to run this pod. More info: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
#### `serviceAccount` (_string_)

DeprecatedServiceAccount is a depreciated alias for ServiceAccountName. Deprecated: Use serviceAccountName instead.
#### `automountServiceAccountToken` (_boolean_)

AutomountServiceAccountToken indicates whether a service account token should be automatically mounted.
#### `nodeName` (_string_)

NodeName is a request to schedule this pod onto a specific node. If it is non-empty, the scheduler simply schedules this pod onto that node, assuming that it fits resource requirements.
#### `hostNetwork` (_boolean_)

Host networking requested for this pod. Use the host's network namespace. If this option is set, the ports that will be used must be specified. Default to false.
#### `hostPID` (_boolean_)

Use the host's pid namespace. Optional: Default to false.
#### `hostIPC` (_boolean_)

Use the host's ipc namespace. Optional: Default to false.
#### `shareProcessNamespace` (_boolean_)

Share a single process namespace between all of the containers in a pod. When this is set containers will be able to view and signal processes from other containers in the same pod, and the first process in each container will not be assigned PID 1. HostPID and ShareProcessNamespace cannot both be set. Optional: Default to false.
#### `securityContext` (_[PodSecurityContext](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#podsecuritycontext-v1-core)_)

SecurityContext holds pod-level security attributes and common container settings. Optional: Defaults to empty.  See type description for default values of each field.
#### `imagePullSecrets` (_[LocalObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#localobjectreference-v1-core) array_)

ImagePullSecrets is an optional list of references to secrets in the same namespace to use for pulling any of the images used by this PodSpec. If specified, these secrets will be passed to individual puller implementations for them to use. More info: https://kubernetes.io/docs/concepts/containers/images#specifying-imagepullsecrets-on-a-pod
#### `hostname` (_string_)

Specifies the hostname of the Pod If not specified, the pod's hostname will be set to a system-defined value.
#### `subdomain` (_string_)

If specified, the fully qualified Pod hostname will be "<hostname>.<subdomain>.<pod namespace>.svc.<cluster domain>". If not specified, the pod will not have a domainname at all.
#### `affinity` (_[Affinity](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#affinity-v1-core)_)

If specified, the pod's scheduling constraints
#### `schedulerName` (_string_)

If specified, the pod will be dispatched by specified scheduler. If not specified, the pod will be dispatched by default scheduler.
#### `tolerations` (_[Toleration](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#toleration-v1-core) array_)

If specified, the pod's tolerations.
#### `hostAliases` (_[HostAlias](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#hostalias-v1-core) array_)

HostAliases is an optional list of hosts and IPs that will be injected into the pod's hosts file if specified. This is only valid for non-hostNetwork pods.
#### `priorityClassName` (_string_)

If specified, indicates the pod's priority. "system-node-critical" and "system-cluster-critical" are two special keywords which indicate the highest priorities with the former being the highest priority. Any other name must be defined by creating a PriorityClass object with that name. If not specified, the pod priority will be default or zero if there is no default.
#### `priority` (_integer_)

The priority value. Various system components use this field to find the priority of the pod. When Priority Admission Controller is enabled, it prevents users from setting this field. The admission controller populates this field from PriorityClassName. The higher the value, the higher the priority.
#### `dnsConfig` (_[PodDNSConfig](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#poddnsconfig-v1-core)_)

Specifies the DNS parameters of a pod. Parameters specified here will be merged to the generated DNS configuration based on DNSPolicy.
#### `readinessGates` (_[PodReadinessGate](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#podreadinessgate-v1-core) array_)

If specified, all readiness gates will be evaluated for pod readiness. A pod is ready when all its containers are ready AND all conditions specified in the readiness gates have status equal to "True" More info: https://git.k8s.io/enhancements/keps/sig-network/580-pod-readiness-gates
#### `runtimeClassName` (_string_)

RuntimeClassName refers to a RuntimeClass object in the node.k8s.io group, which should be used to run this pod.  If no RuntimeClass resource matches the named class, the pod will not be run. If unset or empty, the "legacy" RuntimeClass will be used, which is an implicit class with an empty definition that uses the default runtime handler. More info: https://git.k8s.io/enhancements/keps/sig-node/585-runtime-class
#### `enableServiceLinks` (_boolean_)

EnableServiceLinks indicates whether information about services should be injected into pod's environment variables, matching the syntax of Docker links. Optional: Defaults to true.
#### `preemptionPolicy` (_[PreemptionPolicy](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#preemptionpolicy-v1-core)_)

PreemptionPolicy is the Policy for preempting pods with lower priority. One of Never, PreemptLowerPriority. Defaults to PreemptLowerPriority if unset.
#### `overhead` (_[ResourceList](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#resourcelist-v1-core)_)

Overhead represents the resource overhead associated with running a pod for a given RuntimeClass. This field will be autopopulated at admission time by the RuntimeClass admission controller. If the RuntimeClass admission controller is enabled, overhead must not be set in Pod create requests. The RuntimeClass admission controller will reject Pod create requests which have the overhead already set. If RuntimeClass is configured and selected in the PodSpec, Overhead will be set to the value defined in the corresponding RuntimeClass, otherwise it will remain unset and treated as zero. More info: https://git.k8s.io/enhancements/keps/sig-node/688-pod-overhead/README.md
#### `topologySpreadConstraints` (_[TopologySpreadConstraint](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#topologyspreadconstraint-v1-core) array_)

TopologySpreadConstraints describes how a group of pods ought to spread across topology domains. Scheduler will schedule pods in a way which abides by the constraints. All topologySpreadConstraints are ANDed.
#### `setHostnameAsFQDN` (_boolean_)

If true the pod's hostname will be configured as the pod's FQDN, rather than the leaf name (the default). In Linux containers, this means setting the FQDN in the hostname field of the kernel (the nodename field of struct utsname). In Windows containers, this means setting the registry value of hostname for the registry key HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters to FQDN. If a pod does not have FQDN, this has no effect. Default to false.
#### `os` (_[PodOS](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#podos-v1-core)_)

Specifies the OS of the containers in the pod. Some pod and container fields are restricted if this is set. 
 If the OS field is set to linux, the following fields must be unset: -securityContext.windowsOptions 
 If the OS field is set to windows, following fields must be unset: - spec.hostPID - spec.hostIPC - spec.hostUsers - spec.securityContext.seLinuxOptions - spec.securityContext.seccompProfile - spec.securityContext.fsGroup - spec.securityContext.fsGroupChangePolicy - spec.securityContext.sysctls - spec.shareProcessNamespace - spec.securityContext.runAsUser - spec.securityContext.runAsGroup - spec.securityContext.supplementalGroups - spec.containers[*].securityContext.seLinuxOptions - spec.containers[*].securityContext.seccompProfile - spec.containers[*].securityContext.capabilities - spec.containers[*].securityContext.readOnlyRootFilesystem - spec.containers[*].securityContext.privileged - spec.containers[*].securityContext.allowPrivilegeEscalation - spec.containers[*].securityContext.procMount - spec.containers[*].securityContext.runAsUser - spec.containers[*].securityContext.runAsGroup
#### `hostUsers` (_boolean_)

Use the host's user namespace. Optional: Default to true. If set to true or not present, the pod will be run in the host user namespace, useful for when the pod needs a feature only available to the host user namespace, such as loading a kernel module with CAP_SYS_MODULE. When set to false, a new userns is created for the pod. Setting false is useful for mitigating container breakout vulnerabilities even allowing users to run their containers as root without actually having root privileges on the host. This field is alpha-level and is only honored by servers that enable the UserNamespacesSupport feature.
#### `schedulingGates` (_[PodSchedulingGate](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#podschedulinggate-v1-core) array_)

SchedulingGates is an opaque list of values that if specified will block scheduling the pod. More info:  https://git.k8s.io/enhancements/keps/sig-scheduling/3521-pod-scheduling-readiness. 
 This is an alpha-level feature enabled by PodSchedulingReadiness feature gate.
#### `resourceClaims` (_[PodResourceClaim](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#podresourceclaim-v1-core) array_)

ResourceClaims defines which ResourceClaims must be allocated and reserved before the Pod is allowed to start. The resources will be made available to those containers which consume them by name. 
 This is an alpha field and requires enabling the DynamicResourceAllocation feature gate. 
 This field is immutable.


### GoogleUnsealConfig



GoogleUnsealConfig holds the parameters for Google KMS based unsealing

_Appears in:_
- [UnsealConfig](#unsealconfig)

#### `kmsKeyRing` (_string_)


#### `kmsCryptoKey` (_string_)


#### `kmsLocation` (_string_)


#### `kmsProject` (_string_)


#### `storageBucket` (_string_)




### HSMUnsealConfig



HSMUnsealConfig holds the parameters for remote HSM based unsealing

_Appears in:_
- [UnsealConfig](#unsealconfig)

#### `daemon` (_boolean_)


#### `modulePath` (_string_)


#### `slotId` (_integer_)


#### `tokenLabel` (_string_)


#### `pin` (_string_)


#### `keyLabel` (_string_)




### Ingress



Ingress specification for the Vault cluster

_Appears in:_
- [VaultSpec](#vaultspec)

#### `annotations` (_object (keys:string, values:string)_)


#### `spec` (_[IngressSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#ingressspec-v1-networking)_)




### KubernetesUnsealConfig



KubernetesUnsealConfig holds the parameters for Kubernetes based unsealing

_Appears in:_
- [UnsealConfig](#unsealconfig)

#### `secretNamespace` (_string_)


#### `secretName` (_string_)




### Resources



Resources holds different container's ResourceRequirements

_Appears in:_
- [VaultSpec](#vaultspec)

#### `vault` (_[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#resourcerequirements-v1-core)_)


#### `bankVaults` (_[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#resourcerequirements-v1-core)_)


#### `hsmDaemon` (_[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#resourcerequirements-v1-core)_)


#### `prometheusExporter` (_[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#resourcerequirements-v1-core)_)


#### `fluentd` (_[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#resourcerequirements-v1-core)_)




### UnsealConfig



UnsealConfig represents the UnsealConfig field of a VaultSpec Kubernetes object

_Appears in:_
- [VaultSpec](#vaultspec)

#### `options` (_[UnsealOptions](#unsealoptions)_)


#### `kubernetes` (_[KubernetesUnsealConfig](#kubernetesunsealconfig)_)


#### `google` (_[GoogleUnsealConfig](#googleunsealconfig)_)


#### `alibaba` (_[AlibabaUnsealConfig](#alibabaunsealconfig)_)


#### `azure` (_[AzureUnsealConfig](#azureunsealconfig)_)


#### `aws` (_[AWSUnsealConfig](#awsunsealconfig)_)


#### `vault` (_[VaultUnsealConfig](#vaultunsealconfig)_)


#### `hsm` (_[HSMUnsealConfig](#hsmunsealconfig)_)




### UnsealOptions



UnsealOptions represents the common options to all unsealing backends

_Appears in:_
- [UnsealConfig](#unsealconfig)

#### `preFlightChecks` (_boolean_)


#### `storeRootToken` (_boolean_)


#### `secretThreshold` (_integer_)


#### `secretShares` (_integer_)




### Vault



Vault is the Schema for the vaults API

_Appears in:_
- [VaultList](#vaultlist)

<b> `apiVersion` _string_ </b><b> `vault.banzaicloud.com/v1alpha1`</b>

<b> `kind` _string_ </b><b> `Vault` </b>
#### `metadata` (_[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#objectmeta-v1-meta)_)

Refer to Kubernetes API documentation for fields of `metadata`.
#### `spec` (_[VaultSpec](#vaultspec)_)




### VaultList



VaultList contains a list of Vault



<b> `apiVersion` _string_ </b><b> `vault.banzaicloud.com/v1alpha1`</b>

<b> `kind` _string_ </b><b> `VaultList` </b>
#### `metadata` (_[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#listmeta-v1-meta)_)

Refer to Kubernetes API documentation for fields of `metadata`.
#### `items` (_[Vault](#vault) array_)




### VaultSpec



VaultSpec defines the desired state of Vault

_Appears in:_
- [Vault](#vault)

#### `size` (_integer_)

Size defines the number of Vault instances in the cluster (>= 1 means HA) default: 1
#### `image` (_string_)

Image specifies the Vault image to use for the Vault instances default: hashicorp/vault:latest
#### `bankVaultsImage` (_string_)

BankVaultsImage specifies the Bank Vaults image to use for Vault unsealing and configuration default: ghcr.io/bank-vaults/bank-vaults:latest
#### `bankVaultsVolumeMounts` (_[VolumeMount](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#volumemount-v1-core) array_)

BankVaultsVolumeMounts define some extra Kubernetes Volume mounts for the Bank Vaults Sidecar container. default:
#### `statsdDisabled` (_boolean_)

StatsDDisabled specifies if StatsD based metrics should be disabled default: false
#### `statsdImage` (_string_)

StatsDImage specifices the StatsD image to use for Vault metrics exportation default: prom/statsd-exporter:latest
#### `statsdConfig` (_string_)

StatsdConfig specifices the StatsD mapping configuration default:
#### `fluentdEnabled` (_boolean_)

FluentDEnabled specifies if FluentD based log exportation should be enabled default: false
#### `fluentdImage` (_string_)

FluentDImage specifices the FluentD image to use for Vault log exportation default: fluent/fluentd:edge
#### `fluentdConfLocation` (_string_)

FluentDConfLocation is the location of the fluent.conf file default: "/fluentd/etc"
#### `fluentdConfFile` (_string_)

FluentDConfFile specifices the FluentD configuration file name to use for Vault log exportation default:
#### `fluentdConfig` (_string_)

FluentDConfig specifices the FluentD configuration to use for Vault log exportation default:
#### `watchedSecretsLabels` (_object array_)

WatchedSecretsLabels specifices a set of Kubernetes label selectors which select Secrets to watch. If these Secrets change the Vault cluster gets restarted. For example a Secret that Cert-Manager is managing a public Certificate for Vault using let's Encrypt. default:
#### `watchedSecretsAnnotations` (_object array_)

WatchedSecretsAnnotations specifices a set of Kubernetes annotations selectors which select Secrets to watch. If these Secrets change the Vault cluster gets restarted. For example a Secret that Cert-Manager is managing a public Certificate for Vault using let's Encrypt. default:
#### `annotations` (_object (keys:string, values:string)_)

Annotations define a set of common Kubernetes annotations that will be added to all operator managed resources. default:
#### `vaultAnnotations` (_object (keys:string, values:string)_)

VaultAnnotations define a set of Kubernetes annotations that will be added to all Vault Pods. default:
#### `vaultLabels` (_object (keys:string, values:string)_)

VaultLabels define a set of Kubernetes labels that will be added to all Vault Pods. default:
#### `vaultPodSpec` (_[EmbeddedPodSpec](#embeddedpodspec)_)

VaultPodSpec is a Kubernetes Pod specification snippet (`spec:` block) that will be merged into the operator generated Vault Pod specification. default:
#### `vaultContainerSpec` (_[Container](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#container-v1-core)_)

VaultContainerSpec is a Kubernetes Container specification snippet that will be merged into the operator generated Vault Container specification. default:
#### `vaultConfigurerAnnotations` (_object (keys:string, values:string)_)

VaultConfigurerAnnotations define a set of Kubernetes annotations that will be added to the Vault Configurer Pod. default:
#### `vaultConfigurerLabels` (_object (keys:string, values:string)_)

VaultConfigurerLabels define a set of Kubernetes labels that will be added to all Vault Configurer Pod. default:
#### `vaultConfigurerPodSpec` (_[EmbeddedPodSpec](#embeddedpodspec)_)

VaultConfigurerPodSpec is a Kubernetes Pod specification snippet (`spec:` block) that will be merged into the operator generated Vault Configurer Pod specification. default:
#### `config` (_[JSON](#json)_)

Config is the Vault Server configuration. See https://www.vaultproject.io/docs/configuration/ for more details. default:
#### `externalConfig` (_[JSON](#json)_)

ExternalConfig is higher level configuration block which instructs the Bank Vaults Configurer to configure Vault through its API, thus allows setting up: - Secret Engines - Auth Methods - Audit Devices - Plugin Backends - Policies - Startup Secrets (Bank Vaults feature)

#### `unsealConfig` (_[UnsealConfig](#unsealconfig)_)

UnsealConfig defines where the Vault cluster's unseal keys and root token should be stored after initialization. See the type's documentation for more details. Only one method may be specified. default: Kubernetes Secret based unsealing
#### `credentialsConfig` (_[CredentialsConfig](#credentialsconfig)_)

CredentialsConfig defines a external Secret for Vault and how it should be mounted to the Vault Pod for example accessing Cloud resources. default:
#### `envsConfig` (_[EnvVar](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#envvar-v1-core) array_)

EnvsConfig is a list of Kubernetes environment variable definitions that will be passed to all Bank-Vaults pods. default:
#### `securityContext` (_[PodSecurityContext](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#podsecuritycontext-v1-core)_)

SecurityContext is a Kubernetes PodSecurityContext that will be applied to all Pods created by the operator. default:
#### `serviceType` (_string_)

ServiceType is a Kubernetes Service type of the Vault Service. default: ClusterIP
#### `loadBalancerIP` (_string_)

LoadBalancerIP is an optional setting for allocating a specific address for the entry service object of type LoadBalancer default: ""
#### `serviceRegistrationEnabled` (_boolean_)

serviceRegistrationEnabled enables the injection of the service_registration Vault stanza. This requires elaborated RBAC privileges for updating Pod labels for the Vault Pod. default: false
#### `raftLeaderAddress` (_string_)

RaftLeaderAddress defines the leader address of the raft cluster in multi-cluster deployments. (In single cluster (namespace) deployments it is automatically detected). "self" is a special value which means that this instance should be the bootstrap leader instance. default: ""
#### `servicePorts` (_object (keys:string, values:integer)_)

ServicePorts is an extra map of ports that should be exposed by the Vault Service. default:
#### `affinity` (_[Affinity](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#affinity-v1-core)_)

Affinity is a group of affinity scheduling rules applied to all Vault Pods. default:
#### `podAntiAffinity` (_string_)

PodAntiAffinity is the TopologyKey in the Vault Pod's PodAntiAffinity. No PodAntiAffinity is used if empty. Deprecated. Use Affinity. default:
#### `nodeAffinity` (_[NodeAffinity](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#nodeaffinity-v1-core)_)

NodeAffinity is Kubernetees NodeAffinity definition that should be applied to all Vault Pods. Deprecated. Use Affinity. default:
#### `nodeSelector` (_object (keys:string, values:string)_)

NodeSelector is Kubernetees NodeSelector definition that should be applied to all Vault Pods. default:
#### `tolerations` (_[Toleration](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#toleration-v1-core) array_)

Tolerations is Kubernetes Tolerations definition that should be applied to all Vault Pods. default:
#### `serviceAccount` (_string_)

ServiceAccount is Kubernetes ServiceAccount in which the Vault Pods should be running in. default: default
#### `volumes` (_[Volume](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#volume-v1-core) array_)

Volumes define some extra Kubernetes Volumes for the Vault Pods. default:
#### `volumeMounts` (_[VolumeMount](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#volumemount-v1-core) array_)

VolumeMounts define some extra Kubernetes Volume mounts for the Vault Pods. default:
#### `volumeClaimTemplates` (_[EmbeddedPersistentVolumeClaim](#embeddedpersistentvolumeclaim) array_)

VolumeClaimTemplates define some extra Kubernetes PersistentVolumeClaim templates for the Vault Statefulset. default:
#### `vaultEnvsConfig` (_[EnvVar](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#envvar-v1-core) array_)

VaultEnvsConfig is a list of Kubernetes environment variable definitions that will be passed to the Vault container. default:
#### `sidecarEnvsConfig` (_[EnvVar](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#envvar-v1-core) array_)

SidecarEnvsConfig is a list of Kubernetes environment variable definitions that will be passed to Vault sidecar containers. default:
#### `resources` (_[Resources](#resources)_)

Resources defines the resource limits for all the resources created by the operator. See the type for more details. default:
#### `ingress` (_[Ingress](#ingress)_)

Ingress, if it is specified the operator will create an Ingress resource for the Vault Service and will annotate it with the correct Ingress annotations specific to the TLS settings in the configuration. See the type for more details. default:
#### `serviceMonitorEnabled` (_boolean_)

ServiceMonitorEnabled enables the creation of Prometheus Operator specific ServiceMonitor for Vault. default: false
#### `existingTlsSecretName` (_string_)

ExistingTLSSecretName is name of the secret that contains a TLS server certificate and key and the corresponding CA certificate. Required secret format kubernetes.io/tls type secret keys + ca.crt key If it is set, generating certificate will be disabled default: ""
#### `tlsExpiryThreshold` (_string_)

TLSExpiryThreshold is the Vault TLS certificate expiration threshold in Go's Duration format. default: 168h
#### `tlsAdditionalHosts` (_string array_)

TLSAdditionalHosts is a list of additional hostnames or IP addresses to add to the SAN on the automatically generated TLS certificate. default:
#### `caNamespaces` (_string array_)

CANamespaces define a list of namespaces where the generated CA certificate for Vault should be distributed, use ["*"] for all namespaces. default:
#### `istioEnabled` (_boolean_)

IstioEnabled describes if the cluster has a Istio running and enabled. default: false
#### `veleroEnabled` (_boolean_)

VeleroEnabled describes if the cluster has a Velero running and enabled. default: false
#### `veleroFsfreezeImage` (_string_)

VeleroFsfreezeImage specifices the Velero Fsrfeeze image to use in Velero backup hooks default: velero/fsfreeze-pause:latest
#### `vaultContainers` (_[Container](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#container-v1-core) array_)

VaultContainers add extra containers
#### `vaultInitContainers` (_[Container](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#container-v1-core) array_)

VaultInitContainers add extra initContainers




### VaultUnsealConfig



VaultUnsealConfig holds the parameters for remote Vault based unsealing

_Appears in:_
- [UnsealConfig](#unsealconfig)

#### `address` (_string_)


#### `unsealKeysPath` (_string_)


#### `role` (_string_)


#### `authPath` (_string_)


#### `tokenPath` (_string_)


#### `token` (_string_)




