gwt-contacts
============

[![Build Status](https://secure.travis-ci.org/realityforge/gwt-contacts.png?branch=master)](http://travis-ci.org/realityforge/gwt-contacts)

NOTE: The way we develop GWT apps has changed since this application was developed.

This is the gwt "contacts" tutorial application from google. The following
enhancements have been made;

* Upgrade to use the JDK logging emulation layer
* Integrate "GWT RPC XSRF protection" to avoid Cross-Site Request Forgery
* Use Google Gin as the client-side dependency injection framework
* Converted to use the Activities & Places Framework for managing bookmarking
  inside the application, and to enable easy code splitting.
* Split into multiple code modules (server, client and shared) to help in
  modularizing the code base.
* Integration of checkstyle rules to help enforce good styles.
* Conversion of the server-side to use EJBs for the service layer and JPA for
  the persistence layer.
* Convert to using Domgen to generate service/event/entity boilerplate.
* Conversion to using a maven-style source code layout and the Buildr tool to
  automate the builds.
* Integration with the Intellij IDEA IDE added.

Getting Started
---------------

* Download the right version of ruby.

* Install the ruby dependencies. (i.e. "gem install bundler && bundler install")

* Download dependencies and source for dependencies. Note: It is important
  to download source as the GWT compiler actually uses the source from
  dependencies to generate javascript. e.g. "buildr artifacts artifacts:sources"

* Install the GWT and GlassFish Integration plugins into IDEA

* Generate IDEA project files. e.g. "buildr idea"

* Download and install GlassFish 3.1.2.2 or later.

* Setup GlassFish configuration in IDEA and make sure it deploys the contacts
  artifact when it starts up.

* Learn and perform magic.
