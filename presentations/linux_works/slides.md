---
theme: default
background: "#0e1419"
title: Linux-arbeidsstasjoner i et Microsoft-miljø
info: |
  En balansert vurdering for utviklerteam.
  Konteksten: containeriserte .NET- og React-applikasjoner med AWS- og GCP-deploy,
  i en organisasjon som ellers lever i Microsoft 365 og Entra ID.
class: text-center
highlighter: shiki
lineNumbers: false
drawings:
  persist: false
transition: slide-left
mdc: true
fonts:
  sans: "Inter"
  mono: "JetBrains Mono"
colorSchema: dark
---

# Linux-arbeidsstasjoner

## i et Microsoft-basert miljø

En balansert vurdering for utviklerteam

![tux](./250px-Tux.svg.webp)


<!--
Velkommen. Dette er en kort gjennomgang av fordeler og ulemper ved å bruke
Linux-arbeidsstasjoner i et miljø som ellers er bygget rundt Microsoft 365,
Entra ID og OneDrive.

Konteksten: utviklerne jobber med containeriserte .NET- og React-applikasjoner
som deployes til AWS og GCP. Resten av organisasjonen lever i Microsoft-stacken.

Målet er ikke å konkludere for eller mot, men å gi et tydelig bilde av hva som
vinnes og hva som koster.
-->

---
layout: default
---

# Konteksten

- Backend: **.NET** i containere
- Frontend: **React**
- Sky: **AWS og GCP**
- Administrasjon: **M365, Entra ID, OneDrive**

<!--
Kort om hvorfor dette spørsmålet i det hele tatt er relevant.

Utviklingsstacken er fundamentalt Linux-orientert: containerne kjører Linux i
produksjon, .NET er plattformuavhengig, og React-verktøyene (Node, npm, Vite)
er førsteklasses på Linux.

Skyen vår er AWS og GCP. Begge er Linux-native, og verktøyene — aws CLI,
gcloud, kubectl, terraform — er førsteklasses på Linux og macOS, med Windows
som ettertanke.

Samtidig er administrasjonslaget — identitet, e-post, dokumenter, samarbeid —
dypt integrert i Microsoft-økosystemet. Det er denne spenningen vi navigerer.
-->

---
layout: default
---

# Fordeler

- **Dev/prod-paritet** uten WSL2
- **Raskere** container-bygg og filsystem
- **Ingen Windows-lisens** per maskin
- Bedre **automatisering og tilpasning**

<!--
Fire hovedpunkter på fordelssiden.

Dev/prod-paritet: produksjonscontainerne er Linux. Når utvikleren også kjører
Linux, forsvinner et helt lag med oversettelse og rare feil som bare oppstår
på Windows.

Ytelse: filsystemoperasjoner med mange små filer (node_modules, .NET-bygg) er
målbart raskere. Ingen obligatorisk antivirusskanning av hver fil.

Kostnad: Windows-lisens spares per arbeidsstasjon. Verktøyene utviklerne bruker
— VS Code, Rider, Git — er gratis og fungerer like bra eller bedre.

Automatisering: dotfiles, pakkebehandlere, devcontainers, Ansible.
Reproduserbare utviklermiljøer er enklere å bygge på Linux.
-->

---
layout: default
---

# Ulemper

- **Intune** krever mer konfigurasjonsarbeid
- **Ingen offisiell OneDrive-klient**
- **Office og Teams** kun i nettleser
- **Parallell IT-støtte** kreves

<!--
Ulempene er administrative, ikke tekniske.

Intune på Linux: enhetsadministrasjon fungerer på Ubuntu og RHEL, men er
smalere enn på Windows. Compliance baseres i stor grad på custom shell-scripts
vi skriver selv, ikke på ferdige policy-templates. Det er mer arbeid å sette
opp, men dekkende når det er gjort.

OneDrive: ingen offisiell klient. Alternativene er nettleseren, uoffisielle
klienter som abraunegg/onedrive, eller rclone. Ingen Files On-Demand. For
utviklere som lagrer kode i Git og ikke jobber i OneDrive-mapper er dette
mindre kritisk enn det høres ut.

Office og Teams: native klienter finnes ikke. Teams Linux-klienten ble
avviklet i 2022. Webversjonene fungerer; Teams som PWA fra Edge oppfører seg
som en native app. Mister presisjon på komplekse Word/Excel-dokumenter, men
utviklere lager sjelden slike.

IT-støtte: separate herdingsbaselinjer, separat patching, separat
endepunktsdeteksjon. Defender for Endpoint støtter Linux, det hjelper, men det
er fortsatt et parallelt løp.
-->

---
layout: default
---

# Risikomomenter

- Samsvar (**ISO 27001, NIS2**) krever mer arbeid
- Maskinvare-edge-cases: VPN, fingeravtrykk
- Få Linux-brukere → **selvsupport-felle**

<!--
Tre risikomomenter som ofte undervurderes.

Samsvar: hvis organisasjonen har ISO 27001, SOC 2, NIS2 eller sektorspesifikke
krav, må endepunktskontroller på Linux dokumenteres på en annen måte. Det er
ikke umulig, men bevisinnsamlingen er mindre nøkkelferdig.

Maskinvare: bedrifts-VPN-klienter (særlig eldre, proprietære),
fingeravtrykklesere, leverandørspesifikke dokkingstasjoner kan være ujevne.
Alltid verifiser mot konkret maskinvarestandard før bredere utrulling.

Selvsupport-fellen: hvis bare tre-fire utviklere kjører Linux, ender de ofte
opp som sin egen support. Det fungerer fint helt til noe ryker — og da er det
ingen runbook.
-->

---
layout: default
---

# Identitet og sky-tilgang

- **AWS** via IAM Identity Center føderert til Entra
- **GCP** via Workforce Identity Federation til Entra
- Pålogging skjer i **Edge med broker** → CA håndhever
- Compliant device-claim leveres på Linux

<!--
Dette er den underbelyste delen av historien.

Når sky-tilgang fødereres gjennom Entra ID, blir Entra det reelle
hovedinngangspunktet til alt — M365, AWS-konsollen, GCP-konsollen, alle
CLI-verktøyene. Brukeren logger inn én gang via Entra, og får tilgang til alt.

På Linux fungerer dette i praksis slik: aws sso login eller gcloud auth login
åpner Edge, brukeren autentiserer mot Entra, microsoft-identity-broker
leverer device-compliance-claim i tokenet, og Conditional Access-policyen som
krever compliant device blir tilfredsstilt. Det er ikke noe Linux-spesifikt
hull her — det fungerer like godt som på Windows eller Mac for dette formålet.

Sign-in frequency på 4 timer + matchede session-levetider i AWS Identity
Center og GCP workforce pool sørger for jevnlig re-evaluering. En kompromittert
Linux-maskin mister sky-tilgang innen fire timer selv om angriperen stjeler
lokale tokens.

Dette betyr at sikkerhetsteamet faktisk får mer enhetlig håndhevelse på tvers
av brukere og enheter enn de hadde med direkte AWS/GCP-credentials, uansett
operativsystem.
-->

---
layout: default
---

# Et pragmatisk mønster

- **Linux** for utviklere som vil
- **Windows** som standard ellers
- **Office og Teams** på nett
- Sikkerhet godkjenner **føderasjonsmodellen**

<!--
Dette er det vanligste fungerende oppsettet i organisasjoner som ligner på vår.

Linux tillates for utviklere som ber om det — ikke pålegges, ikke forbys.
Windows forblir standardvalget for alle andre.

Linux-gruppen aksepterer at de bruker Office på nett og Teams i nettleseren.
For utviklere som lager dokumenter sjelden er dette en akseptabel kostnad.

Den kritiske avhengigheten er at sikkerhets- og samsvarsteamet godkjenner
føderasjonsmodellen: Intune-enrollment med custom compliance-policyer,
Defender for Endpoint på Linux, full diskkryptering med LUKS, og Conditional
Access som håndhever device compliance på all sky-pålogging via
Edge-brokeren. Sign-in frequency-kontroller holder sesjonene korte.

Dette er ikke et "hull som må aksepteres" — det er en arkitektur som leverer
sammenlignbar håndhevelse til Windows for de sky-flytene som faktisk betyr noe.
-->

---
layout: center
class: text-center
---

# Konklusjon

Linux er en **sterk teknisk match** for stacken vår.

Identitet og compliance **fungerer** via Entra-føderasjon.

Friksjonen er **operativ støtte**, ikke håndhevelse.

<!--
Oppsummert i tre setninger.

Teknisk er saken klar: utviklere blir målbart mer produktive på Linux når
stacken er containerisert .NET og React med sky-deploy til AWS og GCP.
Dev/prod-paritet, raskere bygg, bedre verktøy.

Identitet og compliance er ikke lenger et "hull": Intune-enrollment på Linux,
custom compliance-scripts, Defender for Endpoint, og CA-håndhevelse via
Edge-brokeren på alle Entra-fødererte applikasjoner — inkludert AWS Identity
Center og GCP Workforce Federation — gir oss sammenlignbar håndhevelse til
Windows for de flytene som betyr mest.

Den gjenværende friksjonen er operativ støtte: at IT klarer å vedlikeholde
Linux som en støttet plattform parallelt med Windows. Det er en investering,
men en kjent og kontrollerbar sådan.

Beslutningen handler nå om kapasitet og prioritering, ikke om
sikkerhetskompromisser.

Takk. Spørsmål?
-->
