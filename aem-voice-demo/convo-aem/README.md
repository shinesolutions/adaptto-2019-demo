Convo AEM
---------

Convo AEM is a [Convo](https://github.com/cliffano/convo-aem) agent and middleware for [aem](https://www.adobe.com/au/marketing/experience-manager.html).

The middleware will be deployed to [GCP Cloud Functions](https://cloud.google.com/functions/), the agent needs to be imported into [Dialogflow agent](https://dialogflow.com/docs/agents). They will then be integrated with AEM, voice devices and/or messaging applications.

[![Architecture Diagram](https://raw.github.com/cliffano/convo-aem/master/docs/architecture.jpg)](https://raw.github.com/cliffano/convo-aem/master/docs/architecture.jpg)

Install
-------

Install required tools:

    make tools

Install dependencies:

    make deps

Usage
-----

1. [Create a CloudFunctions project](https://cloud.google.com/functions/docs/quickstart-console)
2. [Create a Dialogflow project](https://developers.google.com/actions/dialogflow/project-agent)
3. Set Convo AEM environment configuration
4. Generate Convo AEM agent and middleware using command `make gen`
5. Deploy Convo AEM middleware using command `make deploy`
6. Because aem agent deployment hasn't been automated, manually import `stage/convo-aem-dialogflow-agent.zip` to your Dialogflow project
7. Integrate your Dialogflow project with any device/application you have
8. Talk to aem

Configuration
-------------

Modify environment configuration file at `conf/env.yaml` to suit your environment.

| Property | Description |
|----------|-------------|
| convo.token | Token used for linking the Dialogflow agent with the CloudFunctions middleware |
| cloudfunctions.url | The URL of your GCP CloudFunctions project |
| openapi.url | aem URL |
| openapi.username | Username of a the aem user you'd like to use as service account |
| openapi.password | Password of the above aem user |
