# ADR-001: Integrering av Ubuntu Linux i bedriftsmiljøet

**Status:** Foreslått  
**Dato:** 2026-04-13  
**Beslutningstakere:** [Ikke bestemt]  
**Kategori:** Infrastruktur / Endepunktshåndtering

---

## Kontekst

Organisasjonen har i dag et hybrid endepunktsmiljø med Windows- og macOS-klienter, administrert gjennom Microsoft Intune med Entra ID som identitetsleverandør. Det er et økende behov for å støtte Linux-arbeidsstasjoner — primært for utvikling og infrastrukturarbeid.

Flere Linux-distribusjoner ble vurdert (Ubuntu, CachyOS, Kali Linux). Ubuntu ble valgt som den første distribusjonen å integrere, på grunn av Microsofts offisielle støtte i både Intune og Defender for Endpoint.

## Beslutning

Vi integrerer Ubuntu (22.04 LTS og 26.04 LTS) som et administrert bedriftsendepunkt på linje med Windows og macOS, ved bruk av eksisterende Entra ID- og Intune-infrastruktur.

### Integrasjonen består av:

1. **Identitet:** Entra ID-enhetsregistrering via pålogging i Microsoft Edge
2. **Samsvar:** Intune Linux-samsvarsregler (OS-versjon, LUKS-kryptering, Defender-status)
3. **Sikkerhet:** Microsoft Defender for Endpoint på Linux for trusseldeteksjon og rapportering
4. **Nettleser:** Microsoft Edge som primærnettleser, som muliggjør SSO og enhetsbasert betinget tilgang
5. **Konfigurasjonsstyring:** Ansible for innstillinger utenfor Intunes rekkevidde (brannmur, SSH-herding, sertifikater, pakker)
6. **Filtilgang:** M365-webapper via Edge; OneDrive-tilgang via rclone eller nettleser
7. **Onboarding:** Standardisert shell-skript (`setup-corporate-ubuntu.sh`) for automatisert klargjøring

### Policy for betinget tilgang

En dedikert policy for betinget tilgang rettet mot Linux-plattformen opprettes, med krav om:

- Enhet markert som samsvarende i Intune
- Multifaktorautentisering
- Tilgang begrenset til M365 og godkjente bedriftsapplikasjoner

## Vurderte alternativer

| Alternativ | Grunn til avvisning |
|---|---|
| Støtte alle Linux-distribusjoner likt | Kun Ubuntu har offisiell Microsoft-støtte for Intune og Defender. Andre distribusjoner kan ikke administreres med dagens verktøy. |
| Tredjeparts UEM (f.eks. Fleet, JAMF) | Øker kostnader og kompleksitet. Intunes Linux-støtte, selv om den er begrenset, dekker det viktigste og unngår et ekstra administrasjonslag. |
| Behandle Linux som uadministrert BYOD | Uakseptabel sikkerhetsrisiko for enheter som har tilgang til bedriftsressurser. |
| Vente på bredere Intune Linux-støtte | Behovet finnes nå. Dagens funksjonalitet (samsvar + Defender) er tilstrekkelig for en første fase. |

## Konsekvenser

### Positive

- Utviklere og infrastrukturingeniører får støttede Linux-arbeidsstasjoner
- Én identitetsleverandør (Entra ID) på tvers av alle plattformer
- Konsistent sikkerhetsgrunnlinje (Defender, kryptering, samsvar) på Linux
- Automatisert onboarding reduserer klargjøringstiden

### Negative

- Intunes samsvarsomfang på Linux er snevert sammenlignet med Windows/macOS (ingen appdistribusjon, ingen full enhetssletting)
- Ingen offisiell OneDrive-synkroniseringsklient for Linux — brukere må benytte web eller rclone
- Ansible introduserer et ekstra konfigurasjonsstyringslag ved siden av Intune
- Kun Ubuntu LTS støttes — andre distribusjoner forblir utenfor omfanget

### Risikoer

| Risiko | Tiltak |
|---|---|
| Microsoft reduserer eller fjerner Linux-støtte i Intune | Følge med på Microsofts veikart. Ansible dekker konfigurasjonsstyring uavhengig. |
| Brukere installerer distribusjoner som ikke støttes og forventer bedriftstilgang | Tydelig policy: kun Ubuntu LTS er en administrert plattform. Andre distribusjoner får BYOD/begrenset tilgang. |
| Ansible-drift fra ønsket tilstand | Implementere planlagte Ansible-kjøringer eller integrere med CI/CD for driftdeteksjon. |
| LUKS-kryptering ikke aktivert på eksisterende maskiner | Forhåndssjekk i onboarding-skriptet advarer brukeren. Dokumentere prosedyre for reinstallasjon ved behov. |

## Samsvar

- Intune sjekker: OS-versjon, diskkryptering (LUKS), Defender kjører
- Betinget tilgang krever MFA og enhetssamsvar før tilgang til ressurser innvilges
- SSH herdet (ingen root-pålogging, ingen passordautentisering) via onboarding-skript
- UFW-brannmur aktivert som standard
- Automatiske sikkerhetsoppdateringer via unattended-upgrades

## Avgrensning

Denne ADR-en dekker **kun Ubuntu LTS**. CachyOS, Kali Linux og andre distribusjoner er eksplisitt utenfor omfanget for administrert tilgang. Dersom disse er nødvendige (f.eks. for penetrasjonstesting), bør en egen ADR adressere nettverkssegmentering og BYOD-tilgangspolicyer for uadministrerte Linux-enheter.
