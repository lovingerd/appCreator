naming conventions:

TL;DR
Use hyphens `-` for all but nomad/narwhal (nomad naming conventions requires `camelCase`)

___
* SYSLOG: 
  * appname: `hyphen` vs  vs `lowercase` vs `snake case`

`hyphen` ✅

        <appName>ac-teamio</appName>
        <appName>tmp-file-storage</appName>
        <appName>pdjd-views-daemon</appName>
        <appName>pdjd-views</appName>
        <appName>intercom-sync</appName>
        <appName>subscription-audit</appName>
        <appName>teamio-stats</appName>
        <appName>ei-export</appName>
        <appName>advert-model</appName>
        <appName>file-converter-${FILE_CONVERTER_ROLE}</appName>

`lowercase`

        <appName>companysettings</appName>
        <appName>companycore</appName>
        <appName>crmsender</appName>
        <appName>aden2</appName>

`snake case`

        <appName>business_log</appName>
___
* Graylog
  * use spring app name -> `<additionalFields>application=${spring.application.name},NOMAD_ALLOC_INDEX=${NOMAD_ALLOC_INDEX}</additionalFields>` 

`lowercase`

        <additionalFields>application=aden2</additionalFields>
        <additionalFields>application=anoncand,NOMAD_ALLOC_INDEX=${NOMAD_ALLOC_INDEX}</additionalFields>
        <additionalFields>application=asmtmgmt,NOMAD_ALLOC_INDEX=${NOMAD_ALLOC_INDEX}</additionalFields>
        <additionalFields>application=crmsender</additionalFields>
        <additionalFields>application=companysettings</additionalFields>
        
        
`hyphen` ✅

        <additionalFields>application=cv-parser,NOMAD_ALLOC_INDEX=${NOMAD_ALLOC_INDEX}</additionalFields>
        <additionalFields>application=import-log</additionalFields>
        <additionalFields>application=intercom-sync</additionalFields>
        <additionalFields>application=business-log,NOMAD_ALLOC_INDEX=${NOMAD_ALLOC_INDEX}</additionalFields>
        <additionalFields>application=ac-teamio</additionalFields>
        <additionalFields>application=advert-model</additionalFields>
        <additionalFields>application=ei-export</additionalFields>
        <additionalFields>application=tmp-file-storage</additionalFields>
        <additionalFields>application=file-converter-${FILE_CONVERTER_ROLE},NOMAD_ALLOC_INDEX=${NOMAD_ALLOC_INDEX}</additionalFields>

`mix` - camelCase and hyphen

        <additionalFields>application=pdjdViews-daemon-log,NOMAD_ALLOC_INDEX=${NOMAD_ALLOC_INDEX}</additionalFields>
        <additionalFields>application=pdjdViews-log,NOMAD_ALLOC_INDEX=${NOMAD_ALLOC_INDEX}</additionalFields>
___
* spring.application.name

`lowercase`

        spring.application.name=anoncand
        spring.application.name=businesslog
        spring.application.name=crmsender
        spring.application.name=responsesource

`hyphen` ✅

        spring.application.name=ei-export
        spring.application.name=company-core
        spring.application.name=teamio-stats
___
* narwhal/nomad https://nomad.infra.cprodttc/nomad/prod/jobs 
  * artifact name: `camelCase`
    * translates to Nomad job name 
  * e.g. `teamio-companyCore-common`
___
* docker name : `hyphen` ✅
  * e.g. `company-settings` 
___
* package name
  * `com.almamedia.companysettings`  ✅
  * `com.almamedia.company.settings` ?
  * `com.almamedia.company-settings` -> invalid
  * `com.almamedia.company_settings` -> ugly af
___
* repository name: `hyphen` ✅ vs `camelCase`
  * https://bitbucket.lmc.cz/projects/REC/ hyphens mostly
  * https://github.com/almacareer?q=teamio&type=all&language=&sort= hyphens only


___

