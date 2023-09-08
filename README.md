# Linking Tenants without a Partner MPN ID

The partner ID is the [Microsoft Cloud Partner Program ID](https://partner.microsoft.com/) for your organization. Be sure to use the Associated Partner ID shown on your partner profile.

<i>*Challenge proposed on August 25th 2023. #Marcos Paulo Falcirolli</i>

# Schema:

## Input:

```
MPN ID: [Partner MPN ID]
Tenant: [Tenant ID]
```

## Output

```
	{
		Tenant: xxxx-xxxx-xxxx-xxxx - xxx,
		PAL: Registered|Already registered, update,
		Subscriptions:	{
			(subscription: yyy, ID: xxxxx-xxxx-xxxx-xxxx, Owner: true|false, Contributor: true|false, Reader: true|false),
			(subscription: yyy, ID: xxxxx-xxxx-xxxx-xxxx, Owner: true|false, Contributor: true|false, Reader: true|false)
			...
			}
	}
```

# Documentation

[Microsoft Official Documentation](https://learn.microsoft.com/en-us/azure/cost-management-billing/manage/link-partner-id)

[Management Partner](https://learn.microsoft.com/en-us/powershell/module/az.managementpartner/?view=azps-10.2.0#management-partner)