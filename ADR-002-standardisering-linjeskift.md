# ADR-002: Standardisering av linjeskift (LF) for Git-repositorier

**Status:** Foreslått  
**Dato:** 2026-05-05  
**Beslutningstakere:** [Ikke bestemt]  
**Kategori:** Utvikling / Kildekodehåndtering

---

## Kontekst

Organisasjonen har et hybrid utviklingsmiljø med Windows-, macOS- og Ubuntu Linux-arbeidsstasjoner (ref. ADR-001). Ulike operativsystemer bruker forskjellige linjeskiftkonvensjoner:

- **Windows:** CRLF (`\r\n`)
- **Linux / macOS:** LF (`\n`)

Uten en tydelig standard oppstår det problemer med blandede linjeskift i repositorier. Dette fører til unødvendige diff-endringer, byggefeil i Docker/CI-miljøer og konflikter ved merge.

Moderne .NET (Core og 5+) er fullstendig kryssplattform og håndterer LF uten problemer. C#-kompilatoren og moderne IDE-er på Windows fungerer feilfritt med LF.

## Beslutning

Vi standardiserer på **LF som internt linjeskift** i alle Git-repositorier. Dette håndheves gjennom `.gitattributes` og `.editorconfig` i roten av hvert repository.

### .gitattributes

Sikrer at Git lagrer alle tekstfiler med LF internt, uavhengig av utviklerens operativsystem.

```
# Håndter linjeskift automatisk for alle tekstfiler
* text=auto

# Eksplisitt LF for kode- og prosjektfiler
*.cs text
*.csproj text
*.sln text
*.json text

# Tving LF for shell-skript (kritisk for Linux/Docker)
*.sh text eol=lf

# Tving CRLF for Windows-spesifikke skript
*.bat text eol=crlf
*.cmd text eol=crlf
```

### .editorconfig

Sikrer at IDE-er (Visual Studio, VS Code) lagrer filer med LF som standard, slik at Git ikke trenger å konvertere ved commit.

```
[*]
end_of_line = lf
trim_trailing_whitespace = true
insert_final_newline = true
```

## Vurderte alternativer

| Alternativ | Grunn til avvisning |
|---|---|
| CRLF som standard | Skaper problemer i Docker-containere, CI/CD-pipelines og Linux-arbeidsstasjoner. Ikke egnet for et kryssplattformmiljø. |
| Ingen standard (la utviklerne velge) | Fører til blandede linjeskift, støyende diff-er og byggefeil. Uakseptabelt i et team med flere OS. |
| Kun .gitattributes uten .editorconfig | Fungerer, men Git må konvertere flere filer ved commit. .editorconfig reduserer konverteringer og gir en konsistent utvikleropplevelse. |

## Konsekvenser

### Positive

- Rene diff-er uten fantomendringer forårsaket av linjeskiftkonvertering
- Docker- og CI/CD-bygg fungerer uten feil relatert til linjeskift
- Konsistent utvikleropplevelse uavhengig av operativsystem
- Enkel onboarding — innstillingene følger med repositoriet

### Negative

- Eksisterende repositorier må renormaliseres (engangsjobb)
- Windows-utviklere som bruker eldre verktøy kan oppleve visningsproblemer (svært sjelden med moderne IDE-er)

## Implementering

1. Legg til `.gitattributes` og `.editorconfig` i roten av alle repositorier
2. Renormaliser eksisterende filer: `git add --renormalize .` etterfulgt av en commit
3. Informer utviklerteamet om endringen
4. Valider at CI/CD-pipelines bygger korrekt etter renormalisering

## Relasjon til andre ADR-er

- **ADR-001:** Ubuntu Linux-integrering i bedriftsmiljøet — denne ADR-en adresserer en direkte konsekvens av å innføre Linux-arbeidsstasjoner i utviklingsmiljøet.
