.. _changelog:


Change Log
==========

Gem changes until version 2.0.1, in descending order.

Version 2.7.0
-------------
Released on Feb 06, 2017
- Social login now uses the Client API for authentication (Social login v2)
- Automatically initialize base href from application href (after this version you don't have to set the basePath explicitly in the stormpath.yml)
- Code refactoring


Version 2.6.0
-------------
Released on Jan 24, 2017
- Add ID site redirection for the /forgot endpoint
- Implement ID site verification - the gem will now throw an error if IDSite isn't properly configured


Version 2.5.1
-------------
Released on Jan 19, 2017
- Fix bug with callback uri not being set properly on IDSite logout
- Rewrite the IDSite authentication workflow


Version 2.5.0
-------------
Released on Jan 09, 2017
- Implement Multi-tenancy


Version 2.4.0
-------------
Released on Dec 16, 2016
- Fix error with setting custom base path during client initialization


Version 2.3.1
-------------
Released on Nov 28, 2016
- Refactored specs and changed environment variable names to match the other SDK's


Version 2.3.0
-------------
Released on Nov 08, 2016
- Add sphinx documentation
- Fix bug when autoLogin and email verification are both enabled


Version 2.2.0
-------------
Released on Nov 07, 2016

- Implement Authentication with Social Providers (Facebook, Google, Linkedin, Github)

Version 2.1.0
-------------
Released on Nov 02, 2016

- Create script for generating a rake task responsible for transferring users from devise to Stormpath
- Implement ID Site Authentication

Version 2.0.2
-------------
Released on Aug 29, 2016

- Render path links depending on the configuration
- Use Faker to generate random test data
- Rename all user instances to account

Version 2.0.1
-------------
Released on Aug 22, 2016

- Fix error when showing new_register_path on login page when register is disabled.
