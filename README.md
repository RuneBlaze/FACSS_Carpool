UNC Carpool
=================
Carpool System used Internally in FACSS, UNC Chapel Hill

# A Note on Security

This software was made with the basic level of security. I believe no common database
attacks can occur to this software. Yet it is highly possible you can break the system
somehow deliberately. I feel this is somewhat unnecessary, but if you ever were to attempt
to break the system, please be reminded that you probably have something more useful to do
than letting another student working overnight fixing the mess.

防君子不防小人的安全系统，黑客精神固然可贵，但是我也身为维护人希望可能的攻击者别专门制造麻烦。

# Setup

Ruby Required

Install Padrino before dev

See app/views/ for the slim template files


```
bundler install
padrino s
```

# Deployment

This app is currently hosted in the UNC Chapel Hill Openshift platform. You can host it
anywhere where ruby deployment is supported.


# License

MIT License
