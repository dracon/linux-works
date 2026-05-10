---
theme: default
title: Linux-arbeidsstasjoner i et Microsoft-miljø
info: |
  ## Linux-arbeidsstasjoner i et Microsoft-basert miljø
  En balansert vurdering for utviklerteam
colorSchema: dark
class: text-left
transition: slide-left
mdc: true
fonts:
  sans: "Inter, -apple-system, BlinkMacSystemFont, Segoe UI, sans-serif"
---

<style>
:root {
  --slidev-theme-primary: #4a9eb8;
}
.slidev-layout {
  background: #0e1419;
  color: #e6e6e6;
}
.slidev-layout h1,
.slidev-layout h2 {
  color: #4a9eb8 !important;
  font-weight: 600;
}
.slidev-layout h3 {
  color: #6bb6cc !important;
}
.slidev-layout strong {
  color: #ffffff;
}
.slidev-layout code {
  background: #1a2330;
  color: #b8d4e0;
  padding: 2px 6px;
  border-radius: 3px;
}
.slidev-layout a {
  color: #6bb6cc;
}
</style>

# Linux-arbeidsstasjoner

## i et Microsoft-basert miljø

En balansert vurdering for utviklerteam

<!--
Velkommen. Dette er en kort gjennomgang av fordeler og ulemper ved å bruke Linux-arbeidsstasjoner i et miljø som ellers er bygget rundt Microsoft 365, Entra ID og OneDrive.

Konteksten: utviklerne jobber med containeriserte .NET- og React-applikasjoner. Resten av organisasjonen lever i Microsoft-stacken.

Målet er ikke å konkludere for eller mot, men å gi et tydelig bilde av hva som vinnes og hva som koster.

-->

---
layout: center
---

<style>
.highlight-red {
  color: #ff6b6b; /* En fin, mild rød */
}
</style>

  <div class="text-7xl font-bold highlight-red">
    Linux-bias
  </div>

- Utviklere jobber mye med verktøy som fungerer best på Linux
- Det er mye som er gratis i Linux-verdenen, som vi betaler for i dag. f.eks microsoft 365
- Føler det er en fordel for oss at vi ikke er like avhengige av Microsoft som resten av bedriften.


  <div class="text-4xl translate-y-7">
    Fordommer?
  </div>

<!--
Jeg personlig er ganske bias når det gjelder Linux, men det betyr ikke at det er det rette verktøyet for alle på utvikling til å utføre jobben.

Mange er vant til Windows-baserte verktøy som Powershell, gitbash VSCode og andre. 

Men det er viktig å vurdere fordeler og ulemper for innføring av Linux-klienter, objektivt, og å ta hensyn til organisasjonens behov og krav.
-->

---
layout: center
---

# Konteksten

- Backend: **.NET** i containere
- Frontend: **React**
- Administrasjon: **M365, Entra ID, OneDrive**
- Utviklere bruker Office sjelden

<!--
Kort om hvorfor dette spørsmålet i det hele tatt er relevant.

Utviklingsstacken er fundamentalt Linux-orientert: containerne kjører Linux i produksjon, .NET er plattformuavhengig, og React-verktøyene (Node, npm, Vite) er førsteklasses på Linux.

Samtidig er resten av organisasjonen — IT, ledelse, økonomi, alle andre — dypt integrert i Microsoft-økosystemet. Det er denne spenningen vi navigerer.
-->

---
layout: center
---

# Fordeler

- **Dev/prod-paritet** uten WSL2
- **Raskere** container-bygg og filsystem
- **Ingen Windows-lisens** per maskin
- Bedre **automatisering og tilpasning**

<!--
Fire hovedpunkter på fordelssiden.

Dev/prod-paritet: produksjonscontainerne er Linux. Når utvikleren også kjører Linux, forsvinner et helt lag med oversettelse og rare feil som bare oppstår på Windows.

Ytelse: filsystemoperasjoner med mange små filer (node_modules, .NET-bygg) er målbart raskere. Ingen obligatorisk antivirusskanning av hver fil.

Kostnad: Windows-lisens spares per arbeidsstasjon. Verktøyene utviklerne bruker — VS Code, Rider, Git — er gratis og fungerer like bra eller bedre.

Automatisering: dotfiles, pakkebehandlere, devcontainers, Ansible. Reproduserbare utviklermiljøer er enklere å bygge på Linux.
-->

---
layout: center
---

# Ulemper

- **Entra ID / Intune** har begrenset Linux-støtte
- **Ingen offisiell OneDrive-klient**
- **Office og Teams** kun i nettleser
- **Parallell IT-støtte** kreves

<!--
Ulempene er nesten utelukkende administrative, ikke tekniske.

Entra ID og Intune: enhetsadministrasjon på Linux henger etter Windows. Conditional Access basert på enhetssamsvar, Autopilot-provisjonering, BitLocker-tilsvarende attestasjon — alt dette er svakere eller mangler.

OneDrive: ingen offisiell klient. Alternativene er nettleseren, uoffisielle klienter som abraunegg/onedrive, eller rclone. Ingen Files On-Demand.

Office og Teams: native klienter finnes ikke. Teams Linux-klienten ble avviklet i 2022. Nettversjonene fungerer, men mister presisjon på komplekse dokumenter og enkelte møtefunksjoner.

IT-støtte: separate herdingsbaselinjer, separat patching, separat endepunktsdeteksjon. Defender for Endpoint støtter Linux, det hjelper, men det er fortsatt et parallelt løp.
-->

---
layout: center
---

# Risikomomenter

- Samsvar (**ISO 27001, NIS2**) krever mer arbeid
- Maskinvare-edge-cases: VPN, fingeravtrykk
- Få Linux-brukere → **selvsupport-felle**

<!--
Tre risikomomenter som ofte undervurderes.

Samsvar: hvis organisasjonen har ISO 27001, SOC 2, NIS2 eller sektorspesifikke krav, må endepunktskontroller på Linux dokumenteres på en annen måte. Det er ikke umulig, men bevisinnsamlingen er mindre nøkkelferdig.

Maskinvare: bedrifts-VPN-klienter (særlig eldre, proprietære), fingeravtrykklesere, leverandørspesifikke dokkingstasjoner kan være ujevne. Alltid verifiser mot konkret maskinvarestandard før bredere utrulling.

Selvsupport-fellen: hvis bare tre-fire utviklere kjører Linux, ender de ofte opp som sin egen support. Det fungerer fint helt til noe ryker — og da er det ingen runbook.
-->

---
layout: center
---

# Et pragmatisk mønster

- **Linux** for utviklere som vil
- **Windows** som standard ellers
- **Office og Teams** på nett
- Sikkerhet vurderer **enhetsadministrasjons-hullet**

<!--
Dette er det vanligste fungerende oppsettet i organisasjoner som ligner på vår.

Linux tillates for utviklere som ber om det — ikke pålegges, ikke forbys. Windows forblir standardvalget for alle andre.

Linux-gruppen aksepterer at de bruker Office på nett og Teams i nettleseren. For utviklere som lager dokumenter sjelden er dette en akseptabel kostnad.

Den kritiske avhengigheten: sikkerhets- og samsvarsteamet må kunne godkjenne hullet i enhetsadministrasjonen. Typisk lent på Defender for Endpoint på Linux, full diskkryptering med LUKS, MDM via Intune eller tredjepart, og Conditional Access basert på bruker- og applikasjonssignaler fremfor enhetssamsvar.

Hvis sikkerhet ikke kan godkjenne det, er det dealbreakeren — ikke noe ved selve utviklingsarbeidsflyten.
-->

---
layout: center
---

# Konklusjon

Linux er en **sterk teknisk match** for stacken vår.

Friksjonen er **administrativ, ikke teknisk**.

Spørsmålet er om sikkerhet kan godkjenne hullet.

<!--
Oppsummert i tre setninger.

Teknisk er saken klar: utviklere blir målbart mer produktive på Linux når stacken er containerisert .NET og React. Dev/prod-paritet, raskere bygg, bedre verktøy.

Friksjonen ligger ett sted: enhetsadministrasjon, OneDrive, sporadisk Office-presisjon. Det er administrative problemer, ikke tekniske.

Beslutningen ligger derfor ikke hos utviklerne eller arkitektene — den ligger hos sikkerhet og samsvar. Hvis de kan godkjenne hullet, er Linux et fungerende valg. Hvis ikke, er det det som stopper det.

Takk. Spørsmål?
-->
