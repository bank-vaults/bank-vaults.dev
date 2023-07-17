---
title: Bank-Vaults
---

{{< blocks/cover title="Welcome to Bank-Vaults!" image_anchor="top" width="min" color="gray" >}}
<div class="mx-auto">
	<a class="btn btn-lg btn-primary mr-3 mb-4" href="{{< relref "/docs/" >}}">
		Learn More <i class="fa-solid fa-circle-right ml-2"></i>
	</a>
	<a class="btn btn-lg btn-secondary mr-3 mb-4" href="/docs/installing/">
		Install <i class="fa-brands fa-github ml-2 "></i>
	</a>
	<p class="lead mt-5">An easy way to using and operating Hashicorp Vault on Kubernetes</p>
</div>
{{< /blocks/cover >}}

{{% blocks/lead color="primary" %}}
<div class="main-lead">
Bank-Vaults provides tools that make using and operating Hashicorp Vault easier. It's a wrapper for the official Vault client with automatic token renewal and built-in Kubernetes support, dynamic database credential provider for Golang database/sql based clients. It has a CLI tool to automatically initialize, unseal, and configure Vault. It also provides a Kubernetes operator for provisioning, and a mutating webhook for injecting secrets.
</div>
{{% /blocks/lead %}}

{{< blocks/section color="dark" type="features">}}
{{% blocks/feature icon="fa-lightbulb" title="Learn more about Bank-Vaults!" url="/docs/" %}}
Read the Bank-Vaults documentation.
{{% /blocks/feature %}}


{{% blocks/feature icon="fa-brands fa-github" title="Contributions welcome!" url="https://github.com/bank-vaults/bank-vaults" %}}
We do a [Pull Request](https://github.com/bank-vaults/bank-vaults/pulls) contributions workflow on **GitHub**. New users and developers are always welcome!
{{% /blocks/feature %}}


{{% blocks/feature icon="fa-brands fa-slack" title="Come chat with us!" url="https://join.slack.com/t/emergingtechcommunity/shared_invite/zt-1rw2jl0ht-yNdyFgBFlc%7Eyzo9AnE4FbA" url_text="Join Slack" %}}
In case you need help, you can find us in our Slack channel.
{{% /blocks/feature %}}

{{< /blocks/section >}}
