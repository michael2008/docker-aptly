
https://github.com/osism/docker-aptly
здесь для чего-то используется lsb-release и несколько фич

0a57ebd7e8b3072764b485c8ac4f96561f67be3d Add a note about missing entropy for gpg
5f9cb63344c3142845ea0ffaae6bb4a30b48e89b Insatll lsb-release, required by aptly mirror create ppa
3b1e8a8470b3b9eb9bb66c70ab5d3cc9fb998506 As a workaround import the gpg key from registry.osism.io
86c2eac7861d537afadd30dfefa2c924a856acd6 Update bash completion url

https://github.com/lnls-sirius/docker-aptly
а здесь репа epics и специальный скрипт для ее обновления

566cf486048ec82ee4fbc61da2042fb7a085920b Dockerfile.epics: add docker for NSLS-II epics repo
d834a46c3cb1e08b47aad9cdb9c1421d09e4e17a assets: add mirror NSLS-II EPICS repo
89c3b872a6f046e562480ac292fa56b1d5a51c1d assets/*/update_mirror_epics.sh: fix duplicate repository names
288f7c41d5b3bf0a09a62cb3dbf3119455ad4595 assets/*/update_mirror_debian.sh: fix duplicate repository names
e448d6fcfd4f48e8e050e36409a6a7da4e04c798 assets/*/update_mirror_epics.sh: fix EPICS repo name
062c49b9c53ca578f0938d806f713344f30d6fe5 assets/*/update_mirror_epics.sh: fix using only main category as contrib is broken


8e90edd151d872ff18a3a676bc2161a1f10ebda6 nginx conf: Increase hash bucket size to allow multiple server names

## Ideas

Мб сделать докер compose?? Тогда описать зачем нужен nginx, нацти эту инфу в аптли
Может тоже удалить nginx? и использовать exec sleep infinity + aptly serve (написать ишью, спросить Андрея Смирнова)?

Вот как это было сделано в какой-то репе:

```
ADD aptly.conf /etc/aptly.conf
VOLUME ["/aptly"]
VOLUME ["/etc/apt"]
VOLUME ["/root"]
EXPOSE 8080
CMD ["/usr/bin/aptly", "api", "serve", "-no-lock"]
```