# ps2partnerlink

Script Power-Shell to link tennats with Partner MPN ID

The partner ID is the [Microsoft Cloud Partner Program ID](https://partner.microsoft.com/) for your organization. Be sure to use the Associated Partner ID shown on your partner profile.

*Challenge accepted in August 25th 2023. #Marcos Paulo Falcirolli

# Schema:

## Input:

MPN ID: [partner MPN ID]

 
## Output

```
{tenants:
	{tenant 1 name: xxx,
	PAL: "PAL status" ***(new registration/already registered/other MPN ID)
	list of subscriptions:	{(subscription 1 name; subscription ID; user permissions),
			(subscription 2 name; subscription ID; user permissions)....}
	},
	{tenant N name: xxx,
	PAL: "PAL status" ***(new registration/already registered/new review, other MPN ID)
	list of subscriptions:	{(subscription 1 name; subscription ID; user permissions),
			(subscription 2 name; subscription ID; user permissions)....}
	}
}
```

# Documentation

[Microsoft Official Documentation](https://learn.microsoft.com/en-us/azure/cost-management-billing/manage/link-partner-id)